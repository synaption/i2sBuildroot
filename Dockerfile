# Use the base Ubuntu image
FROM ubuntu:22.04


# Create a non-root user
RUN useradd -ms /bin/bash builduser

# Install necessary packages
RUN apt-get update
RUN apt-get install -y build-essential
RUN apt-get install -y make
RUN apt-get install -y git
RUN apt-get install -y file
RUN apt-get install -y wget
RUN apt-get install -y cpio
RUN apt-get install -y unzip
RUN apt-get install -y rsync
RUN apt-get install -y bc
RUN apt-get install -y util-linux
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y patchelf
RUN apt-get install -y bmap-tools
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /home/builduser/i2sBuildroot

