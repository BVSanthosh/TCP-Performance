#!/bin/bash

#This bash script sends TCP packets from the client to the server.
#iperf2(1) is used to create the TCO flow and tc(1)/netem(8) is used to add delay. 

#expreiment parameter(s)
delay=0

#CSV output file
measurements_file="exponential_increase_delay_results.csv"

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

#prompts the user to enter the exponent value
while true; do
    echo "Enter the value for the base"
    read exp

    if [[ -z "$exp" ]]; then
        echo "base not entered"
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
while true; do
    # checks if delay is greater than 64ms
    if [[ $delay -gt 64 ]]; then
        echo "Delay exceeded 64ms, exiting loop."
        break
    fi

    echo "End-to-end delay = ${delay}ms"

    #sends the TCP flow using iperf2 and receives the results
    iperf2_output=$($iperf2_path -c $server_ip)

    # Extracts necessary values (code with the help of ChatGPT)
    transfer=$(echo "$iperf2_output" | grep -o "[0-9]\+\(\.[0-9]\+\)\? [GM]Bytes" | awk '{print $1}')
    bandwidth=$(echo "$iperf2_output" | grep -o "[0-9]\+\(\.[0-9]\+\)\? Mbits/sec" | awk '{print $1}')
    irtt=$(echo "$iperf2_output" | grep -oP 'irtt=\d+/\d+/\d+' | awk -F= '{split($2, a, "/"); print a[3]}')

    #copies the data to the CSV file
    echo "$delay,$transfer,$bandwidth,$irtt" >> $measurements_file

    ((i++))   #increments the exponent
    delay=$(echo "2^$i" | bc)   #increases the delay
    tc qdisc change dev $interface root netem delay ${delay}ms   #changes the current qdisc congifuration
done

echo "Transmission terminated"

#Purges the current configuration
tc qdisc replace dev $interface root pfifo