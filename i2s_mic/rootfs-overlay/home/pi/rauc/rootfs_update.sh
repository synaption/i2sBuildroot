#sudo mkdir /var/lock
#sudo rauc status mark_good
sudo python reboot_o_matic/pet.py
sudo rm /tmp/rootfs.raucb

#if cat /sys/firmware/devicetree/base/model |  grep "Raspberry Pi Compute Module 4 Rev 1.0";
#then 
#   sudo wget http://159.203.115.123:40025/output_cm4/images/update.raucb -P /data; 
#fi
#
#if cat /sys/firmware/devicetree/base/model |  grep "Raspberry Pi 4 Model B";
#then 
#   sudo wget http://159.203.115.123:40025/output_pi4/images/update.raucb -P /data; 
#fi
#
#if cat /sys/firmware/devicetree/base/model |  grep "Raspberry Pi 3";
#then 
#   sudo wget http://159.203.115.123:40025/output_pi3/images/update.raucb -P /data; 
#fi

sudo wget http://159.203.115.123:40025/output_coral/images/rootfs.raucb -P /tmp; 
sudo python reboot_o_matic/pet.py
rauc install /tmp/rootfs.raucb ;
sudo python reboot_o_matic/pet.py
#sh mark_active_other.sh ;
sudo reboot ;


