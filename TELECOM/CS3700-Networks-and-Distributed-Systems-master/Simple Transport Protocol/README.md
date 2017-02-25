<article>
<div class="section_header">CS 3700 - Networks and Distributed Systems</div>
<h2>Project 3: Simple Transport Protocol</h2>
<p>
<b>This project is due at 11:59pm on October 28, 2015.</b>
</p><p>
</p><h2>Description</h2>
You will design a simple transport protocol that provides reliable datagram service. Your protocol
will be responsible for ensuring data is delivered in order, without duplicates, missing data, or
errors. Since the local area networks at Northeastern are far too reliable to be interesting, we will
provide you with access to a machine that will emulate an unreliable network.
<p></p><p>
For the assignment, you will write code that will transfer a file reliably between two
nodes (a sender and a receiver). You do NOT have to implement connection open/close etc. You
may assume that the receiver is run first and will wait indefinitely, and the sender can just send
the data to the receiver.
</p><p>
    </p><h2>Requirements</h2>
    You have to design your own packet format and use UDP as a carrier to transmit packets. Your
    packet might include fields for packet type, acknowledgement number, advertised window, data,
    etc. This part of the assignment is entirely up to you. Your code MUST:
    <ul>
      <li>The sender must accept data from STDIN, sending data until EOF is reached</li>
      <li>The sender and receiver must work together to transmit the data reliably</li>
      <li>The receiver must print out the received data to STDOUT in order and without errors</li>
      <li>The sender and receiver must print out specified debugging messages to STDERR</li>
      <li>Your sender and receiver must gracefully exit</li>
      <li>Your code must be able to transfer a file with any number of packets dropped, damaged,
duplicated, and delayed, and under a variety of different available bandwidths and link
latencies</li>
      <li>Your sending program must be named <i>3700send</i> and your receiving program must be named
      <i>3700recv</i></li>
    </ul>
    You may implement any reliability algorithm(s) you choose. However, more sophisticated algorithms
    (i.e., those which perform better) will be given higher credit. For example, some desired
    properties include (but are not limited to):
    <ul>
      <li>Fast: Require little time to transfer a file.</li>
      <li>Low overhead: Require low data volume to be exchanged over the network, including data
bytes, headers, retransmissions, acknowledgements, etc.</li>
    </ul>
    Regardless, correctness matters most; performance is a secondary concern. We will test your
    code and measure these two performance metrics; better performance will result in higher credit.
    Remember that network-facing code should be written defensively. Your code should check the
    integrity of every packet received. We will test your code by corrupting packets, reordering packets,
    delaying packets, and dropping packets; you should handle these errors gracefully, recover,
    and not crash.
<p></p><p>
    </p><h2>Your Programs</h2>
    For this project, you will submit two programs: a sending program <i>3700send</i> that accepts data and
    sends it across the network, and a receiving program <i>3700recv</i> that receives data and prints it out
    in-order. You may not use any transport protocol libraries in your project (such as TCP); you
    must use UDP. You must construct the packets and acknowledgements yourself, and interpret the
    incoming packets yourself.
<p></p><p>
    </p><h2>Language</h2>
    You can write your code in whatever language you choose, as long as your code compiles and runs
    on <b>unmodified</b> CCIS Linux machines <b>on the command line</b>. Do not use libraries that are not
    installed by default on the CCIS Linux machines.
    You may use IDEs (e.g. Eclipse) during development, but do not turn in your IDE
    project without a Makefile. Make sure you code has <b>no dependencies</b> on your IDE.
<p></p><p>
    </p><h2>Starter Code</h2>
    Very basic starter code in C and Python for the assignment is available in /course/cs3700f15/code/project3.
    You may use this code as a basis for your project, or you may work from scratch. Provided is a
    simple implementation that sends
    one packet at a time; it does not handle any packet retransmissions, delayed packets, or duplicated
    packets. So, it will work if the network is perfectly reliable. Moreover, if the latency is significant,
    the implementation will use very little of the available bandwidth.
    To get started, you should copy down this directory into your own local directory (i.e., cp -r
    /course/cs3700f15/code/project3 ~/). You can compile the code by running <i>make</i>. You can
    also delete any compiled code and object files by running <i>make clean</i>.
