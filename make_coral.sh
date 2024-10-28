#date > output_coral/target/home/pi/rauc/version
make -C buildroot/  BR2_EXTERNAL=../br2rauc:../i2s_mic O=../output_coral coral_defconfig
cd output_coral
make $1
cd ..
date
