if [ $# -eq 1 ]; then
    sudo nmap -n -sn -PP -oG ./data/live_hosts $1
else
    echo "Please provide the target ip range."
fi
