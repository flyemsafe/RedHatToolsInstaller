#!/bin/bash
#POC/Demo

# import functions
for source in $(ls ./functions)
do
    source ./functions/$source 
done 

# Welcome message
WELCOME_MSG

# Check for root
if [ "$(whoami)" != "root" ]
then
echo "This script must be run as root - if you do not have the credentials please contact your administrator"
exit
fi


# Register system and enable repos
REDHAT_SUBSCRIPTIONS

# Get GUI Requirements
GUI_REQUIREMENTS

# Ask user for information
COLLECT_VARIABLES_DIALOG

YMESSAGE="Adding to /root/.bashrc vars"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=10
DEFAULTVALUE=n