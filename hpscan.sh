#!/usr/bin/bash

trap ctrl_c INT

function ctrl_c() {
        echo "** Exiting! CTRL-C"
        exit 1
}

function scan_ports() {
	local host=$1
	for port in {1..65535}; do
		timeout 0.2 bash -c "</dev/tcp/$host/$port &>/dev/null" 2>/dev/null
		if [ $? -eq 0 ]; then
			echo "The port $port is open on $host"
		else
			 n=$(($port % 10000))
			 if [ $n == 0 ]; then
			 	echo "Scaning.. $port"
			 fi
		fi
	done;wait
}

if [ $1 ]; then
	ip=$(echo "$1" | awk '{print $1"."$2"."$3"."}' FS='.')
	for i in {1..254}; do
		timeout 1 ping -c 1 $ip$i > /dev/null && echo "Ip $ip$i UP" && scan_ports $ip$i &
	done;wait
else
	echo -e "\n[i] Usage ./hpscan.sh <ip>. [ ex: ./hpscan.sh 192.168.1.1]"
fi
