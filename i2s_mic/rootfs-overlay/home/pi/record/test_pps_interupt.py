#!/usr/bin/env python
#python record21.py -d dmic_sv /home/pi/record/test.raw

from __future__ import print_function
from periphery import GPIO
from datetime import datetime
from datetime import timezone
from datetime import timedelta
LOCAL_TIMEZONE = datetime.now(timezone.utc).astimezone().tzinfo

import os
import sys
import time
import getopt
import alsaaudio
import random


gpio = GPIO("/dev/gpiochip4", 10, "in")
gpio.edge = "rising"
now = datetime.now()
current_time = now.strftime("%H_%M_%S")

while True:
    if gpio.poll(0):
        now = datetime.now()
        current_time = now.strftime("%H_%M_%S")
        current_second = now.strftime("%S")[1]
        gpio.close()
        gpio = GPIO("/dev/gpiochip4", 10, "in")
        gpio.edge = "falling"
        print("Current Time =", current_time)
        time.sleep(.5)

