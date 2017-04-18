#!/usr/bin/python

import getopt
import sys, traceback
import socket
import fcntl
import struct
import threading
import datetime
import time
from coapthon.server.coap import CoAP
from exampleresources import BasicResource, Long, Separate, Storage, Big, Voltage, voidResource, XMLResource, ETAGResource, \
    Child, \
    MultipleEncodingResource, AdvancedResource, AdvancedResourceSeparate

__author__ = 'Giacomo Tanganelli'


class CoAPServer(CoAP):
    def __init__(self, host, port, multicast=False):
	CoAP.__init__(self, (host, port), multicast)
        self.add_resource('basic/', BasicResource())
        self.add_resource('storage/', Storage())
        self.add_resource('separate/', Separate())
        self.add_resource('long/', Long())
        self.add_resource('big/', Big())
	self.add_resource('Voltage/', Voltage())
        self.add_resource('void/', voidResource())
        self.add_resource('xml/', XMLResource())
        self.add_resource('encoding/', MultipleEncodingResource())
        self.add_resource('etag/', ETAGResource())
        self.add_resource('child/', Child())
        self.add_resource('advanced/', AdvancedResource())
        self.add_resource('advancedSeparate/', AdvancedResourceSeparate())

        print "CoAP Server start on " + host + ":" + str(port)
        print self.root.dump()


def usage():  # pragma: no cover
    print "coapserver.py -i <ip address> -p <port>"

def get_ip_address(ifname):
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    return socket.inet_ntoa(fcntl.ioctl(
        s.fileno(),
        0x8915,  # SIOCGIFADDR
        struct.pack('256s', ifname[:15])
    )[20:24])

    
def main(argv):  # pragma: no cover
#    ip = "0.0.0.0"    
    #ip = get_ip_address('ens38')
    ip = "2001:470:8865:4001:192:168:146:129"
    port = 5683
    multicast = False
    try:
        opts, args = getopt.getopt(argv, "hi:p:m", ["ip=", "port=", "multicast"])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            usage(s)
            sys.exit()
        elif opt in ("-i", "--ip"):
            ip = arg
        elif opt in ("-p", "--port"):
            port = int(arg)
        elif opt in ("-m", "--multicast"):
            multicast = True
    
    while True:    
	try:
                server = CoAPServer(ip, port, multicast)
		server.listen(1000)
	except KeyboardInterrupt:
		print "Server Shutdown"
		server.close()
		print "Exiting..."
	
if __name__ == "__main__":  # pragma: no cover
	main(sys.argv[1:])
