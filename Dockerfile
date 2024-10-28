# Use the base Ubuntu image
FROM ubuntu:22.04


# Create a non-root user
RUN useradd -ms /bin/bash builduser

# Install necessary packages
RUN apt-get update && \
    apt-get install -y build-essential && \
    apt-get install -y make && \
    apt-get install -y git && \
    apt-get install -y file && \
    apt-get install -y wget && \
    apt-get install -y cpio && \
    apt-get install -y unzip && \
    apt-get install -y rsync && \
    apt-get install -y bc && \
    apt-get install -y util-linux && \
    apt-get install -y python3 && \
    apt-get install -y python3-pip && \
    apt-get install -y patchelf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /home/bob/gsdBuildroot

