#!/bin/bash

tx_status=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? web3.eth.getTransactionReceipt(tx).status : console.log("PROBLEM")'`
echo $tx_status | sed -e 's/"//1;s/"//1'

