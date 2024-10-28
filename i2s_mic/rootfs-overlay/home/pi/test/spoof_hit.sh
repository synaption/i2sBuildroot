file=`ls /dev/shm/detect/`
hostname=`cat /sys/class/net/end0/address | tr -d ':'`

echo -n $hostname $file 0.9999999 > /dev/shm/HIT