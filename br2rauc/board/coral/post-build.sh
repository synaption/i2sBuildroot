#!/bin/sh

set -u
set -e

date > ${TARGET_DIR}/etc/rauc/rauc_version
date > ${TARGET_DIR}/home/pi/home_version

RAUC_COMPATIBLE="br2rauc-rpi4-64" #changed during coral migration

# Add a console on tty1
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^tty1::' ${TARGET_DIR}/etc/inittab || \
	sed -i '/GENERIC_SERIAL/a\
tty1::respawn:/sbin/getty -L  tty1 0 vt100 # HDMI console' ${TARGET_DIR}/etc/inittab
fi

# Mount persistent data partitions
if [ -e ${TARGET_DIR}/etc/fstab ]; then
	# For configuration data
	# WARNING: data=journal is safest, but potentially slow!
	grep -qE 'LABEL=Data' ${TARGET_DIR}/etc/fstab || \
	echo "LABEL=Data /data ext4 defaults,data=journal,noatime 0 0" >> ${TARGET_DIR}/etc/fstab

	# For bulk data (eg: firmware updates)
	#grep -qE 'LABEL=Upload' ${TARGET_DIR}/etc/fstab || \
	#echo "LABEL=Upload /upload ext4 defaults,noatime 0 0" >> ${TARGET_DIR}/etc/fstab
fi

# Copy custom cmdline.txt file
#install -D -m 0644 ${BR2_EXTERNAL_BR2RAUC_PATH}/board/raspberrypi/cmdline.txt ${BINARIES_DIR}/custom/cmdline.txt

# Copy RAUC certificate
if [ -e ${BR2_EXTERNAL_BR2RAUC_PATH}/openssl-ca/dev/ca.cert.pem ]; then
	install -D -m 0644 ${BR2_EXTERNAL_BR2RAUC_PATH}/openssl-ca/dev/ca.cert.pem ${TARGET_DIR}/etc/rauc/keyring.pem
else
	echo "RAUC CA certificate not found!"
	echo "...did you run the openssl-ca.sh script?"
	exit 1
fi

# Add disable-spidev.dtbo
install -D -m 0644 $BR2_EXTERNAL_BR2RAUC_PATH/board/raspberrypi/disable-spidev.dtbo ${BASE_DIR}/images/rpi-firmware/overlays/disable-spidev.dtbo

#  Copy newah firmware
#cp ${TARGET_DIR}/lib/firmware/nrc7292_cspi.bin ${TARGET_DIR}/lib/firmware/uni_s1g.bin

# Update RAUC compatible string
sed -i "/compatible/s/=.*\$/=${RAUC_COMPATIBLE}/" ${TARGET_DIR}/etc/rauc/system.conf

# 
cat <<- EOF >> ${TARGET_DIR}/etc/issue

	Root login disabled, use sudo su -
	eth0: \4{eth0}

EOF