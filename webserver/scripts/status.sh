# Check if User is register as a validator or not
reg_status=`/home/ubuntu/go-opera/build/opera attach --preload /extra/preload.js --datadir=/extra/lemon/data --exec '!!abi && !!sfcc ? sfcc.getValidatorID(wallet) : console.log("PROBLEM")'`
# echo $reg_status
# reg_status=0


if [[ $reg_status == *ReferenceError* ]]
then
  echo "$reg_status" 
elif [ "$reg_status" != 0 ] && [[ "$reg_status" != *ReferenceError* ]]
then 
  echo "You are already registered as a validator with $reg_status"
elif [ "$reg_status" == 0 ] && [[ "$reg_status" != *ReferenceError* ]]
then
  echo "Please register this node as a Validator"
else
  echo "Unexpected Result"
fi
