from socket import *
port_server=8080
socket_server = socket(AF_INET, SOCK_STREAM) #Create the socket
socket_server.bind(('',port_server)) #Bind the socket to assigned port and localhost
socket_server.listen(1) #Listen on the specified Port
print 'The Server is listening on the port:', port_server
while True: #Wait for the request to arrive
	print 'Waiting for the request....'
	socket_client, addr = socket_server.accept() #Accept the request from client's socket/Browser
	try: #If Browser requested for the HTML file'
		url = socket_client.recv(1024) #Store it in the url
		file_name = url.split()[1] #Split the URL with whitespace as a delimiter
		p = open(file_name[1:]) #Open the 1st element of the filename
		file_data = p.read() #Read the file and store it in the variable
		socket_client.send(file_data) #Send the file to the Client/Browser
		k = len(file_data.encode('utf-8')) #Measure the length of HTML file in bytes
		socket_client.send('\n\r\n HTTP/1.1 200 OK \r\n') #Send the Status code to the Client
		socket_client.send('\n\r\n Content-Type: text/html \r\n')#Send the Content type to the Client
		socket_client.send('\n\r\n Content-Length: 458 \r\n') #Send the Content Length to the Client
		print 'HTTP/1.1 200 OK' #Display the status code on the server
		print 'Content-Type: text/html' #Display the Content type on the server
		print 'Content-Length: ',k #Display the Content length on the server
		socket_client.close() #Close the Socket
	except: # If Browser has requested for any other file
		print "404 Not Found" #Print the error response on the Terminal window
		socket_client.send('\n\r 404 Not Found\r\n') #Send the error response to the Browser
	break #Serve the client's request only for one time
