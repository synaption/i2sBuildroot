# i2sBuildroot
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
