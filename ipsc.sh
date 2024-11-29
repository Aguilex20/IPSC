#!/bin/bash

# Obtain local IP
localIp=$(hostname -I | awk '{print $1}')

# Obtain the network through local IP and mask
netIp=$(echo $localIp | sed 's/\([0-9]*\.[0-9]*\.[0-9]*\)\.[0-9]*/\1.0\/24/')

# Show found net
echo "Detecting network: $red"

# Execute nmap to scan the net
echo "Scaning network $netIp for active IPs..."
nmap -sn $red | grep "Nmap scan report for" | awk '{print $5}'

# Calculate broadcast ip using ipcalc
broadcast=$(ipcalc -n -b $netIp | grep "Broadcast" | awk '{print $2}')

# Show broadcast IP
echo "Broadcast IP: $broadcast"
echo "Scan end"

# Line jump
echo " "

# Ask for broadcast ping
while true; do
    read -p "Do you want to ping broadcast $broadcast? (y/n): " answer
    case $answer in
        [Yy]* ) 
            pingOut=$(ping -b -c 4 -w 5 $broadcast)
            break
            ;;
        [Nn]* )
            break  # Continues
            ;;
        * ) 
            echo "Please, answer with 'Y' or 'N'"
            ;;
    esac
done

# Detect docs path
if [ -z "$XDG_DOCUMENTS_DIR" ]; then
    # If variable not defined, use default path
    document_path="$HOME/Documents"
else
    # If variable is defined, use XDG_DOCUMENTS_DIR
    document_path="$XDG_DOCUMENTS_DIR"
fi

# Create the /IPSC directory if it doesn't exist
log_directory="$document_path/IPSC"
mkdir -p "$log_directory"  # Create the directory if it doesn't exist

# Log file path
log_file="$document_path/IPSC/log$(date +%Y%m%d%H%M%S).txt"

while true; do
    echo ""
    read -p "Do you want to save a log file? (y/n): " answerLog
    case $answerLog in
        [Yy]* ) 
            # Create the log file and append information
            echo '  ___ ____  ____   ____   _                ' >> "$log_file"
            echo ' |_ _|  _ \/ ___| / ___| | |    ___   __ _ ' >> "$log_file"
            echo '  | || |_) \___ \| |     | |   / _ \ / _` |' >> "$log_file"
            echo '  | ||  __/ ___) | |___  | |__| (_) | (_| |' >> "$log_file"
            echo ' |___|_|   |____/ \____| |_____\___/ \__, |' >> "$log_file"
            echo '                                     |___/ ' >> "$log_file"
            echo "" >> "$log_file"
            echo "Detected network IP: $netIp" >> "$log_file"
            echo "Device IP: $localIp" >> "$log_file"
            echo "Broadcast IP: $broadcast" >> "$log_file"
            echo "" >> "$log_file"

            # Saves the ping result
            echo "Broadcast ping results:" >> "$log_file"
            echo "$pingOut" >> "$log_file"
            echo "Succesfully created $log_file in your docs folder"
            break
            ;;
        [Nn]* )
            exit 0  # Close program
            ;;
        * ) 
            echo "Por favor, responde con 'Y' o 'N'"
            ;;
    esac
done
