<article>
<div class="section_header">CS 3700 - Networks and Distributed Systems</div>
<h2>Project 2: Simple Bridge</h2>
<p>
<b>This project is due at 11:59pm on October 7, 2015.</b>
</p><p>
</p><h2>Description</h2>
You will implement a simple bridge that is able to establish a spanning tree and forward frames
between its various ports. Since running your bridge on Northeastern's network would likely
impact real traffic, we will provide you with a simulation environment that emulates LANs and
end hosts. Your bridges must construct a spanning tree (and disable any ports that are not part
of the tree), must forward frames between these ports, learn the locations (ports) of hosts, and
handle both bridge and port failures (e.g., by automatically reconfiguring the spanning tree).
<p></p><p>
Your bridges will be tested for both correctness and performance. Part of your grade will come
from the overhead your network has (i.e., lower overhead incurs a higher score) and the fraction
of packets that are successfully delivered between end hosts. Your results will be compared to
your classmates' via a leaderboard.
</p><p>
</p><h2>Language</h2>
You can write your code in whatever language you choose, as long as your code compiles and runs
on <b>unmodified</b> CCIS Linux machines <b>on the command line</b>. Do not use libraries that are not
installed by default on the CCIS Linux machines. Similarly, your code must compile and run on the
command line. You may use IDEs (e.g. Eclipse) during development, but do not turn in your IDE
project without a Makefile. Make sure you code has <b>no dependencies</b> on your IDE.
<p></p><p>
    </p><h2>Requirements</h2>
    To simplify the project, instead of using real packet formats, we will be sending our data across
    the wire in JSON (many languages have utilities to encode and decode JSON, and you are welcome
    to use these libraries). Your bridge program must meet the following requirements:
    <ul>
      <li>Form a spanning tree in order to prevent packet loops</li>
      <li>Handle the failure of bridges, the failure of bridge ports, and the introduction of new bridges
      and LANs over time</li>
      <li>Learn the locations of end hosts</li>
      <li>Deliver end host packets to the destination</li>
      <li>Handle the mobility of end hosts between LANs</li>
      <li>Senders and receivers must print out specified debugging messages to STDOUT</li>
      <li>Your program must be called <i>3700bridge</i></li>
    </ul>
    You should implement a simplified version of the standard bridge spanning tree protocol that
    we discussed in class. Note that more sophisticated and properly tuned algorithms (i.e., those
    which perform better) will be given higher credit. For example, some desired properties include
    (but are not limited to):
    <ul>
      <li>Fast convergence: Require little time to form a spanning tree.</li>
      <li>Low overhead: Reduce packet flooding when possible.</li>
    </ul>
    Regardless, correctness matters most; performance is a secondary concern. We will test your
    code and measure these two performance metrics; better performance will result in higher credit.
    We will test your code by introducing a variety of different errors and failures; you should handle
    these errors gracefully, recover, and never crash.
<p></p><p>
    </p><h2>Your Program</h2>
    For this project, you will submit one program named <b>3700bridge</b> that implements a bridge.
    You may use any language of your choice, and we will give you basic starter code for perl and python. You
    may not use any bridging libraries in your project; you must implement all of the bridge logic
    yourself.
