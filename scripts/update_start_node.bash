#!/bin/bash

IP=$1

p_count=`ssh -i /home/rocky/teamhub ubuntu@$IP "grep -E '\-\-port \${port}' /home/ubuntu/start_node.bash | wc -l"`
mp_count=`ssh -i /home/rocky/teamhub ubuntu@$IP "grep -E '\-\-maxpeers \${maxpeers}' /home/ubuntu/start_node.bash | wc -l"`
O_PID_1=`ssh -i /home/rocky/teamhub ubuntu@$IP "pidof opera"`
PORTS=`ssh -i /home/rocky/teamhub ubuntu@$IP "grep -E '^port=5050' /home/ubuntu/start_node.bash"`
PEERS=`ssh -i /home/rocky/teamhub ubuntu@$IP "grep -E '^maxpeers=100' /home/ubuntu/start_node.bash"`

ping -c3 $IP &> /dev/null
if [[ $? -ne 0 ]]
then 
  echo "Node is not Reachiable...Exiting"
  exit 0
else
  if [[ -z $PORTS && -z $PEERS ]]
  then 
    ssh -i /home/rocky/teamhub ubuntu@$IP "sed  -i '/^public_key=/a port=5050' /home/ubuntu/start_node.bash"
    ssh -i /home/rocky/teamhub ubuntu@$IP "sed  -i '/^port=5050/a maxpeers=100' /home/ubuntu/start_node.bash"
    if [[ $p_count -eq 0 && $mp_count -eq 0 ]]
    then
      ssh -i /home/rocky/teamhub ubuntu@$IP "sed  -i '/--genesis \${genesis} \\\\/a \\\   \ --port \${port} \ \\\\' /home/ubuntu/start_node.bash"
      ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i '/--genesis.allowExperimental \\\\/i \\\   \ --maxpeers \${maxpeers} \ \\\\' /home/ubuntu/start_node.bash"
    else
      echo "Looks like flags are Present in the File"
    fi
  else
  echo "maxpeers and port is already defined"
  fi

  if [[ -z $O_PID_1 ]]
  then
    ssh -i /home/rocky/teamhub ubuntu@$IP "bash /home/ubuntu/start_node.bash &> /extra/log/nohup.validator &"
  else
    O_PID_2=`ssh -i /home/rocky/teamhub ubuntu@$IP "pidof opera"`
    process_details_1=`ssh -i /home/rocky/teamhub ubuntu@$IP "ps -ef | grep $O_PID_2 | grep -v grep"`
    echo "Checking Service is Running with Correct Flags"
    if [[ $process_details_1 == *\-\-port* && $process_details_1 == *\-\-maxpeers* ]] && [[ ! -z $PORTS && ! -z $PEERS ]]
    then
      echo "Service already reloaded with --port and --maxpeers flag"
      echo "No Need to Reload Service"
      echo "-------------------------------------"
      echo $process_details_1
      echo "-------------------------------------"
    else
      echo "Reloading Service to Apply Changes"
      ssh -i /home/rocky/teamhub ubuntu@$IP "pkill -e -SIGINT opera"
      echo "Reloading Process Again"
      sleep 2s
      ssh -i /home/rocky/teamhub ubuntu@$IP "bash /home/ubuntu/start_node.bash &> /extra/log/nohup.validator &"
      sleep 30s
      O_PID_2=`ssh -i /home/rocky/teamhub ubuntu@$IP "pidof opera"`
      process_details_2=`ssh -i /home/rocky/teamhub ubuntu@$IP "ps -ef | grep $O_PID_2 | grep -v grep"`
      echo "-------------------------------------"
      echo $process_details_2
      echo "-------------------------------------"
    fi
  fi
fi
