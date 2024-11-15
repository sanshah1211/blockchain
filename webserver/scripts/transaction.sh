#!/bin/bash

# This script is for performing transactions

# Check  wallet balance
tokenstake=`cat /extra/preload.js | grep tokenstake | cut -d "=" -f 2`
wallet_balance=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? web3.eth.getBalance(wallet): console.log("PROBLEM")'`
public_key=`cat /extra/validator | grep "^Public key" | sed -e 's/Public key://g' | tr -d " "`
#
validator_id=`~/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? sfcc.getValidatorID(wallet) : console.log("PROBLEM")'`

last=`~/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? last = sfcc.lastValidatorID() : console.log("PROBLEM")'`
echo $last

# Processing Transactions
echo "Unlocking Account"
account_status=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? personal.unlockAccount(wallet, password, 300): console.log("PROBLEM")'`
if [ "$account_status" == true ]
then
  TX=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? tx = sfcc.createValidator(publickey, {from: wallet, value: web3.toWei(tokenstake)}): console.log("PROBLEM")'`
  result=`echo "$TX" | head -1`
  echo "tx = $TX" >> /extra/preload.js
  sleep 2s
  if [[ "$result" != *Error* ]]
  then
    echo "Transaction Processed Successfully with $TX"
    next=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? next = sfcc.getValidatorID(wallet) : console.log("PROBLEM")'`
    sleep 1s
    echo "$last"
    echo "$next"
    if [[ "$last" -lt "$next" ]]
    then
      echo "Process Complete with Validator ID $next"
    else
      echo "Process Terminated with Unknown Error"
      exit 1
    fi
  else
    echo "Transaction terminated with $TX " | head -1
    exit 1
  fi
fi

TX_STATUS=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? web3.eth.getTransactionReceipt(tx).status : console.log("PROBLEM")'`

BLOCK_NUMBER=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec web3.eth.blockNumber`

TXS=`echo $TX_STATUS | sed -e 's/"//1;s/"//1'`

until [ $TXS == 0x1 ]
do
  echo "Transaction is in Pending State"
  BLOCK=`tail -n 300 /extra/log/nohup.validator | grep -oP 'last_block=\K\d+' | sort -r | head -1`
  echo "Synced block on system is : $BLOCK" 
done

last=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? last = sfcc.lastValidatorID() : console.log("PROBLEM")'`
next=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? next = sfcc.getValidatorID(wallet) : console.log("PROBLEM")'`

sed -i 's/startup_mode=1/startup_mode=3/g' /home/ubuntu/start_node.bash

key=`cat /home/ubuntu/start_node.bash | grep -oP 'public_key=\K\d+'`
val_id=`cat /home/ubuntu/start_node.bash | grep -oP 'validator_id=\K\d+'`


if [[ -z "$key"  &&  -z "$val_id"  ]]
then
  sed -i "s/^validator_id=/validator_id=$next/g" /home/ubuntu/start_node.bash
  sed -i "s/^public_key=/public_key=$public_key/g" /home/ubuntu/start_node.bash
else
  echo "As Public Key Exist not changing any Value"
fi

echo -e "We are in process of registering this node as a Validator for ID $next"

echo -e "Finalizing the final Registration Process"

echo "Running node in Validator Mode"
bash /home/ubuntu/start_node.bash
sleep 1s
tail -300 /extra/log/nohup.validator
sleep 1s

