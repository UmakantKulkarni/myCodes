#define _BSD_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <time.h>

void main(){
	struct timespec t = { 0.00/*seconds*/, 2000000/*nanoseconds*/};
	float c = 0.00;
	while (c < 301.00){	
		system("curl http://[2001:470:8865:4001:192:168:146:129]:6060/Voltage");	
		nanosleep(&t,NULL);
		c = c + 0.02;
	}
	system("ps aux | grep run6 | grep -v \"grep run6\" | awk '{print $2}' | xargs kill -9");
}
