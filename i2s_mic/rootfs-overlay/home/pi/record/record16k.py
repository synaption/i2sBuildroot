#!/usr/bin/env python
#python record21.py -d dmic_sv /home/pi/record/test.raw

from __future__ import print_function
from periphery import GPIO
from datetime import datetime
from datetime import timezone
LOCAL_TIMEZONE = datetime.now(timezone.utc).astimezone().tzinfo
import os

import sys
import time
import getopt
import alsaaudio

def usage():
    print('usage: recordtest.py [-d <device>] <file>', file=sys.stderr)
    sys.exit(2)

def read_data_from_device(inp, f):
    # Read data from device
    l, data = inp.read()
    if l:
        f.write(data)
    time.sleep(.001)


def soundframe():
    os.system("sox -r 16000 -e signed-integer -b 32  test1.raw test.wav")
    os.system("sox frame.wav test.wav out.wav")
    os.system("mv out.wav frame.wav")
    
         
        

if __name__ == '__main__':
    os.chdir("/dev/shm")

    device = 'default'

    opts, args = getopt.getopt(sys.argv[1:], 'd:')
    for o, a in opts:
        if o == '-d':
            device = a

    if not args:
        usage()

    f = open(args[0], 'wb')
    inp = alsaaudio.PCM(alsaaudio.PCM_CAPTURE, alsaaudio.PCM_NONBLOCK, 
        channels=1, rate=16000, format=alsaaudio.PCM_FORMAT_S32_LE, 
        periodsize=640, device=device)

    gpio = GPIO("/dev/gpiochip4", 10, "in")
    gpio.edge = "rising"
    os.system("sox -n -r 16000 frame.raw trim 0.0 1.0")
    os.system("sox -r 16000 -e unsigned -b 32  frame.raw frame.wav")
    os.system("rm out.wav")
    os.system("mkdir -p /dev/shm/detect")
    os.system("mkdir -p /dev/shm/past")
    os.system("sudo chmod 777 /dev/shm/detect")
    os.system("sudo chmod 777 /dev/shm/past")    
    now = datetime.now()
    current_time = now.strftime("%H_%M_%S")
    detect_time=current_time 

    while True:
        if gpio.poll(0):
            now = datetime.now()
            current_time = now.strftime("%H_%M_%S")
            current_second = now.strftime("%S")[1]
            gpio.close()
            gpio = GPIO("/dev/gpiochip4", 10, "in")
            gpio.edge = "falling"
            print("Current Time =", current_time)
            if os.path.getsize(args[0]) > 3000:
                print(os.path.getsize(args[0]))
                os.system("mv test.raw test1.raw")
                f = open(args[0], 'wb')
                soundframe()
                detect_time=current_time
        read_data_from_device(inp, f)
        if os.path.getsize("frame.wav") > 550000 and (current_second == "5" or current_second == "0"):
            os.system("mv /dev/shm/detect/* /dev/shm/past/")
            read_data_from_device(inp, f)
            os.system("sox -r 32000 frame.wav /dev/shm/detect/" + detect_time + ".wav")
            read_data_from_device(inp, f)
            #os.system("sox -r 32000 frame.wav /dev/shm/frame32.wav")
            #os.system("sox frame32.wav -r 48000 /dev/shm/detect/" + detect_time + ".wav")
            os.system("sox -n -r 16000 frame.raw trim 0.0 0.0")
            read_data_from_device(inp, f)
            os.system("sox -r 16000 -e unsigned -b 32  frame.raw frame.wav")
            read_data_from_device(inp, f)