<p></p><p>
    </p><h2>Program Specification</h2>
    The command line syntax for your sending is given below. The client program takes command
    line argument of the remote IP address and port number.
    The syntax for launching your sending program is therefore:
    <pre>./3700send &lt;recv_host&gt;:&lt;recv_port&gt;</pre>
    <ul>
      <li>recv_host (Required) The IP address of the remote host in a.b.c.d format.</li>
      <li>recv_port (Required) The UDP port of the remote host.</li>
    </ul>
    To aid in grading and debugging, your sending program should print out messages to the
    console: When a sender sends a packet (including retransmission), it should print the following
    to STDERR:
    <pre>&lt;timestamp&gt; [send data] start (length)</pre>
    where <i>timestamp</i> is a timestamp (down to the microsecond), <i>start</i> is the beginning offset of the
    data sent in the packet, and <i>length</i> is the amount of the data sent in that packet. When your
    3700send receives an acknowledgement, you should also print to STDERR
    <pre>&lt;timestamp&gt; [recv ack] end</pre>
    where <i>end</i> is the last offset that was acknowledged. You may also print some messages of your own
    to indicate timeouts, etc, depending on your design, but make it concise and readable; a function
    <i>mylog(char *fmt, ...)</i> is provided for this purpose.
<p></p><p>
    The command line syntax for your receiving program is given below. The receiving program will
    start up and will bind to a random local port; once bound, it will print out the following to STDERR:
    </p><pre>&lt;timestamp&gt; [bound] port</pre>
    The syntax for launching your receiving program is therefore:
    <pre>./3700recv</pre>
    To aid in grading and debugging, your receiving program should print out messages to STDERR:
    When the receiver receives a valid data packet, it should print
    <pre>&lt;timestamp&gt; [recv data] start (length) status</pre>
    where <i>start</i> is the beginning offset of the data sent in the packet, and <i>length</i> is the amount of the
    data sent in that packet, and <i>status</i> is one of <i>ACCEPTED (in-order)</i>, <i>ACCEPTED (out-of-order)</i>,
    or <i>IGNORED</i>. If a corrupt packet arrives, it should print to STDERR
    <pre>&lt;timestamp&gt; [recv corrupt packet]</pre>
    Similar to 3700send, you may add your own output messages.
<p></p>
    Both the sender and the receiver should print out a message to STDERR after completion of
    file transfer, and then exit:
    <pre>&lt;timestamp&gt; [completed]</pre>
    You should develop your client program on the CCIS Linux machines (ideally <i>cs3600tcp.ccs.neu.edu</i>),
    as these have the necessary compiler and library support. You are welcome to use your own
    Linux/OS X/Windows machines, but you are responsible for getting your code working, and your
    code must work when graded on <i>cs3600tcp.ccs.neu.edu</i>.
<p></p><p>
    </p><h3>Testing Your Code</h3>
    In order for you to test your code over an unreliable network, we have set up a machine that
    will configurably emulate a network that will drop, reorder, damage, duplicate, and delay your
    packets. This machine is part of the CCIS network, and you can log in to it with your CCIS
    username and credentials. If you have any problems accessing the machine, please post on Piazza.
<p></p><p>
    The machine is <i>cs3600tcp.ccs.neu.edu</i>; you should make sure you are able to ssh to the machine
    and run your code on it. You will need to use the loopback interface in order to leverage the
    emulated network. In other words, you might run something like <i>./3700recv</i> in one terminal,
    record the port it local binds to (say, 3992), and then run <i>./3700send 127.0.0.1:3992</i> in another
    terminal.
</p><p>
    You may configure the emulated network conditions by calling the following program:
    </p><pre>/course/cs3700f15/bin/project3/netsim [--bandwidth &lt;bw-in-mbps&gt;]
    [--latency &lt;latency-in-ms&gt;] [--delay &lt;percent&gt;]
    [--drop &lt;percent&gt;] [--reorder &lt;percent&gt;]
    [--corrupt &lt;percent&gt;] [--duplicate &lt;percent&gt;]
</pre>
    <ul>
        <li><b>bandwidth:</b> This sets the bandwidth of the link in Mbit per second. If not specified, this is 1 Mb/s.</li>
        <li><b>latency</b>: This sets the latency of the link in ms. If not specified, this value is 10 ms.</li>
        <li><b>delay</b>: This sets the percent of packets the emulator should delay. If not specified, this is 0.</li>
        <li><b>drop</b>: This sets the percent of packets the emulator should drop. If not specified, this is 0.</li>
        <li><b>reorder</b>: This sets the percent of packets the emulator should reorder. If not specified, this is 0.</li>
        <li><b>corrupt</b>: This sets the percent of packets the emulator should introduce errors into. If not specified, this is 0.</li>
        <li><b>duplicate</b>: This sets the percent of packets the emulator should duplicate. If not specified, this
	  is 0.</li>
    </ul>
    Once you call this program, it will configure the emulator to delay/drop/reorder/mangle/duplicate
    all UDP and ICMP packets sent by or to you at the specified rate. For example, if you called
    <pre>/course/cs3700f15/bin/project3/netsim --bandwidth 0.5 --latency 100 --delay 20 --drop 40</pre>
    the simulator will configure a network with 500 Kb/s bandwidth and a latency of 100 ms, and
    will randomly delay 20% of your packets and drop 40%. In order to reset it so that none of your
    packets are disturbed, you can simply call
    <pre>/course/cs3700f15/bin/project3/netsim</pre>
    with no arguments. Note that the configuration is done on a per-user-account, rather than per-
    group, basis. The simulator is also stateful, meaning your settings will persist across multiple
    sessions.
