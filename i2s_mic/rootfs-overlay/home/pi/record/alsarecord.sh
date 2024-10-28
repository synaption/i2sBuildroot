sudo nice -n -19 sudo -u pi arecord -D dmic_sv -c2 -r 32000 -f S32_LE -t raw -V mono -v -F 3000 \
| while :; do dd bs=384000 count=1 iflag=fullblock 2>/dev/null >>/dev/shm/test.raw; done