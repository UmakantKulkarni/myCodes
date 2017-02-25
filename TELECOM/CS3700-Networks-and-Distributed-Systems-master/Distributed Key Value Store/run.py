#!/usr/bin/env python
#Run file written by professor, Christo Wilson


import sys, os, time, json, socket, select, random, subprocess, string, hashlib, bisect, atexit

VERSION = "0.4"

REPLICA_PROG = './3700kvstore'
NUM_CLIENTS = 8
TAIL_TIME = 2

# TODO:
# Matt's bug: killing a replica that's already dead. live_rids isn't getting updated somewhere, or it may be zero.
#
# Switch socket to SEQPACKET
# Make the clients dumber: don't cheat by reading sim.leader, make each client learn it locally

#######################################################################################################

# Parses and validates config files for simulations"
class Config:
    def __init__(self, filename):
        # load the json
        conf = json.loads(open(filename).read())

        # check for required fields
        if 'lifetime' not in conf or 'replicas' not in conf or 'requests' not in conf:
            raise AttributeError("Required field is missing from the config file")
        
        # load the required fields and sanity check them
        self.lifetime = int(conf['lifetime'])
        if self.lifetime < 5:
            raise ValueError("Simulation lifetime must be at least 5 seconds")
        self.replicas = int(conf['replicas'])
        if self.replicas < 3 or self.replicas > 21:
            raise ValueError("Number of replicas must be at least 3 and at most 21")
        self.requests = int(conf['requests'])
        if self.requests < 0:
            raise ValueError("Number of requests cannot be negative")

        # initialize the random number generator
        if 'seed' in conf: self.seed = conf['seed']
        else: self.seed = None
        random.seed(self.seed)
        
        # load the default variables
        self.mix = self.__get_default__(conf, 'mix', 0, 1, 0.8, "Read/Write mix must be between 0 and 1")
        self.wait = self.__get_default__(conf, 'wait', 0, self.lifetime, 2.0,
            "Wait must be between 0 and %s" % (self.lifetime))
        self.drops = self.__get_default__(conf, 'drops', 0, 1, 0.0, "Drops must be between 0 and 1")
        
        if 'events' in conf: self.events = conf['events']
        else: self.events = []

        # sanity check the events
        for event in self.events:
            if event['type'] not in ['kill_leader', 'kill_non_leader', 'part_easy', 'part_hard', 'part_end']:
                raise ValueError("Unknown event type: %s" % (event['type']))
            if event['time'] < 0 or event['time'] > self.lifetime:
                raise ValueError("Event time must be between 0 and %s" % (self.lifetime))

    def __get_default__(self, conf, field, low, high, default, exception):
        if field in conf:
            temp = float(conf[field])
            if temp < low or temp > high:
                raise ValueError(exception)
        else: temp = default
        return temp
    
    def dump(self):
        print ('%8s %s\n' * 8) % ('Lifetime', self.lifetime, 'Replicas', self.replicas,
                                  'Requests', self.requests, 'Seed', self.seed,
                                  'Mix', self.mix, 'Wait', self.wait, 'Drops', self.drops),
        for event in self.events:
            print '%8s %15s %s' % ('Event', event['type'], event['time'])

#######################################################################################################

