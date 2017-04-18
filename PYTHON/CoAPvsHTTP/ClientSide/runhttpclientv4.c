#define _BSD_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

void main(){
	
	time_t start, end;
   	double elapsed;  // seconds
	struct timespec t = { 0.00/*seconds*/, 2000000/*nanoseconds*/};
	float c = 0.00;
	int terminate = 1;	
	start = time(NULL);	
	while (terminate){	
		end = time(NULL);
	     	elapsed = difftime(end, start);
	        if (elapsed >= 420.0 /* seconds */)
	    	    terminate = 0;
     	     	else
		 { // No need to sleep when 90.0 seconds elapsed.
			system("curl http://192.168.146.129:4040/Voltage");	
			nanosleep(&t,NULL);			
		}
	}
	system("ps aux | grep run7 | grep -v \"grep run7\" | awk '{print $2}' | xargs kill -9");
}
