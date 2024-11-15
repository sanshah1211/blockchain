#!/bin/bash

EMAIL=$1
D_PATH=$HOME/validators/$EMAIL.details

# Fetch Validator Details from WHMCS
echo "Email ID: $EMAIL"
# Fetch Validator Information 
t_vals=`curl -s --location "https://myvortexhosting.io/getdata.php?auth=hdS3EfdPDn&email=$EMAIL" | jq -r '.[].name'`

for validators in $t_vals
do
IP=`curl -s --location "https://myvortexhosting.io/getdata.php?auth=hdS3EfdPDn&name=$validators" | jq --arg name $validators 'select(.name==$name).ip' | sed -e 's/"//1;s/"//1'`
mode=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /home/ubuntu/start_node.bash | grep "^startup_mode" | grep -oP 'startup_mode=\K\d+'"`
val_id=`ssh -i /home/rocky/teamhub ubuntu@$IP "/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec 'sfcc.getValidatorID(wallet)'"`
node_val_id=`ssh -i /home/rocky/teamhub ubuntu@$IP "cat /home/ubuntu/start_node.bash | grep "^validator_id" | grep -oP 'validator_id=\K\d+'"`
echo "Validator IP: $IP"
echo "Validator Information"
echo "------------------------------------------------------------"
echo "Validator Name: $validators"
# Check Mode
if [[ $mode -eq 3 ]]
then 
  echo "Mode: Validator"
else
  echo "Mode: Read Only"
fi
# Validator ID from Blokchain Explorer
if [[ $val_id -ne 0 && ! -z $val_id ]]
then
  echo "Network Registered Validator ID: $val_id"
else
  echo "This node is still not registered as Validator"
fi
# Validator ID Registered in start_node.bash
echo "Validator ID Cofigured on Node: $node_val_id"
echo "------------------------------------------------------------"
done
  