class Client:
    class Request:
        def __init__(self, get, key, val=None):
            self.get = get
            self.key = key
            self.val = val
            self.ts = time.time()

    def __init__(self, simulator, cid):
        self.reqs = {}
        self.items = {}
        self.completed = set()
        self.sim = simulator
        self.cid = cid
    
    def __get_rand_str__(self, size=16, chars=string.ascii_uppercase + string.digits):
        return ''.join(random.choice(chars) for _ in range(size))
    
    def __create_get__(self, key):
        self.sim.total['get'] += 1
        mid = self.__get_rand_str__()
        self.reqs[mid] = self.Request(True, key)
        dst = self.sim.leader
        if dst == 'FFFF': dst = random.choice(self.sim.replicas.keys())
        return {'src': self.cid, 'dst': dst, 'leader': self.sim.leader,
                'type': 'get', 'MID': mid, 'key': key}
        
    def __create_put__(self, key, value):
        self.sim.total['put'] += 1
        mid = self.__get_rand_str__()
        self.reqs[mid] = self.Request(False, key, value)
        dst = self.sim.leader
        if dst == 'FFFF': dst = random.choice(self.sim.replicas.keys())
        return {'src': self.cid, 'dst': dst, 'leader': self.sim.leader,
                'type': 'put', 'MID': mid, 'key': key, 'value': value}

    def finalize(self):
        fail_get = 0
        fail_put = 0
        for req in self.reqs.itervalues():
            if req.get: fail_get += 1
            else: fail_put += 1
        return (fail_get, fail_put)
        
    def create_req(self, get=True):
        # create a get message, if possible
        if get and len(self.items) > 0:
            return self.__create_get__(random.choice(self.items.keys()))
        
        # decide to add a new key, or update an existing key
        if len(self.items) == 0 or random.random() > 0.5:
            k = self.__get_rand_str__(size=32)
            v = hashlib.md5(k).hexdigest()
        else:
            k = random.choice(self.items.keys())
            v = hashlib.md5(self.items[k]).hexdigest()
        return self.__create_put__(k, v)
                    
    def deliver(self, raw_msg, msg):
        # validate the message
        if 'MID' not in msg:
            print "*** Simulator Error - Message missing mid field: %s" % (raw_msg)
            self.sim.incorrect += 1
            return None
        if msg['type'] not in ['ok', 'fail', 'redirect']:
            print "*** Simulator Error - Unknown message type sent to client: %s" % (raw_msg)
            self.sim.incorrect += 1
            return None
        
        mid = msg['MID']

        # is this a duplicate?
        if mid in self.completed:
            self.sim.duplicates += 1
            return None
        
        # is this a message that I'm expecting?
        try:
            req = self.reqs[mid]
        except:
            print "*** Simulator Error - client received an unexpected MID: %s" % (raw_msg)
            self.sim.incorrect += 1
            return None
        
        del self.reqs[mid]
        
        self.sim.latencies.append(time.time() - req.ts)
        
        # if this is a redirect or a fail, try again
        if msg['type'] in ['redirect', 'fail']:
            if req.get:
                if msg['type'] == 'fail': self.sim.failures['get'] += 1
                self.sim.redirects += 1
                return self.__create_get__(req.key)            
            if msg['type'] == 'fail': self.sim.failures['put'] += 1            
            self.sim.redirects += 1
            return self.__create_put__(req.key, req.val)
        
        # msg type must be ok, mark it as completed
        self.completed.add(mid)
        if req.get:
            if 'value' not in msg:
                print "*** Simulator Error - get() response missing the value of the key: %s" % (raw_msg)
                self.sim.incorrect += 1
    
            if self.items[req.key] != msg['value']:
                print "*** Simulator Error - client received an incorrect value for a key: %s" % (raw_msg)
                self.sim.incorrect += 1
        else:
            self.items[req.key] = req.val
        
        return None

#######################################################################################################

# Represents a replica, the associated process, and it's sockets
class Replica:
    def __init__(self, rid):
        self.rid = rid
        self.client_sock = None
        self.alive = False
        
        # try and delete the old domain socket, just in case
        try: os.unlink(rid)
        except: pass

        # create the listen socket for this replica
        self.listen_sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.listen_sock.bind(rid)
        self.listen_sock.listen(1)

    def run(self, rids):
        args = [REPLICA_PROG, self.rid]
        args.extend(rids - set([self.rid]))
        self.proc = subprocess.Popen(args)
        self.alive = True
        
    def shutdown(self):
        if self.alive:
            self.alive = False
            if self.client_sock: self.client_sock.close()
            self.listen_sock.close()
            self.proc.kill()
            self.proc.wait()
            os.unlink(self.rid)

    def deliver(self, raw_msg):
        if self.alive:
            try:
                self.client_sock.send(raw_msg + '\n')
                return True
            except:
                # the socket is busted, so this replica is dead
                self.shutdown()
        return False
                                
#######################################################################################################

