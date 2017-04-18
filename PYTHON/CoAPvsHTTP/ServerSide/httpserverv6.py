#!/usr/bin/env python
"""
Very simple HTTP server in python.
Usage::
    ./dummy-web-server.py [<port>]
Send a GET request::
    curl http://localhost
Send a HEAD request::
    curl -I http://localhost
Send a POST request::
    curl -d "foo=bar&bin=baz" http://localhost
"""
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServerV6
import SocketServer
import socket 

class S(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_GET(self):
        self._set_headers()
	if (self.path=="/Voltage"):
        	self.wfile.write("49.5 V")
	#print (self.path)

    def do_HEAD(self):
        self._set_headers()
        
    def do_POST(self):
        # Doesn't do anything with posted data
        self._set_headers()
        self.wfile.write("<html><body><h1>POST!</h1></body></html>")

#class HTTPServerV6(HTTPServer):
#  address_family = socket.AF_INET6
        
def run(server_class=HTTPServerV6, handler_class=S, port=6060):
    server_address = ('2001:470:8865:4001:192:168:146:129', port)
    httpd = server_class(server_address, handler_class)
    print '\n'
    print 'Starting httpd...'
    print 'Listening on Port ',port
    print '\n'
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    if len(argv) == 2:
        run(port=int(argv[1]))
    else:
	run()
