#!/usr/bin/env python
import socket
import sys
import os
port = int(sys.argv[1])
host = (sys.argv[2])

s = socket.socket()
s.connect ((host,port))

msg = 'Voltage'
s.send(msg)
while True:
	#s.send(msg)
	data = s.recv(1024)
	if (data == '') or (data[:16] == 'Unknown_Husky_ID'):
		print 'Received from server :' + str(data)
		sys.exit()
		
	elif (data[82:85] == 'BYE') :
		f = data[17:81]
		print 'Secret flag: ' + str(f)
		sys.exit()

	else: 
		print 'Received from server :' + str(data)
		pk = data.split()
		a = int(pk[2])
		b = int(pk[4])
		c = pk[3]
		if c == '+':
			d = a+b
			print (d)
		elif c == '-':
			d = a-b
			print (d)
		elif c == '*':
			d = a*b
			print (d)
		elif c == '/':
			d = a/b
			print (d)
		else :
			break
	
		sol = 'cs5700spring2015 ' + str(d)
		print 'sending data...' + str(sol)
		s.send(sol)

s.close




