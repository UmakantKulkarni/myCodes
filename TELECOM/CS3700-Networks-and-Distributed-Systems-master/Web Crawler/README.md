<article>
<div class="section_header">CS 3700 - Networks and Distributed Systems</div>
<h2>Project 4: Web Crawler</h2>
<p>
<b>This project is due at 11:59pm on November 12, 2015.</b>
</p><p>
</p><h2>Description</h2>
This assignment is intended to familiarize you with the HTTP protocol. HTTP is (arguably)
the most important application level protocol on the Internet today: the Web runs on HTTP,
and increasingly other applications use HTTP as well (including Bittorrent, streaming video,
Facebook and Twitter's social APIs, etc.).
<p></p>
Your goal in this assignment is to implement a web crawler that gathers data from a fake
social networking website that we have set up for you. The site is available here:
<a href="http://fring.ccs.neu.edu/">Fakebook</a>.
<p></p><p>
</p><h2>What is a Web Crawler?</h2>
A web crawler (sometimes known as a robot, a spider, or a screen scraper) is a piece of
software that automatically gathers and traverses documents on the web. For example,
lets say you have a crawler and you tell it to start at www.wikipedia.com. The software
will first download the Wikipedia homepage, then it will parse the HTML and locate all
hyperlinks (i.e. anchor tags) embedded in the page. The crawler then downloads
all the HTML pages specified by the URLs on the homepage, and parses them looking for more
hyperlinks. This process continues until all of the pages on Wikipedia are downloaded and
parsed.
<p></p><p>
Web crawlers are a fundamental component of today's web. For example, Googlebot is Google's
web crawler. Googlebot is constantly scouring the web, downloading pages in search of new
and updated content. All of this data forms the backbone of Google's search engine infrastructure.
</p><p>
</p><h2>Fakebook</h2>
We have set up a fake social network for this project called <a href="http://fring.ccs.neu.edu/">Fakebook</a>.
Fakebook is a very
simple website that consists of the following pages:
<ul><li><b>Homepage</b>: The Fakebook homepage displays some welcome text, as well as links
to several random Fakebook users' personal profiles.</li>
<li><b>Personal Profiles</b>: Each Fakebook user has a profile page that includes their
name, some basic demographic information, as well as a link to their list of friends.</li>
<li><b>Friends List</b>: Each Fakebook user is friends with one or more other Fakebook
users. This page lists the user's friends and has links to their personal profiles.</li>
</ul>
In order to browse Fakebook, you must first login with a username and password. We will email
each student to give them a unique username and password.
<p></p><p>
</p><h2>WARNING: DO NOT TEST YOUR CRAWLERS ON PUBLIC WEBSITES</h2>
Many web server administrators view crawlers as a nuisance, and they get very mad if
they see strange crawlers traversing their sites. <b>Only test your crawler against
Fakebook, do not test it against any other websites</b>.
<p></p><p>
</p><h2>High Level Requirements</h2>
Your goal is to collect 5 <i>secret flags</i> that have been hidden somewhere on the Fakebook website.
The flags are unique for each student, and the pages that contain the flags will be different for each student.
Since you have no idea what pages the secret flags will appear on, and the Fakebook site is very large (tens of
thousands of pages), your only option is to write a web
crawler that will traverse Fakebook and locate your flags. 
<p></p><p>
Your web crawler must execute on the command line using the following syntax:
</p><p>
./webcrawler [username] [password]
</p><p>
<i>username</i> and <i>password</i> are used by your crawler to log-in to Fakebook. You may assume
that the root page for Fakebook is available at <a href="http://fring.ccs.neu.edu/fakebook/">
http://fring.ccs.neu.edu/fakebook/</a>. You may also assume that the log-in form for Fakebook is available
at <a href="http://fring.ccs.neu.edu/accounts/login/?next=/fakebook/">
http://fring.ccs.neu.edu/accounts/login/?next=/fakebook/</a>.
</p><p>
Your web crawler should print <b>exactly fives lines of output</b>: the five <i>secret flags</i> discovered
during the crawl of Fakebook. If your program encounters an unrecoverable error, it may print an error
message before terminating.
</p><p>
Secret flags may be hidden on any page on Fakebook, and their exact location on each page may be different.
Each secret flag is a 64 character long sequences of random alphanumerics.
All secret flags will appear in the following format (which makes them easy to identify):
</p><p>
&lt;h2 class='secret_flag' style="color:red"&gt;FLAG: 64-characters-of-random-alphanumerics&lt;/h2&gt;
</p><p>
</p><h2>HTTP and (Il)Legal Libraries</h2>
Part of the challenge of this assignment is that <b>all HTTP request and response code must be written by the
  student, from scratch</b>. In other words, you need to implement the ability to send HTTP/1.1 messages, and parse
HTTP responses. Students may use any available libraries to create socket connections, parse URLs,
and parse HTML. However, you may not use <b>any</b> libraries/modules/etc. that implement HTTP or manage cookies
for you.
<p></p><p>
For example, if you were to write your crawler in Python, the following modules would
all be allowed: <i>socket</i>, <i>parseurl</i>, <i>html</i>, <i>html.parse</i>, and <i>xml</i>.
However, the following modules would <b>not</b> be allowed: <i>urllib</i>, <i>urllib2</i>,
<i>httplib</i>, <i>requests</i>, <i>pycurl</i>, and <i>cookielib</i>.
</p><p>
Similarly, if you were to write your crawler in Java, it would <b>not be legal</b> to use <i>java.net.CookieHandler</i>,
<i>java.net.CookieManager</i>, <i>java.net.HttpCookie</i>, <i>java.net.HttpUrlConnection</i>, <i>java.net.URLConnection</i>,
<i>URL.openConnection()</i>, <i>URL.openStream()</i>, or <i>URL.getContent()</i>. 
</p><p>
If students have any questions about the legality of any libraries please post them to Piazza.
It is much safer to ask ahead of time, rather than turn in code that uses a questionable
library and receive points off for the assignment after the fact. 
</p><p>
</p><h2>Implementation Details and Hints</h2>
In this assignment, your crawler must implement HTTP/1.1 (not 0.9 or 1.0). This means that there are certain
HTTP headers like <i>Host</i> that you must include in your requests (i.e. they are required for all HTTP/1.1
requests). We encourage you to implement <i>Connection: Keep-Alive</i> (i.e. pipelining) to improve your
crawlers performance (and lighten the load on our server), but this is not requiring, and it is tricky to get
correct. We also encourage students to implement <i>Accept-Encoding: gzip</i> (i.e. compressed HTTP responses),
since this will also improve performance for everyone, but this is also not required. If you want to get really
crazy, you can definitely speed up your crawler by using multithreading or multiprocessing, but again this is
not required functionality.
<p></p><p>
One of the key differences between HTTP/1.0 and HTTP/1.1 is that the latter supports <i>chunked encoding</i>.    
HTTP/1.1 servers may break up large responses into chunks, and it is the client's responsibility to reconstruct
the data by combining the chunks. Our server may return chunked responses, which means your client must be able
to reconstruct them. To aid in debugging, you might consider using HTTP/1.0 for your initial implementation; once
you have a working 1.0 implementation, you can switch to 1.1 and add support for chunked responses.
</p><p>
In order to build a successful web crawler, you will need to handle several different aspects of the HTTP
protocol:
</p><ul><li>HTTP GET - These requests are necessary for downloading HTML pages.</li>
<li>HTTP POST - You will need to implement HTTP POST so that your code can login to Fakebook. As
shown above, you will pass a 
username and password to your crawler on the command line. The crawler will then use
these values as parameters in an HTTP POST in order to log-in to Fakebook.</li>
<li>Cookie Management - Fakebook uses cookies to track whether clients are logged in to the site. If
your crawler successfully logs in to Fakebook using an HTTP POST,
Fakebook will return a session cookie to your crawler. Your crawler should
store this cookie, and submit it along with each HTTP GET request as it crawls Fakebook.
If your crawler fails to handle cookies properly, then your software will not be able
  to successfully crawl Fakebook.</li>
</ul>
<p></p><p>
In addition to crawling Fakebook, your web crawler must be able to correctly handle <a href="http://en.wikipedia.org/wiki/List_of_HTTP_status_codes">HTTP status codes</a>. Obviously, you need to handle 200, since that means
everything is okay. Your code must also handle:
</p><ul>
<li>301 - Moved Permanently: This is known as an HTTP redirect. Your crawler should try the request 
again using the new URL given by the server in the <i>Location</i> header.</li>
<li>403 - Forbidden and 404 - Not Found: Our web server may return these codes in order to trip up your
crawler. In this case, your crawler should abandon the URL that generated the error code.</li>
<li>500 - Internal Server Error: Our web server may <b>randomly</b> return this error code to your
crawler. In this case, your crawler should re-try the request for the URL until the request is
successful.</li>
</ul>
<p></p><p>
I highly recommend the <a href="http://www.jmarshall.com/easy/http/">HTTP Made Really Easy</a>
tutorial as a starting place for students to learn about the HTTP protocol. Furthermore, the
developer tools built-in to Chrome and Firefox are both excellent for inspecting and understanding
HTTP requests.
</p><p>
In addition to HTTP-specific issues, there are a few key things that all web crawlers must do in order function:
</p><ul>
<li><b>Track the Frontier</b>: As your crawler traverses Fakebook it will observe many URLs.
Typically, these uncrawled URLs are stored in a queue, stack, or list until the crawler is 
ready to visit them.  These uncrawled URLs are known as the frontier.</li>
<li><b>Watch Out for Loops</b>: Your crawler needs to keep track of where it has been, i.e. the
URLs that it has already crawled. Obviously, it isn't efficient to revisit the same pages over
and over again. If your crawler does not keep track of where it has been, it will almost
certainly enter an infinite loop. For example, if users A and B are friends on Fakebook, then that
means A's page links to B, and B's page links to A. Unless the crawler is smart, it will ping-pong
back and forth going A-&gt;B, B-&gt;A, A-&gt;B, B-&gt;A, ..., etc.</li>
<li><b>Only Crawl The Target Domain</b>: Web pages may include links that point to arbitrary
domains (e.g. a link on google.com that points to cnn.com). <b>Your crawler should only traverse
URLs that point to pages on fring.ccs.neu.edu</b>. For example, it would be valid to crawl
<i>http://fring.ccs.neu.edu/fakebook/018912/</i>, but it would not be valid to crawl
<i>http://www.facebook.com/018912/</i>. Your code should check to make sure that each URL has
a valid domain (i.e. the domain is fring.ccs.neu.edu) before you attempt to visit it.
</li></ul>
<p></p><p>
</p><h2>Logging in to Fakebook</h2>
In order to write code that can successfully log-in to Fakebook, you will need to
reverse engineer the HTML form on the log-in page. <b>Students should carefully inspect
  the form's code, since it may not be as simple as it initially appears.</b> The key acronym
you should be on the lookout for is <i>CSRF</i>.
<p></p><p>
</p><h2>Language</h2>
<p></p><p>
You can write your code in whatever language you choose, as long as your code compiles and runs
on <b>unmodified</b> CCIS Linux machines <b>on the command line</b>. Do not use libraries that are not
installed by default on the CCIS Linux machines, or that are disallowed for this project. You may use IDEs
(e.g. Eclipse) during development, but do not turn in your IDE
project without a Makefile. Make sure you code has <b>no dependencies</b> on your IDE.
</p><p>
</p><h2>Submitting Your Project</h2>
Before turning in your project, you and your partner(s) must register your group. To register yourself
in a group, execute the following script:
<pre>$ /course/cs3700f15/bin/register project4 [team name]</pre>
This will either report back success or will give you an error message.  If you have trouble registering,
please contact the course staff. <b>You and your partner(s) must all run this script with the same 
[team name]</b>. This is how we know you are part of the same group.
<p></p><p>
To turn-in your project, you should submit your (thoroughly documented) code along with three other files:
</p><ul><li>A Makefile that compiles your code.</li>
<li>A plain-text (no Word or PDF) README file. In this file, you should briefly describe your high-level
approach, any challenges you faced, and an overview of how you tested your code.</li>
<li>A file called <i>secret_flags</i>. This file should contain the <i>secret flags</i> of all group
members, one per line, in plain ASCII. For example, a group of two should have a file with exactly ten lines in it.</li>
</ul>
Your README, Makefile, secret_flags file, source code, etc. should all be placed in a directory. You submit
your project by running the turn-in script as follows:
<pre>$ /course/cs3700f15/bin/turnin project4 [project directory]</pre>
[project directory] is the name of the directory with your submission. The script will print out every
file that you are submitting, so make sure that it prints out all of the files you wish to submit!
The turn-in script will not accept submissions that are missing a README, a Makefile, or a secret_flags
file. <b>Only one group member needs to submit your project.</b> Your group may submit as many times as you
wish; only the last submission will be graded, and the time of the last submission will determine
whether your assignment is late.
<p></p><p>
</p><h2>Grading</h2>
This project is worth 8 points. You will receive full credit if 1) your code compiles, runs, and produces the
expected output, 2) you have not used any illegal libraries, and 3) you successfully submit the
<i>secret flags</i> of all group members. All student code will be scanned by plagarism
detection software to ensure that students are not copying code from the Internet or each other.
<p></p><p>
</p></article>
