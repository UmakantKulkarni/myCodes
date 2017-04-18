#define _BSD_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

void main(){
		
	system("fuser -n udp -k 5683");	
	system("ps aux | grep python | grep -v \"grep python\" | awk '{print $2}' | xargs kill -9");	
	system("sh -x runserver.sh & sh -x run5.sh");
	sleep(4);
	system("fuser -n udp -k 5683");	
	system("ps aux | grep python | grep -v \"grep python\" | awk '{print $2}' | xargs kill -9");	
		
}
