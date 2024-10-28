import subprocess
from periphery import GPIO
import time
import sys


def system_ok():
    gpio = GPIO("/dev/gpiochip2", 13, "out")
    gpio.write(True)

def system_degraded():
    gpio = GPIO("/dev/gpiochip2", 13, "out")
    gpio.write(False)

def check_detect_file():
    detect_file = '/dev/shm/detect'
    if os.path.exists(detect_file):
        modified_time = os.path.getmtime(detect_file)
        current_time = time.time()
        if current_time - modified_time < 10:
            return True
        else:
            return False
    else:
        return False

def check_system_status():
    try:
        # Run the systemctl command and get the output
        result = subprocess.run(['systemctl', 'is-system-running'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # Check the output
        if (result.stdout.strip() == 'running'
            check_detect_file()):
            system_ok()
        else:
            system_degraded()

    except Exception as e:
        print(f"An error occurred: {e}")

# Run the check in a while loop
while True:
    try:
        check_system_status()
        time.sleep(60)
    except Exception as e:
        print(f"An error occurred: {e}")
    # Add any additional logic or delay here if needed

