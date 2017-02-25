#!/usr/bin/env python
#Test file written by professor, Christo Wilson

import getpass, os, argparse, atexit
from run import Simulation

# Constants for tuning the difficulty of the tests
PACKETS_LOW = 500
PACKETS_HIGH = 1000
REPLICAS = 5.0
MAYFAIL_LOW = 0.01
MAYFAIL_HIGH = 0.08
LATENCY = 0.05 # In fractions of a second

parser = argparse.ArgumentParser()
parser.add_argument("--config-directory",
                    dest='config_dir',
                    default=None,
                    help='A subdirectory for run configs')
args = parser.parse_args()

sim = None

# Attempt to kill child processes regardless of how Python shuts down (e.g. via an exception or ctrl-C)
@atexit.register
def kill_simulation():
    if sim:
        try: sim.shutdown()
        except: pass

def run_test(filename, description, requests, replicas, mayfail, tolerance, latency, log=None):
    global sim
        
    if args.config_dir: sim = Simulation(os.path.join(args.config_dir, filename))
    else: sim = Simulation(filename)

    sim.run()
    stats = sim.get_stats()    
    sim.shutdown()
    sim = None
        
    pf = 'PASS'
    if stats.incorrect:
        print '\t\tTesting error: >0 incorrect responses to get()'
        pf = 'FAIL'
    elif stats.failed_get > requests * mayfail or stats.failed_put > requests * mayfail:
        print '\t\tTesting error: Too many type=fail responses to client requests'
        pf = 'FAIL'
    elif stats.total_msgs > requests * replicas * 2 * tolerance:
        print '\t\tTesting error: Too many total messages'
        pf = 'FAIL'
    elif stats.mean_latency > latency:
        print '\t\tTesting error: Latency of requests is too high'
        pf = 'FAIL'

    if pf == 'PASS' and log:
        log.write('%s %i %i %i %f %f\n' % (filename, stats.total_msgs, stats.failed_get, stats.failed_put,
                                           stats.mean_latency, stats.median_latency))

    print '\t%-40s\t[%s]' % (description, pf)
    return pf == 'PASS'

trials = []
print 'Basic tests (5 replicas, 30 seconds, 500 requests):'
trials.append(run_test('config-files/simple-1.json', 'No drops, no failures, 80% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.2, LATENCY))
trials.append(run_test('config-files/simple-2.json', 'No drops, no failures, 60% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.2, LATENCY))
trials.append(run_test('config-files/simple-3.json', 'No drops, no failures, 40% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.2, LATENCY))
trials.append(run_test('config-files/simple-4.json', 'No drops, no failures, 20% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.2, LATENCY))

print 'Unreliable network tests (5 replicas, 30 seconds, 500 requests):'
trials.append(run_test('config-files/unreliable-1.json', '10% drops, no failures, 80% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.25, LATENCY))
trials.append(run_test('config-files/unreliable-2.json', '10% drops, no failures, 20% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.25, LATENCY))
trials.append(run_test('config-files/unreliable-3.json', '20% drops, no failures, 80% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.3, LATENCY))
trials.append(run_test('config-files/unreliable-4.json', '20% drops, no failures, 20% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.3, LATENCY))
trials.append(run_test('config-files/unreliable-5.json', '30% drops, no failures, 80% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.35, LATENCY))
trials.append(run_test('config-files/unreliable-6.json', '30% drops, no failures, 20% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.35, LATENCY))

print 'Crash failure tests (5 replicas, 30 seconds, 500 requests):'
trials.append(run_test('config-files/crash-1.json', 'No drops, 1 replica failure, 80% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.3, LATENCY))
trials.append(run_test('config-files/crash-2.json', 'No drops, 1 replica failure, 20% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.3, LATENCY))
trials.append(run_test('config-files/crash-3.json', 'No drops, 2 replica failure, 80% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.3, LATENCY))
trials.append(run_test('config-files/crash-4.json', 'No drops, 2 replica failure, 20% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_LOW, 1.3, LATENCY))
trials.append(run_test('config-files/crash-5.json', 'No drops, 1 leader failure, 80% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_HIGH, 1.3, LATENCY))
trials.append(run_test('config-files/crash-6.json', 'No drops, 1 leader failure, 20% read',
                       PACKETS_LOW, REPLICAS, MAYFAIL_HIGH, 1.3, LATENCY))


print 'Bring the pain (5 replicas, 30 seconds, 1000 requests):'
trials.append(run_test('config-files/advanced-1.json', '20% drops, 2 replica failure, 20% read',
                       PACKETS_HIGH, REPLICAS, MAYFAIL_LOW, 1.3, LATENCY, ldr))
trials.append(run_test('config-files/advanced-2.json', '30% drops, 2 replica failure, 20% read',
                       PACKETS_HIGH, REPLICAS, MAYFAIL_LOW, 1.35, LATENCY, ldr))
trials.append(run_test('config-files/advanced-3.json', '30% drops, 1 leader failure, 20% read',
                       PACKETS_HIGH, REPLICAS, MAYFAIL_HIGH, 1.35, LATENCY, ldr))
trials.append(run_test('config-files/advanced-4.json', '50% drops, 2 leader failure, 20% read',
                       PACKETS_HIGH, REPLICAS, MAYFAIL_HIGH, 1.6, LATENCY, ldr))

print 'Passed', sum([1 for x in trials if x]), 'out of', len(trials), 'tests'
