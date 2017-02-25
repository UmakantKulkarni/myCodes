<article>
<div class="section_header">CS 3700 - Networks and Distributed Systems</div>
<h2>Project 5: Distributed, Replicated Key-Value Store</h2>
<p>
<b>This project is due at 11:59pm on December 9, 2015.</b>
</p><p>
</p><h2>Description</h2>
In his project, you will build a (relatively) simple, distributed, replicated key-value datastore. A key-value
datastore is a very simple type of database that supports two API calls from clients: <i>put(key, value)</i>
and <i>get(key)</i>. The former API allows a client application to store a key-value pair in the database,
while the latter API allows a client to retrieve a previously stored value by supplying its key. Real-world
examples of distributed key-value datastores include memcached, Redis, DynamoDB, etc. 
<p></p><p>
Of course, it would be simple to build a key-value store if it was a single process. However, your system must
be replicated and support strong consistency guarantees. Thus, you will be implementing
a simplified version of the <a href="http://ramcloud.stanford.edu/raft.pdf">Raft</a> consensus protocol.
Your datastore will be run multiple times, in parallel, and it will use the Raft protocol to maintain consensus
among the replicas.
</p><p>
Your datastore will be tested for both correctness and performance. We will provide a testbed for your
datastore that will simulate clients who execute <i>put()</i> and <i>get()</i> commands, as well as
an unreliable network that can drop packets or make hosts unavailable. Part of your grade will come
from the overhead your system has (i.e., fewer packets will result in a higher score), while another
part will depend on the speed at which your datastore answers client queries (i.e. what is the query
latency). Your results will be compared to your classmates' via a leaderboard.
</p><p>
</p><h2>Language and Libraries</h2>
You may write your code in whatever language you choose, as long as your code compiles and runs
on <b>unmodified</b> CCIS Linux machines <b>on the command line</b>. Do not use libraries that are not
installed by default on the CCIS Linux machines. Similarly, your code must compile and run on the
command line. You may use IDEs (e.g. Eclipse) during development, but do not turn in your IDE
project without a Makefile. Make sure you code has <b>no dependencies</b> on your IDE.
<p></p><p>
You may not use libraries or modules that implement consensus protocols. This includes any library that
implements Raft, Paxos, Replicated View-state, or similar protocols. Obviously, you cannot use any libraries
or software packages that implement a replicated key-value datastore. For example, your program cannot
be a thin wrapper around memcached, etc. You may use libraries or modules that implement local database
storage (e.g. SQLite, BerkeleyDB, LevelDB) if you want to use them for persistent storage within each replica. If you
have any questions about whether a particular library or module is allowed, post on Piazza.
</p><p>
    </p><h2>Your Program</h2>
    For this project, you will submit one program named <b>3700kvstore</b> that implements the replicated datastore.
    You may use any language of your choice, and we will give you basic starter code in python. Keep in mind
	that you are writing a program that will be run multiple times, in parallel, to form a distributed system. Thus,
	<b>3700kvstore</b> will bear some conceptual similarities to your <b>3700bridge</b> program from Project 2.
