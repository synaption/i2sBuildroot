arecord -D dmic_sv -c2 -r 16000 -f S32_LE -t wav -V mono -v -F 10000 -d 1 -v /dev/shm/test.wav
sudo sox /dev/shm/test.wav /dev/shm/test2.wav norm -0.1 channels 1 
sudo sox /dev/shm/test2.wav -n stat &> /home/pi/test/audio_test
sudo cat /home/pi/test/audio_test | grep 'Rough   frequency:' >  /home/pi/test/audio_test2
cat test/audio_test2