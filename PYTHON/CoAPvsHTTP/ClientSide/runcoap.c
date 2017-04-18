#define _BSD_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

void main(){
	
	time_t start, end;
   	double elapsed;  // seconds
	struct timespec t = { 0.00/*seconds*/, 200000/*nanoseconds*/};
	float c = 0.00;
	int terminate = 1;	
	start = time(NULL);	
	while (terminate){	
		end = time(NULL);
	     	elapsed = difftime(end, start);
	        if (elapsed >= 6.0 /* seconds */)
	    	    terminate = 0;
     	     	else
		 { // No need to sleep when 90.0 seconds elapsed.
			system("coapclient.py -o GET -p coap://[2001:470:8865:4001:192:168:146:129]:5683/Voltage 420");	
			nanosleep(&t,NULL);			
			system ("fuser -n udp -k 5683");
			system("ps aux | grep python | grep -v \"grep python\" | awk '{print $2}' | xargs kill -9");
		}
	}
	system ("fuser -n udp -k 5683");
	system("ps aux | grep python | grep -v \"grep python\" | awk '{print $2}' | xargs kill -9");
}
