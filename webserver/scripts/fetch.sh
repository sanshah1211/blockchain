#!/bin/bash

FILE_PATH=/extra/lemon/data/keystore
FILE=`ls -l /extra/lemon/data/keystore | grep UTC | awk '{print $9}'`


if [ -f "$FILE_PATH"/"$FILE" ]
then
  cp "$FILE_PATH"/"$FILE" /home/ubuntu/validator-wallet.json
  cat /home/ubuntu/validator-wallet.json
else
  echo "Private Key File Missing, please contact support"
fi

