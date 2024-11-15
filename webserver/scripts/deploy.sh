#!/bin/bash
#
##########################################
# This script is to deploy the validator#
#########################################
# Reconfiguring correct permissions to /extra
sudo chown -R ubuntu:ubuntu /extra

# Check if Validator is already initialized
if [ -f /extra/validator ]
then
   echo "Validator file is already there so stoping Deployment"
   sudo systemctl mask validator.service
   exit 0
fi

# Validator Service Configuration
cat > /home/ubuntu/validator.service  << EOF
[Unit]
Description=Service to generate validator address

[Service]
Type=oneshot
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu
#ExecStartPre=rm -rf /extra/validator
ExecStart=/home/ubuntu/go-opera/build/opera account new --datadir=/extra/lemon/data --password=/extra/lemon/password
StandardOutput=file:/extra/validator
StandardError=file:/extra/validator.errors
ExecStart=/home/ubuntu/go-opera/build/opera validator new --datadir=/extra/lemon/data --password=/extra/lemon/password
StandardOutput=append:/extra/validator
StandardError=append:/extra/validator.errors

[Install]
WantedBy=multi-user.target
EOF

sudo cp -rv /home/ubuntu/validator.service /lib/systemd/system/
sudo chown root:root /lib/systemd/system/validator.service
sudo systemctl daemon-reload  
sudo systemctl enable validator; sudo systemctl start validator

sleep 1s

echo -e "In process of Deploying Validator, it may take upto 5 mins. In the meantime you can query /status api"

# Enode Details Capture
enode=`head -n 20 /extra/log/nohup.validator | egrep -o 'enode://[0-9a-f]{128}@.*$'`
# echo -e "\n$enode"

# network: lemon=mainnet, lemon=testnet
network=lemon

# Print Wallet Details
# echo "Enode Detail: $enode"

wallet_address=`cat /extra/validator | grep 'Public address'`
wallet_key=`cat /extra/validator | grep 'Public key'`

#Storing password, public key and public address in preload.js
password=`cat /extra/lemon/password`
publickey=`cat /extra/validator | grep "Public key" | cut -d ":" -f 2 | tr -d " "`
publicaddress=`cat /extra/validator | grep "Public address" | cut -d ":" -f 2 | tr -d " "`
preload_file=preload.js
preload=/extra/${preload_file}
asset_base_url="https://assets.allthingslemon.io/validators"

# Downloading file and appending the contents to make sure no duplication
# echo "Deleting existing file to make sure copy is updated"
rm -rf /extra/preload.js

# echo "Downloading preload file for ${network}"
wget -O "${preload}" "${asset_base_url}/${preload_file}"

pass=`echo $password |sed -e 's/^/"/;s/$/"/'`
echo -e "\npassword = $pass"  >> /extra/preload.js

pubkey=`echo $publickey |sed -e 's/^/"/;s/$/"/'`
echo "publickey = $pubkey" >> /extra/preload.js

pubaddress=`echo $publicaddress |sed -e 's/^/"/;s/$/"/'`
echo "wallet = $pubaddress" >> /extra/preload.js

echo "tokenstake = 10.00" >> /extra/preload.js

if [ -f /extra/validator ]
then
   echo "Validator Deployment is completed"
   echo "Generating Details for you"
   echo -e "$wallet_address\n$wallet_key"
fi

sudo chown -R ubuntu:ubuntu /extra
sudo systemctl restart webserver

