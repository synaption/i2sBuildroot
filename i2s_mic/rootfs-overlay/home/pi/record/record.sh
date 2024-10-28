#!/bin/bash

#started by gsdRecord.service

amixer set Boost 100%
sudo chmod 777 /dev/gpiochip4
sudo chmod 777 /dev/shm
touch /dev/shm/test.wav;
touch /dev/shm/test.raw;
#mkdir -p /dev/shm/detect/asdf
#mkdir -p /dev/shm/checked/asdf


sudo python util/beep.py & sh test/audio.sh

until sh util/ntpstat.sh | grep 'ms'
do
  sleep 10
done

# Get the disk usage of /dev/sda1
usage=$(df -h | awk '/\/dev\/mmcblk1p1/ { print $5 }' | tr -d '%')

# Check if usage is less than 90%
if [ "$usage" -lt 90 ]; then
  echo "True: /dev/mmcblk1p1 is less than 90% full."

#if ! cat /data/mpp 
#then 
while true
do
  sudo nice -n -19 sudo -u pi python /home/pi/record/record.py -d dmic_sv /dev/shm/test.raw
done
#fi

fi
#sudo nice -n -20 sudo -u $USER python /home/pi/record/record.py -d dmic_sv /dev/shm/test.raw
#arecord -D dmic_sv -c2 -r 16000 -f S32_LE -t wav -V mono -v -F 10000 -d 1 -v /dev/shm/test.raw
#sudo python util/beep.py & arecord -D dmic_sv -c2 -r 16000 -f S32_LE -t wav -V mono -v -F 10000 -d 3 -v /dev/shm/test.raw
#sox /dev/shm/test.wav norm -0.1 channels 1 
#arecord -D dmic_sv -c2 -r 16000 -f S32_LE -t wav -V mono -v -F 10000 -d 10 -v /dev/shm/test.raw



#sound_frame.sh &&
#arecord -D dmic_sv -c2 -r 48000 -f S32_LE -t raw -V mono -v -F 3000 | while :; 
#do dd bs=384000 count=1 iflag=fullblock 2>/dev/null >> /dev/shm/output;  
#done