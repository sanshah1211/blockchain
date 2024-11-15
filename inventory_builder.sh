#!/bin/bash

VAL_DETAILS=/home/rocky/validator_details
VAL_INVENTORY_TEMPLATE=/home/rocky/validator_info_inventory.templ
VAL_INVENTORY=/home/rocky/validator_info_inventory

if [[ -f $VAL_INVENTORY ]]
then 
   rm -rf $VAL_INVENTORY
   cp $VAL_INVENTORY_TEMPLATE $VAL_INVENTORY
   for i in `cat $VAL_DETAILS | awk '{print $2}'` ; do sed  -i "2 i $i" $VAL_INVENTORY; done 
fi

















