#!/bin/bash
#POC/Demo

# import functions
ROOT_DIR=$(pwd)

if [ ! -d ${ROOT_DIR}/functions ]
then
    echo "could not fin ${ROOT_DIR}/functions"
    exit 1
fi

for i in $(ls ${ROOT_DIR}/functions)
do
    source ${ROOT_DIR}/functions/${i}
done 

# Welcome message
#WELCOME_MSG

# Check for root
if [ "$(whoami)" != "root" ]
then
echo "This script must be run as root - if you do not have the credentials please contact your administrator"
exit
fi


# Register system and enable repos
#REDHAT_SUBSCRIPTIONS

# Get GUI Requirements
#GUI_REQUIREMENTS

# Ask user for information
COLLECT_SATELLITE_PRIMARY_VARIABLES
IPA
CAPSULE
SATLIBVIRT
SATRHV
RHVORLIBVIRT
DEFAULTMSG
SYNCREL5
SYNCREL6

if [ "${IPA_CLIENT}A" == "trueA" ]
then
  yum install -y ipa-client ipa-admintools
fi

YMESSAGE="Adding to /root/.bashrc vars"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=10
DEFAULTVALUE=n