<p></p><p>
    </p><h3>Helper Script</h3>
    In order to make testing your code easier, we have also included a perl script that will launch your
    receiver, read the port number, launch your sender, feed the sender input, read the output from
    the receiver, compare the two, and print out statistics about the transfer. This script is included
    in the starter code, and you can run it by executing
    <pre>./run</pre>
    This script also takes a couple of arguments to determine what it should do:
    <pre>./run [--size (small|medium|large|huge)] [--printlog] [--timeout <seconds>]</seconds></pre>
    <ul>
        <li><b>size</b>: The size of the data to send, including 1 KB (small), 10 KB (medium), 100 KB (large), MB
(huge). Default is small.</li>
        <li><b>printlog</b>: Instructs the script to print a (sorted) log of the debug output of 3700send and 3700recv.
This may add significant processing time, depending on the amount of output.</li>
        <li><b>timeout</b>: The maximum number of seconds to run the sender and receiver before killing them.
Defaults to 30 seconds.</li>
    </ul>
    The output of this script include some statistics about the transfer:
    <pre>bash$ ./run --size large
Time elapsed: 1734.921 ms
Packets sent: 140
Bytes sent: 107000
Effective goodput: 461.116 Kb/s
Data match: Yes</pre>
    where <i>Data match</i> is whether the data was transferred correctly.
<p></p><p>
    <b>Note</b>: The run script will only work on the <i>cs3600tcp.ccs.neu.edu</i> machine, as it assumes certain
    libraries exist. You should not run the script on other machines.
</p><p>
    </p><h3>Testing Script</h3>
    Additionally, we have included a basic test script that runs your code under a variety of network
    conditions and also check your code's compatibility with the grading script. If your code fails in
    the test script we provide, you can be assured that it will fare poorly when run under the grading
    script. To run the test script, simply type
    <pre>bash$ make test</pre>
    This will compile your code and then test your programs on a number of inputs. If any errors are
    detected, the test will print out the expected and actual output.
<p></p><p>
    <b>Note</b>: The testing script will only work on the <i>cs3600tcp.ccs.neu.edu</i> machine, as it changes the
    network emulation. You should not run the script on other machines.
</p><p>
    </p><h3>Performance Testing</h3>
    15% of your grade on this project will come from performance. Your
    project will be graded against the submissions of your peers. To help you know how you're doing,
    the testing script will also run a series of performance tests at the end; for each test that you
    successfully complete, it will report your time elapsed and bytes sent to a common data base. For
    example, you might see
    <pre>Performance tests
Huge 5Mb/s, 10 ms                       [PASS]
13.889 sec elapsed, 1.1MB sent</pre>
    This indicates that you passed the test in 13.889 seconds and sent a total of 1.1MB of data (including
    retransmissions, overhead, etc). This score will be reported to the common database.
<p></p><p>
    In order to see how your project ranks, you can run
    </p><pre>cbw@cs3600tcp:~$ /course/cs3700f15/bin/project3/printstats
----- TEST: Huge 5Mb/s, 10 ms -----
Quickest:
1:cbw             9.322 sec
2:othergroup      13.889 sec

Most Efficient:
1:othergroup      1.1MB sent
2:cbw             2.8GB sent</pre>
<p></p><p>
    which will print out the rank of each group for each performance test, divided into time spend
    and bytes sent. In this particular example, cbw's project is quicker but has higher overhead.
    Obviously, you would ideally have both lower time and fewer bytes sent.
</p><p>
</p><h2>Submitting Your Project</h2>
If you have not done so already, register yourself for our grading system using the following command:
<pre>$ /course/cs3700f15/bin/register-student [NUID]</pre>
NUID is your Northeastern ID number, including any leading zeroes.
<p></p><p>
Before turning in your project, you and your partner(s) must register your group. To register yourself
in a group, execute the following script:
</p><pre>$ /course/cs3700f15/bin/register project3 [team name]</pre>
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
<pre>$ /course/cs3700f15/bin/turnin project3 [project directory]</pre>
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
  <li>70% Program correctness</li>
  <li>15% Performance</li>
  <li>15% Style and documentation</li>
</ul>
By definition, you are going to be graded on how gracefully you handle errors; your code should
never print out incorrect data. Your code will definitely see corrupted packets, delays, duplicated
packets, and so forth. You should always assume that everyone is trying to break your program.
To paraphrase John F. Woods, "Always code as if the [the remote machine youâ€™re communicating
with] will be a violent psychopath who knows where you live."
<p></p>
</article>
