#!/bin/bash

IP=$1

ids=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /home/ubuntu/start_node.bash | grep "^validator_id" | grep -oP 'validator_id=\K\d+'"`
mode=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /home/ubuntu/start_node.bash | grep "^startup_mode" | grep -oP 'startup_mode=\K\d+'"`
pub_key=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /home/ubuntu/start_node.bash  | grep ^public_key" | sed -e 's/public_key=//g'`
pubkey=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /extra/validator | grep '^Public key:' | sed -e 's/Public key://g' | tr -d ' '"`
pid=`ssh -i /home/rocky/teamhub ubuntu@$IP "sudo pidof opera"`

if [[ ! -z $pid ]]
then
  # Check in which mode Validator Is Running
  val_id=`ssh -i /home/rocky/teamhub ubuntu@$IP "/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec 'sfcc.getValidatorID(wallet)'"`
  if [[ "$mode" == 1 ]]
  then
    echo "Validator is Running in Read Only Mode"
    process_details=`ssh -i /home/rocky/teamhub ubuntu@$IP "ps -ef | grep $pid | grep -v grep"`
    echo "-------------------------------------"
    echo $process_details
    echo "-------------------------------------"
    echo -e "\nWallet Status"
    validator_check=`ssh -i /home/rocky/teamhub ubuntu@$IP "bash webserver/scripts/healthcheck.sh"`
    if [[ "$validator_check" == "Validator Is Ready" ]]
    then
      echo -e "\n-------------------------------------"
      echo "Wallet is Created"
      echo "-------------------------------------"
        ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/validator_id=$ids/validator_id=/g' /home/ubuntu/start_node.bash"
        ssh -i /home/rocky/teamhub ubuntu@$IP "sudo pkill -e -SIGINT opera"
        sleep 30s
        ssh -i /home/rocky/teamhub ubuntu@$IP "sudo chown -R ubuntu:ubuntu /extra"
        ssh -i /home/rocky/teamhub ubuntu@$IP "bash /home/ubuntu/start_node.bash &> /extra/log/nohup.validator &"
        sleep 2m
        process_details_1=`ssh -i /home/rocky/teamhub ubuntu@$IP "ps -ef | grep $pid | grep -v grep"`
        echo "-------------------------------------"
        echo $process_details_1
        echo "-------------------------------------"
        val_id_1=`ssh -i /home/rocky/teamhub ubuntu@$IP '/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec "sfcc.getValidatorID(wallet)"'`
        if [[ $val_id_1 -eq 0 ]]
        then
          echo "Node running in correct mode"
        else
          echo "Node Correction Done"
          ssh -i /home/rocky/teamhub ubuntu@$IP "sudo pkill -e -SIGINT opera"
          sleep 2s
          ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/startup_mode=1/startup_mode=3/g' /home/ubuntu/start_node.bash"
          ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/public_key=/public_key=$pubkey/g' /home/ubuntu/start_node.bash"
          ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/validator_id=/validator_id=$val_id/g' /home/ubuntu/start_node.bash"
          ssh -i /home/rocky/teamhub ubuntu@$IP "bash /home/ubuntu/start_node.bash &> /extra/log/nohup.validator &"
          sleep 2m
          process_details_2=`ssh -i /home/rocky/teamhub ubuntu@$IP "ps -ef | grep $pid | grep -v grep"`
          echo "-------------------------------------"
          echo $process_details_2
          echo "-------------------------------------"
        fi
    else
      echo -e "\n-------------------------------------"
      echo "Wallet is Not Created"
      echo "-------------------------------------"
    fi 
  else
    echo "Validator is having some issue"
  fi
else
  echo "Opera Process is Not Running"
fi
