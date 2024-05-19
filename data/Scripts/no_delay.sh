#!/bin/bash

#This bash script sends TCP packets from the client to the server.
#iperf2(1) is used to create the TCO flow and tc(1)/netem(8) is used to add delay. 

#expreiment parameter(s)
flow_rep=10
delay=0

#CSV output file
measurements_file="no_delay_results.csv"

#initialise CSV
echo "Delay (ms), Transfer (GBytes), Bandwidth (Mbits/sec), irtt (microseconds)" > $measurements_file

#prompts the user to enter the server name
while true; do
    echo "Enter the server name"
    read server_ip

    if [[ -z "$server_ip" ]]; then
        echo "Server name cannot be empty"
    else
        break
    fi
done

#extracts client's ethernet interface (code with the help of ChatGPT)
interface=$(ip addr | awk '/^[0-9]+: / { if ($2 != "lo:") print $2 }' | sed 's/://' | head -n 1)

#location of iperf2
iperf2_path=$(which iperf2)

echo "Transmission started"

#main loop 
for ((i=0; i < $flow_rep; i++))
do
    echo "End-to-end delay = ${delay}ms"

    #sends the TCP flow using iperf2 and receives the results
    iperf2_output=$($iperf2_path -c $server_ip)

    # Extracts necessary values (code with the help of ChatGPT)
    transfer=$(echo "$iperf2_output" | grep -o "[0-9]\+\(\.[0-9]\+\)\? [GM]Bytes" | awk '{print $1}')
    bandwidth=$(echo "$iperf2_output" | grep -o "[0-9]\+\(\.[0-9]\+\)\? Mbits/sec" | awk '{print $1}')
    irtt=$(echo "$iperf2_output" | grep -oP 'irtt=\d+/\d+/\d+' | awk -F= '{split($2, a, "/"); print a[3]}')

    #checks that the necessary values have been received
    if [[ -z $transfer || -z $bandwidth || -z $irtt ]]; then
        echo "Missing value(s) from iperf2"
        exit 1
    fi
    #copies the data to the CSV file
    echo "$delay,$transfer,$bandwidth,$irtt" >> $measurements_file
done

echo "Transmission terminated"