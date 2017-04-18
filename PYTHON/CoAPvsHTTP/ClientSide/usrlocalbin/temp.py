#!/usr/bin/python
import getopt
import socket
import sys
import threading
import datetime
import time
import os


os.system('ps aux | grep python | grep -v \"grep python\" | awk \'{print $2}\' | xargs kill -9')
os.system('fuser -n udp -k 5683')
