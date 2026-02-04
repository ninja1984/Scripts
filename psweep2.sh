#!/bin/bash

read -p "Enter IP Subnet (e.g., 192.168.1): " IP

echo "Scanning $IP.0/24..."

for i in {1..254}
do
    # 1. We added -W 1 so it doesn't wait forever
    # 2. We simplified grep to just look for "from"
    # 3. We use awk to grab the IP address part
    ping -c 1 -W 1 $IP.$i 2>/dev/null | grep "from" | awk '{print $4}' | tr -d ":" &
done

# This 'wait' is critical so the script stays active until all pings finish
wait
echo "Scan Complete."
