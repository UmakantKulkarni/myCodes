from socket import *

def main():

	serverPort=8080
	serverSocket = socket(AF_INET, SOCK_STREAM)
	#Prepare a sever socket
	serverSocket.bind(('',serverPort))
	serverSocket.listen(1)
	print 'the web server is up on port:', serverPort
	while True:
	#Establish the connection
		print 'Ready to serve...'
		connectionSocket, addr = serverSocket.accept()
		try:
			message = connectionSocket.recv(1024) 
			print message, '::',message.split()[0],':',message.split()[1]
			filename = message.split()[1]
			print filename,'||',filename[1:]
			f = open(filename[1:])
			outputdata = f.read()
			print outputdata
			connectionSocket.send(outputdata)
			connectionSocket.close()
		except IOError:
			pass
			#Send response message for file not found
			print "404 Not Found"
			connectionSocket.send('\nHTTP/1.1 404 Not Found\n\n')
		break
	pass
if __name__ == '__main__':
  	main()
#Close client socket
