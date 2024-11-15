#!/bin/bash
#
##########################################
# This script is initialize the validator#
#########################################
# Reconfigure correct permissions on /extra
sudo chown -R ubuntu:ubuntu /extra

# Run validator into read-only mode
echo "Validator Node in Read Only Mode"
sudo su ubuntu -c "bash /home/ubuntu/start_node.bash"
sleep 2s
tail -10 /extra/log/nohup.validator
sleep 10s
#
#Enode Details
enode=`head -n 20 /extra/log/nohup.validator | egrep -o 'enode://[0-9a-f]{128}@.*$'`

# IP Details
ipaddr=`ip -f inet addr show ens3 | sed -En -e 's/.*inet ([0-9.]+).*/\1/p'`

sleep 5s
# Check if API service is running succesfully or not.
curl http://$ipaddr:8000

if [ $? -eq 0 ] && ( sudo systemctl -q is-active webserver.service )
then
  echo "API is running and can be reachable from WHMCS"
else
  echo "Something is wrong, please check the code"
fi

