#!/usr/bin/env python
#sudo nice -n -19 sudo -u pi arecord -D dmic_sv -c2 -r 32000 -f S32_LE -t raw -v -F 1000 >> /dev/shm/test.raw
#sudo nice -n -19 sudo -u pi python /home/pi/record/record.py

from periphery import GPIO
from datetime import datetime
from datetime import timezone
LOCAL_TIMEZONE = datetime.now(timezone.utc).astimezone().tzinfo
import os

import sys
import time
import getopt
import random
import subprocess
import shutil
import traceback



def soundframe(detect_time, current_time):
    os.system("ln -sf " + str(current_time) + " test.raw")
    shutil.move(str(detect_time), "test1.raw")
    #os.system("cp test.raw","test1.raw; cp asdfasdf test.raw") #shutil.move("test.raw", "test1.raw")
    subprocess.run(["sox", "-c", "2", "-r", "32000", "-e", "signed-integer", "-b", "32", "test1.raw", "test.wav"])  # convert raw to wav
    subprocess.run(["sox", "test.wav", "test_mono.wav", "remix", "1"])  # make the sound file mono
    subprocess.run(["sox", "frame.wav", "test_mono.wav", "out.wav"])  # concatenate audio
    shutil.move("out.wav", "frame.wav")  # replace old file with new file
    
         
        

if __name__ == '__main__':
    os.chdir("/dev/shm")

    gpio = GPIO("/dev/gpiochip4", 10, "in")
    gpio.edge = "rising"

    os.system("touch /dev/shm/empty; touch /dev/shm/test.wav; touch /dev/shm/test.raw;")
    subprocess.run(["sox", "-n", "-r", "32000", "frame.raw", "trim", "0.0", "0.0"])
    subprocess.run(["sox", "-r", "32000", "-e", "unsigned", "-b", "32", "frame.raw", "frame.wav"])
    subprocess.run(["cp", "frame.wav", "template.wav"])
    subprocess.run(["rm", "out.wav"])
    subprocess.run(["mkdir", "-p", "/dev/shm/detect"])
    subprocess.run(["mkdir", "-p", "/dev/shm/past"])
    subprocess.run(["sudo", "chmod", "777", "/dev/shm/detect"])
    subprocess.run(["sudo", "chmod", "777", "/dev/shm/past"])
    now = datetime.now()
    current_time = now.strftime("%H_%M_%S")
    detect_time=current_time 

    while True:
        try:
            if gpio.poll(0):
                now = datetime.now()
                detect_time=current_time
                current_time = now.strftime("%H_%M_%S")
                current_second = now.strftime("%S")[1]
                gpio.close()
                gpio = GPIO("/dev/gpiochip4", 10, "in")
                gpio.edge = "falling"
                #print("Current Time =", current_time)
                soundframe(detect_time, current_time)
                if os.path.getsize("frame.wav") > 550000 and (current_second == "5" or current_second == "0"):
                    files = os.listdir("/dev/shm/detect/")
                    for file in files:
                        shutil.move("/dev/shm/detect/" + file, "/dev/shm/past/" + file)
                    shutil.move("frame.wav", "/dev/shm/detect/" + detect_time + ".wav")
                    shutil.copy("template.wav", "frame.wav")
            time.sleep(.001)
        except Exception as e:  # Catch the exception and print the traceback
            traceback.print_exc()
            time.sleep(0.5)


