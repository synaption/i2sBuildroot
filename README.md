# i2sBuildroot

builds a minimumal booting linux with ota enabled and builds a driver for the microphone.  There is a small python program that crashes everything randomly after an hour or 2 on average.  


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
