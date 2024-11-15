#!/bin/bash

DETAILS=$1
IP=`cat /home/rocky/validator_details | grep $DETAILS | awk '{print $2}'`
ansible -i /home/rocky/validator_info_inventory validators -b -m shell -a "cat /extra/lemon/password" -l $IP > /dev/null

#Fetch Password Details
password=`timeout 10 curl -s http://$IP:8000/information | grep Password | sed -e 's/Password://g'`


if [[ -z $password ]]
then  
   ansible -i /home/rocky/validator_info_inventory validators -b -m shell -a "systemctl restart webserver" -l $IP  > /dev/null
else
   echo Password = $password
fi