<p></p><p>
    If you use C or any other compiled language, your executable should be named 3700kvstore.
    If you use an interpreted language, your script should be called 3700kvstore and be marked as
    executable. If you use a virtual machine-based language (like Java or C#), you must write a brief
    Bash shell script, named 3700kvstore, that conforms to the input syntax given below and then launches
    your program using whatever incantations are necessary. For example, if you write your solution
    in Java, your Bash script might resemble
    </p><pre>      #!/usr/bin/perl -w
      $args = join(' ', @ARGV);
      print 'java -jar 3700kvstore.jar $args';</pre>
    Or, if you use python, your script might start with
    <pre>      #!/usr/bin/python
      import foo from bar</pre>
    and should be marked executable.
<p></p><p>
    </p><h2>Starter Code</h2>
    Very basic starter code for the assignment in Python, as well as the testbed scripts, are available in /course/cs3700f15/code/project5.
    To get started, you should copy this directory into your own local directory (i.e., cp -r /course/cs3700f15/code/project5 ~/), since
	you will need the <i>run.py</i> and <i>test.py</i> scripts, as well as the example configuration files.
<p></p><p>
	The starter code provides a bare-bones implementation of a datastore that simply connects to the LAN and
	broadcasts a "no-op" message once every second. You may use this code as a basis for your project if
    you wish, but it is strongly recommended that you do not do so unless you are comfortable
    with Python.
</p><p>
    </p><h2>Testing Your Code</h2>
	In order to evaluate your replicated datastore, we have provided a simulated test environment. The
	simulator will create an emulated network and all necessary sockets, execute several copies of your
	datastore with the appropriate command line arguments, route messages between the datastore
	replicas, and generate requests from clients. This script is included
    in the starter code, and you can run it by executing
    <pre>./run.py &lt;config-file&gt;</pre>
    where &lt;config-file&gt; is the configuration file that describes the test configuration you would like to use.
    Note that you will not need to modify the run script, or parse the config files (the run script parses the
	config files). You may create custom configs to test your code under different scenarios if you want to.
<p></p><p>
    </p><h3>Config File Format</h3>
    The configuration file that you pass to ./run.py contains a number of parameters that control the
	simulation. The file is formatted in JSON and has the following elements
    <ul>
      <li>lifetime (Required) The number of seconds the simulation should run for. Must be at least 5.</li>
      <li>replicas (Required) The number of replicas to execute, i.e. copies of your 3700kvstore program. Must be at least 3.</li>
	  <li>requests (Required) The number of get() and put() requests to randomly generate from clients.</li>
	  <li>mix (Optional) Float between 0 and 1 representing the fraction of client queries that are get()s. Defaults to 0.8.</li> 
      <li>wait (Optional) The number of seconds to wait before sending any client requests. Defaults to 2 seconds.</li>
      <li>seed (Optional) The random seed to choose. If not specified, a random value is chosen. Setting
      this value will allow for a semi-reproducible set of clients and requests.</li>
	  <li>drops (Optional) Float between 0 and 1 representing the fraction of messages between replicas to drop. Defaults to 0.</li>
	  <li>events (Optional) A list of events that will occur during the simulation. Each event has a type and a time when it will trigger
	  <ul>
	    <li>type (Required) The type of event. Valid types are 'kill_non_leader' and 'kill_leader'. The former will crash fail a random non-leader replica. The latter will crash fail the current leader.</li>
	    <li>time (Required) The timestamp, in seconds, when the event should occur.</li>
	  </ul>
    </li></ul>
    For example, a simple configuration with no events and a read-heavy workload might look like the following
    <pre>      {
          "lifetime": 30,
          "replicas": 5,
          "requests": 100,
          "mix": 0.9
      }</pre>
    and a more complex configuration with events and a lossy network might be
    <pre>      {
          "lifetime": 30,
          "replicas": 5,
          "requests": 100,
          "mix": 0.7,
	  "drops": 0.1,
          "events": [{"type": "kill_non_leader", "time": 10},
                      {"type": "kill_leader", "time": 20}]
      }</pre>
<p></p><p>
    </p><h3>./run.py Output</h3>
    The ./run.py script will output any errors it encounters during the simulation, including malformed
    messages, messages to unknown destinations, replicas that unexpectedly quit, etc. Once the simulation
    completes, ./run.py prints some statistics about your datastore's performance:
    <pre>    bash$ ./run.py config.json
    ...
    Simulation finished.
    Total messages sent: 6730
    Total client get()/put() requests: 60/40
    Total get()/put() failures: 0/1
    Total get() with correct response: 60
    Average/mean query latency: 1.2sec/0.9sec
    Total messages dropped: 183</pre>
    Each of the fields is self-explanatory. Ideally, you would like all get() and put() requests to succeed
	without failing and for them to have low latency. Obviously, if your system is returning incorrect values
	to get() requests then your datastore has consistency issues. Furthermore, you would like the total
	number of packets to
	be as low as possible, i.e. the overhead of your datastore on the network should be low.
<p></p><p>
    </p><h3>Testing Script</h3>
    Additionally, we have included a basic test script that runs your code under a variety of different
    configurations and also checks your code's compatibility with the grading script. If your
    code fails in the test script we provide, you can be assured that it will fare poorly when run under
    the grading script. To run the test script, simply type
    <pre>    bash$ ./test.py
	Basic tests (5 replicas, 30 seconds, 100 requests):
		No drops, no failures, 80% read		[PASS]
		No drops, no failures, 60% read		[PASS]
		No drops, no failures, 40% read		[PASS]
		No drops, no failures, 20% read		[PASS]
	Unreliable network tests (5 replicas, 30 seconds, 150 requests):
		10% drops, no failures, 80% read	[FAIL]
	...
	</pre>
<!--
		10% drops, no failures, 20% read
		20% drops, no failures, 80% read
		20% drops, no failures, 20% read
		30% drops, no failures, 80% read
		30% drops, no failures, 20% read
	Crash failure tests (5 replicas, 30 seconds, 200 requests):
		No drops, 1 replica failure, 80% read
		No drops, 1 replica failure, 20% read
		No drops, 2 replica failure, 80% read
		No drops, 2 replica failure, 20% read
		No drops, 1 leader failure, 80% read
		No drops, 1 leader failure, 20% read
	Bring the pain (5 replicas, 30 seconds, 300 requests):
		20% drops, 2 replica failure, 20% read
		30% drops, 2 replica failure, 20% read
		30% drops, 1 leader failure, 20% read
		50% drops, 2 leader failure, 20% read	
-->
    This will run your datastore on a number of configurations, and will output whether your program
    performs sufficiently. If you wish to run one of the tests manually, you can do so with
    <pre>bash$ ./run.py test-whatever.json</pre>
<p></p><p>
    </p><h2>Message Format</h2>
	To simplify this project, instead of using real packet formats, we will be sending our data across
	the wire in JSON (many languages have utilities to encode and decode JSON, and you are welcome
    to use these libraries). All messages <b>must</b> be encoded as a dictionary, they <b>must</b> end
    with a \n, and they <b>must</b> include the following four keys (at a minimum) :
	<ul>
		<li><i>src</i> - The ID of the source of the message.</li>
		<li><i>dst</i> - The ID of the destination of the message.</li>
		<li><i>leader</i> - The ID of the leader, or "FFFF" if the leader's ID is unknown.</li>
		<li><i>type</i> - The type of the message.</li>
	</ul>
	The simulator uses <i>src</i> and <i>dst</i> instead of IP addresses in order to route and deliver messages.
	Furthermore, the simulator supports multicast: if <i>dst</i> is set to "FFFF", the message will be
	delivered to all replicas (use multicast sparingly, since it is expensive). <i>leader</i> is the ID of the
	replica that the sender of the message believes is the leader. All messages must include the <i>leader</i>
	so that the simulator can learn which replica is the leader (otherwise, the simulator would have no way of
	determining this information).
<p></p><p>
	<i>type</i> describes the type of the message. You may define custom types in order to implement your
	datastore (and you may add custom keys to the message dictionary in these cases). However, there are
	several message types that your replicas <b>must</b> support in order to handle requests from clients.
	</p><ul>
		<li><i>get</i> - get() messages are read requests from clients. They have the following format:
		  <pre>{"src": "&lt;ID&gt;", "dst": "&lt;ID&gt;", "leader": "&lt;ID&gt;",
"type": "get", "MID": "&lt;a unique string&gt;", "key": "&lt;some key&gt;"}</pre>
		Your replicas may respond with an OK message which include the corresponding value:
		  <pre>{"src": "&lt;ID&gt;", "dst": "&lt;ID&gt;", "leader": "&lt;ID&gt;",
"type": "ok", "MID": "&lt;a unique string&gt;", "value": "&lt;value of the key&gt;"}</pre>
		Or your replicas may respond with a failure message, in which case the client will retry the get():
		  <pre>{"src": "&lt;ID&gt;", "dst": "&lt;ID&gt;", "leader": "&lt;ID&gt;",
"type": "fail", "MID": "&lt;a unique string&gt;"}</pre>		
		If the client issues a get() for a key that has does not exist (i.e. it was never put()), your datastore should return an empty value (i.e. an empty string).
		</li>
		<li><i>put</i> - put() messages are write requests from clients. They have the following format:
		  <pre>{"src": "&lt;ID&gt;", "dst": "&lt;ID&gt;", "leader": "&lt;ID&gt;",
"type": "put", "MID": "&lt;a unique string&gt;", "key": "&lt;some key&gt;",
"value": "&lt;value of the key&gt;"}</pre>
		Your replicas may respond with an OK message if the write was successful:
		  <pre>{"src": "&lt;ID&gt;", "dst": "&lt;ID&gt;", "leader": "&lt;ID&gt;",
"type": "ok", "MID": "&lt;a unique string&gt;"}</pre>
		Or your replicas may respond with a failure message, in which case the client will retry the put():
		  <pre>{"src": "&lt;ID&gt;", "dst": "&lt;ID&gt;", "leader": "&lt;ID&gt;",
"type": "fail", "MID": "&lt;a unique string&gt;"}</pre>		
		</li>
		<li><i>redirect</i> - If the client sends any message (get() or put()) to a replica that is not the leader, it should respond with a redirect:
		  <pre>{"src": "&lt;ID&gt;", "dst": "&lt;ID&gt;", "leader": "&lt;ID&gt;",
"type": "redirect", "MID": "&lt;a unique string&gt;"}</pre>
		In this case, the client will retry the request by sending it to the specified leader.
		</li>
	</ul>
	Note that in all of the above cases, the MID in a request must match the MID in the response. For example, the following would
	be a legal series of requests and responses, where 001A is a client and 0000 and 0001 are replicas:
	<pre>Request 1     {"src": "001A", "dst": "0001", "leader": "FFFF",
               "type": "get", "MID": "4D61ACF83027", "key": "name"}
Response 1    {"src": "0001", "dst": "001A", "leader": "0000",
               "type": "redirect", "MID": "4D61ACF83027"}
	
Request 2     {"src": "001A", "dst": "0000", "leader": "0000",
               "type": "get", "MID": "9AB4CE50023", "key": "name"}
Response 2    {"src": "0000", "dst": "001A", "leader": "0000", "type": "ok",
               "MID": "9AB4CE50023", "value": "Christo Wilson"}
	</pre>
	Again, you will need to develop additional, custom message types in order to implement the Raft consensus
	protocol. As long as your messages include the four minimum required fields (src, dst, leader, type), the
	simulator will ensure that your messages are delivered.
<p></p><p>
    Finally, as mentioned above <b>all messages must be terminated with a line-feed (\n) character</b>. When you
    recv() data from the domain socket, you may end up reading multiple, separate messages. You can use the \n
    characters to split the data and thus recover the individual messages. Be sure to remove the \n from the
    string before you attempt to decode the JSON: many JSON decoders will throw an exception if they encounter
    unknown characters like \n in the data stream.
</p><p>
    </p><h2>Command Line Specification</h2>
    The command line syntax for your <i>3700kvstore</i> program is given below. The simulator will pass parameters
	to each replica representing (1) the ID of the replica, and (2) the IDs of all other replicas in the system.
	The syntax for launching your datastore is therefore:
    <pre>./3700kvstore &lt;your ID&gt; &lt;ID of second replica&gt; [ID3 [ID4 ...]]</pre>
	For simplicity, all replica IDs are unique four-digit hexadecimal numbers (e.g., 0AA1 or F29A). You will use these IDs as the
	<i>src</i> and <i>dst</i> in your messages. Clients will also be assigned unique IDs by the simulator.
    
<p></p><p>
    </p><h2>Connecting to the LAN</h2>
    We will be using UNIX domain sockets to emulate a LAN. Each of your replicas will connect to a single
	domain socket (the way a server would connect to a single Ethernet cable). A replica will send and 
	receive all messages over this socket (i.e. messages to/from other replicas, as well as messages
	to/from clients). Your program should be constantly reading from the socket make sure it receives all
	messages (they will be buffered if you don't read immediately). The simulator will take care of routing
	all sent messages to the appropriate destinations;
	thus, it's okay if you're not intimately familiar with how Domain Sockets work, or with how the simulator
	works.
<p></p><p>	
	Each replica should connect to a Domain Socket named "ID" (no-quotes), where ID is the replica's ID
	(i.e. the first ID it receives on the command line). We will be using the SOCK_SEQPACKET socket type, which
	provides a reliable message-oriented stream. Note that unlike Project 2, you do not need to pad
	the name of the domain sockets with \0.
</p><p>
    Exactly how to connect to a UNIX domain socket depends on your programming language.
    For example, if you were using perl to complete the project, your code for connecting would look
    like:
    </p><pre>use IO::Socket::UNIX;

my $lan = IO::Socket::UNIX-&gt;new(
    Type =&gt; SOCK_SEQPACKET,
    Peer =&gt; "&lt;lan&gt;"
);</pre>
    You can then read and write from the $lan variable. In python, your code would look like
    <pre>from socket import socket, SOCK_SEQPACKET, AF_UNIX
s = socket (AF_UNIX, SOCK_SEQPACKET)
s.connect ('&lt;lan&gt;')</pre>
    with similar results.
<p></p><p>
    We encourage you to write your code in an event-driven style using select() or poll(). This will keep
	your code single-threaded and will make debugging your code significantly easier. Alternatively, you
	can implement your datastore in a threaded model, but expect it to be significantly more
    difficult to debug.
</p><p>
    </p><h2>Datastore Requirements and Assumptions</h2>
	The goal of your system is to accept put()s from clients and retrieve the corresponding
	data when a get() is issued. To ensure that data is not lost when a process crashes, all data from
	clients must be replicated, which then raises the dueling issues of how to maintain consistency and
	achieve high-availability. To meet these goals, your datastore will implement the Raft consensus protocol.
	Ultimately, your datastore should achieve the following two goals:
	<ol>
		<li>Consistency - clients should always receive correct answers to get() requests.</li>
		<li>Availability - clients should be able to execute put() and get() requests at any time with low latency
		(i.e. your system should execute requests quickly).</li>
	</ol>
	Raft is a complicated protocol, and real-world datastores are extremely complicated artifacts. To
	simplify this project, there are several things you <b>do not need to implement</b>:
	<ul>
		<li>True persistence - you do not need to write client updates to disk, or worry about committing data
		to permanent storage. All of the data from clients and the log of updates can live in memory.</li>
		<li>Garbage collection - Raft maintains a log of all updates. In a real system, this log periodically needs
		to be garbage collected, since it cannot grow infinitely long. However, your system will not be running for
		long periods time, and therefor you do not need to worry about garbage collection.</li>
	    <li>Restarts - in a real system, replicas might fail for a while then come back online, necessitating
		snapshots and reconciliation. However, you may assume that replicas in the simulator will crash fail,
		i.e. they will die completely and never return.</li>
	</ul>
<p></p><p>
    </p><h2>Implementing Raft</h2>
	The <a href="http://ramcloud.stanford.edu/raft.pdf">Raft paper</a> is specifically designed to be easy to read.
	To implement the protocol you should definitely start by reading the paper. Additional papers and resources
	are available on the <a href="https://raft.github.io/">Raft Github</a>. I would suggest the following series of
	steps to begin working on your datastore implementation:
	<ol>
		<li>Add basic support for responding to client get() and put() requests. At this point, you can respond to all requests with a "type": "fail" message.</li>
		<li>Implement the Raft election protocol (section 5.2 of the Raft paper); add the ability to respond to get() and put() requests with "type": "redirect" messages.</li>
		<li>Add a timeout to detect leader failures (i.e. if you don't hear from the leader in X milliseconds...) and make sure that the new election proceeds correctly.</li>
		<li>Implement a basic, empty version of the AppendEntries RPC call that doesn't replicate any data, but acts as a keepalive message from the leader to other replicas to prevent unnecessary elections.</li>
		<li>Implement the transaction log and the "state machine" (i.e. a dictionary containing the key/value pairs from clients, Section 5.3). Don't bother replicating the transactions, just ensure that the leader is able to correctly answer get() and put() requests.</li>
		<li>Improve your AppendEntries RPC call to actually send data to replicas. Ensure that updates are only committing when a quorum is in agreement.</li>
		<li>Add support for retrying failed commits and test it by experimenting with lossy network simulations.</li>
		<li>If you haven't already, modify the leader election to support the additional restrictions in Section 5.4.1; test your implementation on lossy networks with failed leaders.</li>
		<li>Implement the subtle commit restriction given in Section 5.4.2.</li>
		<li>Test, test, test, and test some more ;)</li>
	</ol>
	Step 6 will probably require the most time in terms of writing code and debugging, since it is the crux of the algorithm.
	Implementing steps 7-9 are necessary to ensure correctness of the protocol, but shouldn't be too difficult.
<p></p><p>
    </p><h3>Performance Testing</h3>
    10% of your grade on this project will come from performance. Your
    project will be graded against the submissions of your peers. To help you know how you're doing,
    the testing script will report total packets sent and average request latency for several of the harder tests
	to a central database. Note that, by default, only reasonable scores are sent to the database; if your scores
	aren't showing up, that means the tests are not passing, or you need to improve your performance.
<p></p><p>
    In order to see how your project ranks, you can run
    </p><pre>    bash$ /course/cs3700f15/bin/project5/printstats
    ----- TEST: 20% drops, 2 replica failure, 20% read -----
    Least overhead:
    1: cbw                         200 packets
    2: foo                         220 packets

    Lowest query latency:
    1: foo                         1.00000
    2: cbw                         1.15000</pre>
    which will print out the rank of each group for each performance test, divided into the number
    of packets sent and the query latency. In this particular example, cbw's project has lower
    overhead but answers queries more slowly. Obviously, you would ideally have like to have
	lower latency and fewer total packets sent.
<p></p><p>
</p><h2>Submitting Your Project</h2>
If you have not done so already, register yourself for our grading system using the following command:
<pre>$ /course/cs3700f15/bin/register-student [NUID]</pre>
NUID is your Northeastern ID number, including any leading zeroes.
<p></p><p>
Before turning in your project, you and your partner(s) must register your group. To register yourself
in a group, execute the following script:
</p><pre>$ /course/cs3700f15/bin/register project5 [team name]</pre>
This will either report back success or will give you an error message.  If you have trouble registering,
please contact the course staff. <b>You and your partner(s) must all run this script with the same
[team name]</b>. This is how we know you are part of the same group.
<p></p><p>
To turn-in your project, you should submit your (thoroughly documented) code along with two other files:
</p><ul><li>A Makefile that compiles your code. Your Makefile may be blank, but it must exist.</li>
<li>A plain-text (no Word or PDF) README file. In this file, you should briefly describe your high-level
approach, any challenges you faced, and an overview of how you tested your code.</li>
</ul>
Your README, Makefile, source code, etc. should all be placed in a directory. You submit
your project by running the turn-in script as follows:
<pre>$ /course/cs3700f15/bin/turnin project5 [project directory]</pre>
[project directory] is the name of the directory with your submission. The script will print out every
file that you are submitting, so make sure that it prints out all of the files you wish to submit!
The turn-in script will not accept submissions that are missing a README or a Makefile.
<b>Only one group member needs to submit your project.</b> Your group may submit as many times as you
wish; only the last submission will be graded, and the time of the last submission will determine
whether your assignment is late.
<p></p><p>
</p><h2>Grading</h2>
This project is worth 15% of your final grade. The grading in this project will consist of
<ul>
  <li>75% Program correctness</li>
  <li>10% Performance</li>
  <li>15% Style and documentation</li>
</ul>
At a minimum, your code must pass the test suite without errors or crashes, and it must obey
the requirements specified above. All student code will be scanned by plagarism
detection software to ensure that students are not copying code from the Internet or each other.
<p></p>
</article>