# Represents and executes the entire simulation
class Simulation:        
    def __init__(self, filename):
        self.leader = 'FFFF'
        self.events = []
        
        # stats tracking variables
        self.total_msgs = 0
        self.total = {'get': 0, 'put': 0}
        self.failures = {'get': 0, 'put': 0}
        self.redirects = 0
        self.duplicates = 0
        self.incorrect = 0
        self.total_drops = 0        
        self.latencies = []

        # for handling partial reads
        self.rollover = None
                
        # virtual network partitions
        self.partition = None
                
        # Load the config file
        self.conf = Config(filename)
        #self.conf.dump()
        
        # Create the clients
        self.cids = set()
        self.clients = {}
        for i in xrange(self.conf.replicas + 16, self.conf.replicas + 16 + NUM_CLIENTS):
            cid = ('%04x' % (i)).upper()
            self.cids.add(cid)
            self.clients[cid] = Client(self, cid)
                
        # Create the sockets and the replicas
        self.rids = set()
        self.replicas = {}
        self.listen_socks = set()
        self.client_socks = set()
        for i in xrange(self.conf.replicas):
            rid = ('%04x' % (i)).upper()
            self.rids.add(rid)
            self.replicas[rid] = Replica(rid)
            self.listen_socks.add(self.replicas[rid].listen_sock)

        self.living_rids = self.rids.copy()

    def print_stats(self):
        print 'Simulation finished.'
        print 'Total messages sent:', self.total_msgs
        print 'Total messages dropped:', self.total_drops
        print 'Total client get()/put() requests: %i/%i' % (self.total['get'], self.total['put'])
        print 'Total duplicate responses: %i' % (self.duplicates)
        print 'Total redirects: %i' % (self.redirects)
        print 'Total get()/put() failures: %i/%i' % (self.failures['get'], self.failures['put'])
        print 'Total get() with incorrect response:', self.incorrect
        if len(self.latencies) > 0:
            print 'Mean/Median query latency: %fsec/%fsec' % (float(sum(self.latencies))/len(self.latencies),
                                                              self.latencies[len(self.latencies)/2])
    
    def get_stats(self):
        class Stats: pass
        s = Stats()
        s.total_msgs = self.total_msgs
        s.total_drops = self.total_drops
        s.total_get = self.total['get']
        s.total_put = self.total['put']
        s.failed_get = self.failures['get']
        s.failed_put = self.failures['put']
        s.incorrect = self.incorrect
        s.duplicates = self.duplicates
        s.redirects = self.redirects
        if len(self.latencies) > 0:
            s.mean_latency = float(sum(self.latencies))/len(self.latencies)
            s.median_latency = self.latencies[len(self.latencies)/2]
        else:
            s.mean_latency = 0.0
            s.median_latency = 0.0                        
        return s
    
    def run(self):
        for r in self.replicas.itervalues():
            r.run(self.rids)
        
        # initialize the clock and create all the get(), put(), and kill() events
        clock = start = time.time()
        self.__populate_event_queue__(clock)
        
        # the main recv() and event loop
        while clock - start < self.conf.lifetime:
            sockets = list(self.listen_socks | self.client_socks)

            ready = select.select(sockets, [], [], 0.1)[0]
            
            for sock in ready:
                # if this is a listen sock, accept the connection and map it to a replica
                if sock in self.listen_socks: self.__accept__(sock)
                # otherwise, this is a client socket connected to a replica
                else: self.__route_msgs__(sock)

            # check the time and fire off events
            clock = time.time()
            while len(self.events) != 0 and self.events[0][0] < clock:
                self.events.pop(0)[1]()
                                
        # Finish out the clients. All unanswered requests are considered failures
        for client in self.clients.itervalues():
            fg, fp = client.finalize()
            self.failures['get'] += fg
            self.failures['put'] += fp
        
        # Sort the latency samples so stats can be calculated
        self.latencies.sort()
                                
    def shutdown(self):
        for r in self.replicas.itervalues():
            try: r.shutdown()
            except: pass
                                
    def __kill_replica__(self, r):
        if r.rid not in self.living_rids: return
        self.living_rids.remove(r.rid)        
        self.listen_socks.remove(r.listen_sock)
        self.client_socks.remove(r.client_sock)
        r.shutdown()

    def __kill_leader__(self):
        if self.leader != 'FFFF':
            self.__kill_replica__(self.replicas[self.leader])
            self.leader = 'FFFF'
                        
    def __kill_non_leader__(self):
        self.__kill_replica__(self.replicas[random.choice(list(self.living_rids - set([self.leader])))])

    def __partition__(self, add_leader=False):
        qsize = len(self.replicas) / 2 + 1
        self.partition = set()
        r = list(self.rids)

        if add_leader and self.leader != 'FFFF':
            self.partition.add(self.leader)
            r.remove(self.leader)
            qsize -= 1
        else:
            self.leader = 'FFFF'
                        
        for i in range(qsize):
            rid = random.choice(r)
            self.partition.add(rid)
            r.remove(rid)

    def __partition_easy__(self):
        self.__partition__(True)
                        
    def __partition_hard__(self):
        self.__partition__()

    def __partition_end__(self):
        self.partition = None

    def __check_partition__(self, rid1, rid2):
        if not self.partition: return True
        i = len(self.partition & set([rid1, rid2]))
        if i == 2 or i == 0: return True
        return False
                
    def __send_get__(self):
        client = random.choice(self.clients.values())
        msg = client.create_req(True)
        self.__replica_deliver__(self.replicas[msg['dst']], json.dumps(msg))
        
    def __send_put__(self):
        client = random.choice(self.clients.values())
        msg = client.create_req(False)
        self.__replica_deliver__(self.replicas[msg['dst']], json.dumps(msg))

    def __replica_deliver__(self, replica, raw_msg):
        if not replica.deliver(raw_msg):
        	self.__kill_replica__(replica)
                        
    def __populate_event_queue__(self, clock):
        clock += self.conf.wait

        # Generate get() and put() events for the event queue
        t = clock
        delta = float(self.conf.lifetime - self.conf.wait - TAIL_TIME) / self.conf.requests
        for i in xrange(self.conf.requests):
            if random.random() < self.conf.mix: self.events.append((t, self.__send_get__))
            else: self.events.append((t, self.__send_put__))
            t += delta
                        
        # Add any events from the config into the event queue
        for event in self.conf.events:
            if event['type'] == 'kill_leader':
                bisect.insort(self.events, (event['time'] + clock, self.__kill_leader__))
            elif event['type'] == 'kill_non_leader':
                bisect.insort(self.events, (event['time'] + clock, self.__kill_non_leader__))
            elif event['type'] == 'part_easy':
                bisect.insort(self.events, (event['time'] + clock, self.__partition_easy__))
            elif event['type'] == 'part_hard':
                bisect.insort(self.events, (event['time'] + clock, self.__partition_hard__))
            elif event['type'] == 'part_end':
                bisect.insort(self.events, (event['time'] + clock, self.__partition_end__))

    def __validate_addr__(self, addr):
        if type(addr) not in [str, unicode] or len(addr) != 4: return False
        try:
            i = int(addr, 16)
        except:
            return False
        return True
                                
    def __route_msgs__(self, sock):
        try:
            raw_msgs = sock.recv(131072)
        except: 
            print "*** Simulator Error - A replica quit unexpectedly"
            self.__close_replica__(sock)
            return

        # is this sock shutting down?
        if len(raw_msgs) == 0:
            self.__close_replica__(sock)
            return

        raw_msgs = raw_msgs.split('\n')
                
        for index, raw_msg in enumerate(raw_msgs):
            if len(raw_msg) == 0: continue

            if self.rollover:
                raw_msg = self.rollover + raw_msg
                self.rollover = None
                                
            # decode and validate the message
            try:
                msg = json.loads(raw_msg)
            except:
                if index == len(raw_msgs) - 1:
                    self.rollover = raw_msg
                    return

                print "*** Simulator Error - Unable to decode JSON message: %s" % (raw_msg)
                self.incorrect += 1
                return
            
            if type(msg) is not dict:
                print "*** Simulator Error - Message is not a dictionary: %s" % (raw_msg)
                self.incorrect += 1
                return
            if 'src' not in msg or 'dst' not in msg or 'leader' not in msg or 'type' not in msg:
                print "*** Simulator Error - Message is missing a required field: %s" % (raw_msg)
                self.incorrect += 1
                return
            if not self.__validate_addr__(msg['leader']):
                print "*** Simulator Error - Incorrect leader format: %s" % (raw_msg)
                self.incorrect += 1
                return
            if not self.__validate_addr__(msg['dst']):
                print "*** Simulator Error - Incorrect destination format: %s" % (raw_msg)
                self.incorrect += 1
                return
            if not self.__validate_addr__(msg['src']):
                print "*** Simulator Error - Incorrect source format: %s" % (raw_msg)
                self.incorrect += 1
                return
                        
            # record the id of the current leader
            if not self.partition or msg['src'] in self.partition:
                self.leader = msg['leader']

            # is this message to a replica?
            if msg['dst'] in self.replicas:
                self.total_msgs += 1
                if self.__check_partition__(msg['src'], msg['dst']) and random.random() >= self.conf.drops:
                    self.__replica_deliver__(self.replicas[msg['dst']], raw_msg)
                else: self.total_drops += 1
    
            # is this message a broadcast?
            elif msg['dst'] == 'FFFF':
                self.total_msgs += len(self.replicas) - 1
                for rid, r in self.replicas.iteritems():
                    if rid != msg['src']:
                        if self.__check_partition__(msg['src'], rid) and random.random() >= self.conf.drops:
                            self.__replica_deliver__(r, raw_msg)
                        else: self.total_drops += 1

            # is this message to a client?
            elif msg['dst'] in self.clients:
                response = self.clients[msg['dst']].deliver(raw_msg, msg)
                if response:
                    self.__replica_deliver__(self.replicas[response['dst']], json.dumps(response))
                
            # we have no idea who the destination is
            else:
                print "*** Simulator Error - Unknown destination: %s" % (raw_msg)
                self.incorrect += 1
            
    def __accept__(self, sock):
        client = sock.accept()[0]
        self.client_socks.add(client)
        for r in self.replicas.itervalues():
            if r.listen_sock == sock:
                r.client_sock = client
                break
    
    def __close_replica__(self, sock):
        for r in self.replicas.itervalues():
            if r.client_sock == sock:
                self.living_rids.remove(r.rid)
                self.client_socks.remove(r.client_sock)
                self.listen_socks.remove(r.listen_sock)
                r.shutdown()
                break

#######################################################################################################

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print 'Usage: $ %s <config file>' % (sys.argv[0])
        sys.exit()

    sim = Simulation(sys.argv[1])

    def kill_processes():
        try: sim.shutdown()
        except: pass

    # Attempt to kill child processes regardless of how Python shuts down (e.g. via an exception or ctrl-C)
    atexit.register(kill_processes)
        
    sim.run()
    sim.print_stats()
