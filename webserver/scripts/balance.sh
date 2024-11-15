#!/bin/bash
# Check  wallet balance
tokenstake=`cat /extra/preload.js | grep tokenstake | cut -d "=" -f 2`
echo "Token Stake = $tokenstake"
wallet_balance=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? web3.eth.getBalance(wallet): console.log("PROBLEM")'`
echo "Balance = $wallet_balance"

