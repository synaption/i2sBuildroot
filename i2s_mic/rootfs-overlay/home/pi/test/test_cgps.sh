killall -9 gpsd ntpd
gpsd -n /dev/ttyXX
sleep 2
ntpd -gN
sleep 2
cgps