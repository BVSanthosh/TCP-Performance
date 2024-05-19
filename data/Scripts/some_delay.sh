#!/bin/bash

#This bash script sends TCP packets from the client to the server.
#iperf2(1) is used to create the TCO flow and tc(1)/netem(8) is used to add delay. 

#expreiment parameter(s)
flow_rep=10

#CSV output file
measurements_file="some_delay_results.csv"

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

#prompts the user to enter the delay to add
while true; do
    echo "Enter the amount of delay"
    read delay

    if [[ -z "$delay" ]]; then
        echo "Delay not entered"
    elif [[ $delay -gt 64 ]]; then
        echo "Delay cannot be greater than 64ms"
    else
        break
    fi
done

#extracts client's ethernet interface (code with the help of ChatGPT)
interface=$(ip addr | awk '/^[0-9]+: / { if ($2 != "lo:") print $2 }' | sed 's/://' | head -n 1)

#location of iperf2
iperf2_path=$(which iperf2)

#replaces current qdisc configuration
tc qdisc replace dev $interface root netem delay ${delay}ms

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

    #copies the data to the CSV file
    echo "$delay,$transfer,$bandwidth,$irtt" >> $measurements_file
done

echo "Transmission terminated"

#Purges the current configuration
tc qdisc replace dev $interface root pfifo