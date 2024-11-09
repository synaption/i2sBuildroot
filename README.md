# i2sBuildroot

builds a minimumal booting linux with ota enabled and builds a driver for the microphone.  There is a small python program that crashes everything randomly after an hour or 2 on average.  

the main important files for reproducing the bug are:

```bash
i2sBuildroot/i2s_mic/configs/coral_defconfig
i2sBuildroot/i2s_mic/package/snd_i2s_rpi/src/snd-i2smic-rpi.c
i2sBuildroot/br2rauc/patches/linux/0010-sai.patch
i2sBuildroot/i2s_mic/rootfs-overlay/home/pi/min_record.py
```


# Build Instructions

1. Clone this repo with subrepos:
    ```bash
    git clone --recurse-submodules https://github.com/synaption/i2sBuildroot
    ```

2. Install Docker:
    Follow the instructions on the [Docker website](https://docs.docker.com/get-docker/) to install Docker for your operating system.

4. Generate certs:
    ```bash
    cd br2rauc
    bash openssl-ca.sh
    cd ..
    ```

3. Build the project:
    ```bash
    ./Dmake_coral.sh
    ```

To reset clear your docker containers and remove the buildroot config file:
    ```bash
    rm output_coral/.config 
    docker ps -aq | xargs docker stop | xargs docker rm
    docker image ls -aq | xargs docker image rm
    ```
