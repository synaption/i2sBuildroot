#!/bin/bash

# Function to convert time in HH_MM_SS format to seconds
time_to_seconds() {
    local time=$1
    local seconds
    seconds=$(date -d "1970-01-01 $time UTC" +%s)
    echo "$seconds"
}

# Function to calculate the future time based on current time and seconds
calculate_future_time() {
    local seconds=$1
    local current_time
    current_time=$(date +%s)
    local future_time
    future_time=$((current_time + seconds))
    date -u -d "@$future_time" '+%H_%M_%S'
}

# Check if the script has at least one argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <time in HH_MM_SS or seconds>"
    exit 1
fi

# Check if the argument is a number
if [[ $1 =~ ^[0-9]+$ ]]; then
    future_time=$(calculate_future_time "$1")
elif [[ $1 =~ ^[0-9]{2}_[0-9]{2}_[0-9]{2}$ ]]; then
    future_time=$(time_to_seconds "$1")
else
    echo "Invalid time format. Please use either 'HH_MM_SS' or seconds."
    exit 1
fi

rounded_future_time=$(echo $future_time | sed -E 's/([0-9])([0-9])$/\10/; s/([0-9])([0-9])$/\15/')
echo $rounded_future_time > /dev/shm/test_time

