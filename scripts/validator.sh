#!/bin/bash

IP=$1

ids=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /home/ubuntu/start_node.bash | grep "^validator_id" | grep -oP 'validator_id=\K\d+'"`
mode=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /home/ubuntu/start_node.bash | grep "^startup_mode" | grep -oP 'startup_mode=\K\d+'"`
pub_key=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /home/ubuntu/start_node.bash  | grep ^public_key" | sed -e 's/public_key=//g'`
pubkey=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /extra/validator | grep '^Public key:' | sed -e 's/Public key://g' | tr -d ' '"`
pid=`ssh -i /home/rocky/teamhub ubuntu@$IP "sudo pidof opera"`
#val_id=`ssh -i /home/rocky/teamhub ubuntu@$IP "/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? sfcc.getValidatorID(wallet) : console.log("PROBLEM")'"`

if [[ ! -z $pid ]]
then
  # Check in which mode Validator Is Running
  val_id=`ssh -i /home/rocky/teamhub ubuntu@$IP "/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? sfcc.getValidatorID(wallet) : console.log("PROBLEM")'"`
  if [[ "$mode" == 1 ]]
  then
    echo "Validator is Running in Read Only Mode"
    process_details=`ssh -i /home/rocky/teamhub ubuntu@$IP "ps -ef | grep $pid | grep -v grep"`
    echo "-------------------------------------"
    echo $process_details
    echo "-------------------------------------"
    echo -e "\nWallet Status"
    validator_check=`ssh -i /home/rocky/teamhub ubuntu@$IP bash webserver/scripts/healthcheck.sh`
    if [[ "$validator_check" == "Validator Is Ready" ]]
    then
      echo -e "\n-------------------------------------"
      echo "Wallet is Created"
      echo "-------------------------------------"
    else
      echo -e "\n-------------------------------------"
      echo "Wallet is Not Created"
      echo "-------------------------------------"
    fi 
  elif [[ "$mode" == 3 ]]
  then
    echo "Validator is Running in Validator Mode" 
    process_details=`ssh -i /home/rocky/teamhub ubuntu@$IP "ps -ef | grep $pid | grep -v grep"`
    echo "-------------------------------------"
    echo $process_details
    echo "-------------------------------------"
  else
    echo "Check Mode"
  fi
else
  echo "Process is not Running"
  validator_check=`ssh -i /home/rocky/teamhub ubuntu@$IP bash webserver/scripts/healthcheck.sh`
  if [[ $mode -eq 1 && -z $ids && -z $pub_key && "$validator_check" == "Validator Is Ready" ]]
  then 
    ssh -i /home/rocky/teamhub ubuntu@$IP "bash /home/ubuntu/start_node.bash &> /extra/log/nohup.validator &"
    sleep 1m
    pid=`ssh -i /home/rocky/teamhub ubuntu@$IP "pidof opera"`
    process_details=`ssh -i /home/rocky/teamhub ubuntu@$IP "ps -ef | grep $pid | grep -v grep"`
    echo "-------------------------------------"
    echo $process_details
    echo "-------------------------------------"
  elif [[ $mode -eq 3 && ! -z $ids && ! -z $pub_key && "$validator_check" == "Validator Is Ready" ]] || [[ $ids -eq 0 ]]
  then
    ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/startup_mode=3/startup_mode=1/g' /home/ubuntu/start_node.bash"
    ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/public_key=$pubkey/public_key=/g' /home/ubuntu/start_node.bash" 
    ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/validator_id=$ids/validator_id=0/g' /home/ubuntu/start_node.bash"
    ssh -i /home/rocky/teamhub ubuntu@$IP "bash /home/ubuntu/start_node.bash &> /extra/log/nohup.validator &"
    sleep 2m
    val_id=`ssh -i /home/rocky/teamhub ubuntu@$IP "/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec 'sfcc.getValidatorID(wallet)'"`
    ssh -i /home/rocky/teamhub ubuntu@$IP "pkill -e -SIGINT opera"
    ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/startup_mode=1/startup_mode=3/g' /home/ubuntu/start_node.bash"
    ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/validator_id=0/validator_id=$val_id/g' /home/ubuntu/start_node.bash"
    ssh -i /home/rocky/teamhub ubuntu@$IP "sed -i 's/public_key=/public_key=$pubkey/g' /home/ubuntu/start_node.bash"
    ssh -i /home/rocky/teamhub ubuntu@$IP "bash /home/ubuntu/start_node.bash &> /extra/log/nohup.validator &"
    sleep 2m
    pid=`ssh -i /home/rocky/teamhub ubuntu@$IP "pidof opera"`
    process_details=`ssh -i /home/rocky/teamhub ubuntu@$IP "ps -ef | grep $pid | grep -v grep"`
    echo "-------------------------------------"
    echo $process_details
    echo "-------------------------------------"
  else
    echo "Check System"
  fi
fi
