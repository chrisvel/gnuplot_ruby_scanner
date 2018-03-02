if [ $# -eq 1 ]; then
		sudo nmap -sS --top-ports 100 --reason --open -oG ./data/tcp_ports_10_$1 $1
else
    echo "Please provide the target ip address."
fi
