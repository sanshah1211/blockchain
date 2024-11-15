#!/bin/bash
Wallet_Address=`cat /extra/validator | grep 'Public address' | sed -e 's/of the key//g' | sed -e 's/Public address/Wallet Address/g'`
echo -e "$Wallet_Address"
Wallet_Key=`cat /extra/validator | grep 'Public key'`
echo -e "$Wallet_Key"
private_key=`cat /extra/lemon/data/go-opera/nodekey`
echo -e "Private Key: $private_key"
password=`cat /extra/lemon/password`
echo -e "Password: $password"

