#sudo mount /dev/mmcblk1 /media
sudo mkdir "/media/$(hostname)_$(date +%F)"
#mv /dev/shm/checked/* "/media/$(hostname)_$(date +%F)/"
sudo find /dev/shm/past/ -name "*" -type f -mmin +1 -exec mv -t "/media/$(hostname)_$(date +%F)" {} +
#sudo find /dev/shm/past/ -name "*" -type f -mmin +1 -exec rm {} +
#find /dev/shm/detect/ -name "*" -type f -mmin +10 -delete