<p></p><p>
    If you use C or any other compiled language, your executable should be named 3700bridge.
    If you use an interpreted language, your script should be called 3700bridge and be marked as
    executable. If you use a virtual machine-based language (like Java or C#), you must write a brief
    Bash shell script, named 3700bridge, that conforms to the input syntax above and then launches
    your program using whatever incantations are necessary. For example, if you write your solution
    in Java, your Bash script might resemble
    </p><pre>      #!/usr/bin/perl -w
      $args = join(' ', @ARGV);
      print 'java -jar 3700bridge.jar $args';</pre>
    Or, if you use python, your script might start with
    <pre>      #!/usr/bin/python
      import foo from bar</pre>
    and should be marked executable.
<p></p><p>
    </p><h2>Starter Code</h2>
    Very basic starter code for the assignment in perl and python is available in /course/cs3700f15/code/project2.
    The starter code provides a bare-bones implementation of a bridge that simply connects to the LANs and broadcasts
    a "Hello world!" message twice every second. You may use this code as a basis for your project if
    you wish, but it is strongly recommended that you do not do so unless you are very comfortable
    with perl or python. To get started, you should copy this directory into your own local directory (i.e.,
    cp -r /course/cs3700f15/code/project2 ~/), since you will need the <i>run</i> and <i>test</i> scripts,
    as well as the example configuration files.
<p></p><p>
    </p><h2>Program Specification</h2>
    The command line syntax for your bridge is given below. The bridge program takes command
    line arguments representing (1) the ID of the bridge, and (2) the LAN or LANs that it should connect
    to. The bridge must be connected to at least one LAN. The syntax for launching your bridge is
    therefore:
    <pre>./3700bridge &lt;id&gt; &lt;LAN&gt; [LAN [LAN ...]]</pre>
    <ul>
      <li>id (Required) The id of the bridge. For simplicity, all bridge ids are four-digit hexadecimal numbers
	(e.g., 0aa1 or f29a).</li>
      <li>LAN (Required) The unique name of the LAN(s) the bridge should connect to. The LANs are
      named using unique ASCII strings; the names themselves are not meaningful.</li>
    </ul>
<p></p><p>
    </p><h3>BPDU Messages</h3>
    You should configure your bridges to periodically broadcast BPDUs on all ports. You should
    broadcast BPDUs no more frequently than once every 500 ms. Using those BPDUs, you should
    constantly be listening for new roots, new bridges, etc, and should make decisions about which
    ports are active and inactive upon receiving each BPDU. Additionally, you should "timeout" BPDUs
    after 750 ms. To aid in grading and debugging, your bridge program should print out messages
    about the spanning tree calculation to STDOUT. When starting up, your bridge should print
    out
    <pre>Bridge &lt;id&gt; starting up</pre>
    where &lt;id&gt; is the ID of the bridge. When your bridge selects a new root, it should print out
    <pre>New root: &lt;id&gt;/&lt;root&gt;</pre>
    where &lt;id&gt; is the ID of the local bridge and &lt;root&gt; is the ID of the new root. When your bridge
    changes its root port, it should print out
    <pre>Root port: &lt;id&gt;/&lt;port_id&gt;</pre>
    where &lt;port_id&gt; is the port number (0-indexed). When your bridge decides that a port is
    the designated port for a LAN, it should print out:
    <pre>Designated port: &lt;id&gt;/&lt;port_id&gt;</pre>
    Finally, when your bridge decides that a port should be disabled, it should print out:
    <pre>Disabled port: &lt;id&gt;/&lt;port_id&gt;</pre>
<p></p><p>
    </p><h3>Data Messages</h3>
    Additionally, your bridge should build up a forwarding table as discussed in class. You should
    "timeout" forwarding table entries 5 seconds after receiving the last message from that address.
    When any of your bridge's ports changes state (designated, root, etc), you should flush your forwarding
    table. When forwarding data packets, your bridge program should print out the following messages to
    STDOUT. When your bridge receives a message on an active port (i.e., not
    disabled), it should print out
    <pre>Received message &lt;id&gt; on port &lt;port_id&gt; from &lt;source&gt; to &lt;dest&gt;</pre>
    where &lt;id&gt; is the unique identifier of the data message, &lt;port_id&gt; is the port number on the
    bridge that the message was received on, and &lt;source&gt; and &lt;dest&gt; are the source and destination
    of the message. (Note that your bridge should silently ignore all messages [other than BPDUs] on
    disabled ports) Once your bridge makes a forwarding decision about the message, it should print
    out one of three messages:
    <pre>Forwarding message &lt;id&gt; to port &lt;port_id&gt;</pre>
    or
    <pre>Broadcasting message &lt;id&gt; to all ports</pre>
    or
    <pre>Not forwarding message &lt;id&gt;</pre>
    Thus, every non-BPDU message your bridge receives on an active port should have one of the
    above three lines printed out. This will help you to debug why your bridges are misrouting messages
    (if this should ever occur).
<p></p><p>
    </p><h3>Packet Format</h3>
    In order to simplify the development and debugging of this project, we use JSON (JavaScript Object
    Notation) to format all messages sent on the wire. Many common programming languages
    have built-in support for encode and decoding JSON messages, and you should use these when
    sending and receiving messages (i.e., you do not have to create or parse JSON messages yourself).
    The format of all messages is
    <pre>{"source":"&lt;source&gt;", "dest":"&lt;destination&gt;", "type":"&lt;type&gt;", "message":{<message>}}</message></pre>
    where &lt;source&gt; and &lt;destination&gt; are either bridge or end host addresses. Recall that all
    addresses are four-byte hexadecimal numbers (e.g., 98a2), and a special broadcast address ffff
    indicates the packet should be received by all hosts and bridges. Additionally, &lt;message&gt; should
    be the JSON-encoded message itself, and &lt;type&gt; is either 'bpdu' for BPDUs or 'data' for end-host data
    packets. For example, a BPDU that you send from bridge 02a1 might look like
    <pre>{"source":"02a1", "dest":"ffff", "type": "bpdu",
      "message":{"id":"92b4", "root":"02a1", "cost":3, "port":2}}</pre>
    All data packets will include a unique id field that you should use refer to that message. For
    example, a data message from host 28aa to 97bf might look like
    <pre>{"source":"28aa", "dest":"97bf", "type": "data", "message":{"id": 17}}</pre>
<p></p><p>
    </p><h3>Connecting to the LAN</h3>
    We will be using UNIX domain sockets to emulate the LANs, with one domain socket per LAN
    that your bridge is connected to. You do not need to be intimately familiar with how these work,
    but they essentially give you a socket-like device that you can read and write from. Whenever you
    write to it, all other end hosts and bridges on that LAN will receive your message. You should
    constantly be reading from it to make sure you receive all messages (they will be buffered if you
    don't read immediately).
<p></p><p>
    One thing to note is that we will be using abstract domain sockets, which means that you should
    put a \0 byte before the LAN name when you are connecting to the socket. So, if you were trying
    to connect to the LAN named LAN#cbw#1, the name that you would actually connect to is
    \0LAN#cbw#1. We will be using the SOCK_SEQPACKET socket type, which basically provides
    a reliable message-oriented stream.
</p><p>
    Exactly how to connect to a UNIX domain socket depends on your programming language.
    For example, if you were using perl to complete the project, your code for connecting would look
    like:
    </p><pre>use IO::Socket::UNIX;

my $lan = IO::Socket::UNIX-&gt;new(
    Type =&gt; SOCK_SEQPACKET,
    Peer =&gt; "\0&lt;lan&gt;"
);</pre>
    where &lt;lan&gt; is the name of the LAN that is passed in on the command line. You can then read
    and write from the $lan variable. In python, your code would look like
    <pre>from socket import socket, SOCK_SEQPACKET, AF_UNIX
s = socket (AF_UNIX, SOCK_SEQPACKET)
s.connect ('\0&lt;lan&gt;')</pre>
    with similar results.
<p></p><p>
    We encourage you to write your code in an event-driven style using select() or poll()
    on all of the LANs that your bridge is connected to. This will keep your code single-threaded and
    will make debugging your code significantly easier. Alternatively, you can implement your bridge
    in a threaded model (with one thread attached to each LAN), but expect it to be significantly more
    difficult to debug.
</p><p>
    </p><h2>Testing Your Code</h2>
    In order for you to test your code in our network simulator, we have included a perl script that will
    create the emulated LANs, run your bridge program and connect it to these LANs, start and stop
    your bridges in a configurable way, and create and record end host traffic. This script is included
    in the starter code, and you can run it by executing
    <pre>./run &lt;config-file&gt;</pre>
    where &lt;config-file&gt; is the configuration file that describes the network you would like to implement.
    Note that you do not need to parse the config files yourself; the run script does this. Instead,
    you can create custom configs to test your code under different scenarios.
<p></p><p>
    </p><h3>Config File Format</h3>
    The configuration file that you specify describes the LANs, the bridges, and the connections between
    these. It also contains information about when bridge come up and down, and the end host
    traffic that should be generated. The file is formatted in JSON and has the following elements
    <ul>
      <li>lifetime (Required) The number of seconds the simulation should run for.</li>
      <li>bridges (Required) An array of bridge elements (described below). At least one bridge must be
	specified. Each bridge element is an associative array that has the following properties:
	<ul>
	  <li>id (Required) The ID of the bridge, a string.</li>
	  <li>lans (Required) An array of the LAN IDs that the bridge is connected to. All LANs are
	  identified by a non-negative number.</li>
	  <li>start (Optional) The start time (in seconds) when the bridge should be turned on. If not
	  specified, the bridge is started at the beginning of the simulation.</li>
	  <li>stop (Optional) The stop time (in seconds) when the bridge should be turned off. If not
	  specified, the bridge is stopped at the end of the simulation.</li>
	</ul>
      </li>
      <li>hosts (Required) The number of hosts to generate (these are randomly attached to LANs).</li>
      <li>traffic (Required) The number of end host packets to randomly generate (these are sent with
      randomly selected sources and destinations).</li>
      <li>wait (Optional) The number of seconds to wait before sending any data traffic (default of 2
	seconds).</li>
      <li>seed (Optional) The random seed to choose. If not specified, a random value is chosen. Setting
      this value will allow for a reproducible set of hosts and traffic.</li>
    </ul>
    For example, a simple network with two LANs connected by a single bridge would be:
    <pre>      {
          "lifetime": 30,
          "bridges": [{"id": "A", "lans": [1, 2]}],
          "hosts": 10,
          "traffic": 1000
      }</pre>
    and a more complex network may be
    <pre>      {
          "lifetime": 30,
          "bridges": [{"id": "A", "lans": [1, 3]},
                      {"id": "B", "lans": [2, 3], "stop": 7},
                      {"id": "C", "lans": [1, 2], "start": 5, "stop": 9},
                      {"id": "D", "lans": [2, 4]},
                      {"id": "E", "lans": [2, 4, 5, 6]}]
          "hosts": 100,
          "traffic": 10000
      }</pre>
<p></p><p>
    </p><h3>./run Output</h3>
    The output of the ./run script includes timestamps and all logging information from your bridges
    and the emulated end hosts. Note that all data traffic will be delayed for 2 seconds at the beginning
    of the simulation to allow your bridges to form an initial spanning tree. At the end, the output
    also includes some statistics about the your bridges' performance:
    <pre>    bash$ ./run config.json
    ...
    [ 14.9990
    Host ed10] Sent message 776 to 41c1
    [ 15.0001 Bridge 92ba] Received message 776 on port 0 from ed10 to 41c1
    Simulation finished.
    Total packets sent: 6730
    Total data packets sent: 2000
    Total data packets received: 1984
    Total data packets dropped: 16 (message ids 52, 70, 181, 320, 517, 571, 634, 776, 900, 1111, 1242, 1501, 1517, 1588, 1685, 1887)
    Total data packets duplicated: 17 (message ids 311, 433, 541, 630, 632, 658, 717, 804, 998, 1022, 1341, 1364, 1433, 1611, 1668, 1804, 1876)
    Data packet delivery ratio: 0.992000</pre>
    Each of the fields is self-explanatory. Ideally, you would like all messages to be delivered (a delivery
    ratio of 1.0) and the number of packets dropped and duplicated to be 0 (a message can cause
    two packets to be delivered if the network is being re-configured when it is sent). Additionally,
    you want the number of total packets sent to be low as well (this includes BPDUs, which are
    overhead).
<p></p><p>
    </p><h3>Testing Script</h3>
    Additionally, we have included a basic test script that runs your code under a variety of different
    network configurations and also checks your code's compatibility with the grading script. If your
    code fails in the test script we provide, you can be assured that it will fare poorly when run under
    the grading script. To run the test script, simply type
    <pre>    bash$ ./test
    Basic (no failures, no new bridges) tests (PDR = 1.0)
      One bridge, one LAN                                    [PASS]
      One bridge, two LANs                                   [PASS]
      One bridge, three LANs                                 [PASS]
      Two bridges, one LAN                                   [PASS]
      Two bridges, two LANs                                  [PASS]</pre>
    This will run your code on a number of configurations, and will output whether your program
    performs sufficiently. If you wish to run one of the tests manually, you can do so with
    <pre>bash$ ./run basic-4.conf</pre>
<p></p><p>
    </p><h3>Performance Testing</h3>
    As mentioned in class, 10% of your grade on this project will come from performance. Your
    project will be graded against the submissions of your peers. To help you know how you're doing,
    the testing script will also run a series of performance tests at the end; for each test that you
    successfully complete, it will report your time elapsed and bytes sent to a common database. For
    example, you might see
    <pre>    Performance tests
      Network 1                                        [PASS]
       99.1% packets delivered, 3.0% overhead</pre>
    This indicates that you successfully delivered 99.1% of all end-host packets and had an overhead
    of 3%. This score will be reported to the common database. Note that, by default, only reasonable
    scores are sent to the database; if your scores aren't showing up, that means you need to improve
    your performance.
<p></p><p>
    In order to see how your project ranks, you can run
    </p><pre>    bash$ /course/cs3700f15/bin/project2/printstats
    ----- TEST: Eight bridges, eight LANs -----
    Least overhead:
    1: cbw                         200 packets
    2: foo                         220 packets

    Highest delivery ratio:
    1: foo                         1.00000
    2: cbw                         0.950000</pre>
    which will print out the rank of each group for each performance test, divided into the number
    of packets sent and the delivery ratio. In this particular example, cbw's project has lower
    overhead but delivers fewer of the packets. Obviously, you would ideally have like to have more packets
    delivered and fewer packets sent.
<p></p><p>
</p><h2>Submitting Your Project</h2>
If you have not done so already, register yourself for our grading system using the following command:
<pre>$ /course/cs3700f15/bin/register-student [NUID]</pre>
NUID is your Northeastern ID number, including any leading zeroes.
<p></p><p>
Before turning in your project, you and your partner(s) must register your group. To register yourself
in a group, execute the following script:
</p><pre>$ /course/cs3700f15/bin/register project2 [team name]</pre>
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
<pre>$ /course/cs3700f15/bin/turnin project2 [project directory]</pre>
[project directory] is the name of the directory with your submission. The script will print out every
file that you are submitting, so make sure that it prints out all of the files you wish to submit!
The turn-in script will not accept submissions that are missing a README or a Makefile.
<b>Only one group member needs to submit your project.</b> Your group may submit as many times as you
wish; only the last submission will be graded, and the time of the last submission will determine
whether your assignment is late.
<p></p><p>
</p><h2>Grading</h2>
This project is worth 12% of your final grade. The grading in this project will consist of
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
