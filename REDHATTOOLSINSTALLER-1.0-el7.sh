#!/bin/bash
#POC/Demo
echo -ne "\e[8;40;170t"

# Hammer referance to assist in modifing the script can be found at 
# https://www.gitbook.com/book/abradshaw/getting-started-with-satellite-6-command-line/details


reset

#--------------------------required packages for script to run----------------------------

echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "

                           P.O.C Satellite 6.X RHEL 7.X KVM or RHEL 7 Physical Host 
                              THIS SCRIPT CONTAINS NO CONFIDENTIAL INFORMATION

                  This script is designed to set up a basic standalone Satellite 6.X system

             Disclaimer: This script was written for education, evaluation, and/or testing purposes. 
    This helper script is Licensed under GPL and there is no implied warranty and is not officially supported by anyone.
                                 
         ...SHOULD NOT BE USED ON A CURRENTlY OPERATING PRODUCTION SYSTEM - USE AT YOUR OWN RISK...
         Satellite 6.4 requirements can be found at 


   However the if you have an issue with the products installed and have a valid License please contact Red Hat at:

   RED HAT Inc..
   1-888-REDHAT-1 or 1-919-754-3700, then select the Menu Prompt for Customer Service
   Spanish: 1-888-REDHAT-1 Option 5 or 1-919-754-3700 Option 5
   Fax: 919-754-3701 (General Corporate Fax)
   Email address: customerservice@redhat.com "

echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
clear
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo "



                          JUST A REVIEW
                          This is a Proof Of Concept script for the purposes of evaluation
                          and/or training.
                          Requirements for this script to work:
                           * RHEL 7.6 Base install or Server with UI
                           * A Baremetal or VM (Snap shot this system in case you want 
                             to change something and run again)
                           * System
                              4 PROC
                              22 GB RAM
                              250 GB Storage
                           * Basic Partitioning on LVM
                              /  (root) 
                              /boot
                              swap 
                           * An external network connection 
                           * A subscription to Satellite 
                              In another window you will need to obtain your account Satellite pool ID from: 
                              ' subscription-manager list --available ' save that incase you are prompted for the it
                           * Manifest created with some entitlements and downloaded from:
                            https://access.redhat.com/management/subscription_allocations/
                           * The manifest placed in a directory /home/admin/Downloads
                           * Lastly this script 
                               "


echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
clear
if [ "$(whoami)" != "root" ]
then
echo "This script must be run as root - if you do not have the credentials please contact your administrator"
exit
fi

#--------------------------required packages for script to run----------------------------
#------------------
function SCRIPT {
#------------------
echo ""
echo "*************************************************************"
echo " Script configuration requirements installing for this server"
echo "*************************************************************"
echo "*********************************************************"
echo "SET SELINUX TO PERMISSIVE FOR THE INSTALL AND CONFIG OF SATELLITE"
echo "*********************************************************"
echo "In order for the script to work properly we need to eisable Selinux and the firewall."
read -p "Enter yY disable selinux and stop the firewall " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config
    setenforce 0
    service firewalld stop
    chkconfig firewalld off
    HNAME=$(hostname)
    DOM="$(hostname -d)"
    service firewalld stop
    setenforce 0
    mkdir -p /home/admin/Downloads
fi
echo ""
echo "*********************************************************"
echo "UNREGESTERING SYSTEM"
echo "*********************************************************"
echo "To ensure the system has proper entitlements and the ability to enable required repos. If you system is already setup and properly entitled, enter nN for no."
read -p "Enter yY to unrgister system " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    subscription-manager unregister
    subscription-manager clean
    echo " "
    echo "*********************************************************"
    echo "REGESTERING SYSTEM"
    echo "*********************************************************"
    subscription-manager register --auto-attach
    echo " "
    echo "*********************************************************"
    echo "NOTE:"
    echo "*********************************************************"
    echo "Attaching to your Satellite subscription using the pool id if the predefined value fails please obtain your pool id in another terminal running:

       subscription-manager list --available
       or 
       subscription-manager list --available --matches 'Red Hat Satellite'"
    echo " "
    read -p "Press [Enter] 32 digit pool id if prompted "
    echo " "
    subscription-manager attach --pool=`subscription-manager list --available --matches 'Red Hat Satellite Infrastructure Subscription' --pool-only`
    if [ $? -eq 0 ]; then
        echo 'Attaching Red Hat Satellite Infrastructure Subscription'
    else
        echo 'None of the predefined Satellite Pool IDs worked please enter your 32 digit alphanumeric Pool ID'
        read POOLID
        subscription-manager attach --pool=`POOLID`
        echo " "
    fi
    echo " "
    echo "*********************************************************"
    echo "SET REPOS ENABLING THE REDHATTOOLSINSTALLER SCRIPT TO RUN"
    echo "*********************************************************"
    subscription-manager repos --disable "*" || exit 1
    subscription-manager repos --enable=rhel-7-server-rpms || exit 1
    subscription-manager repos --enable=rhel-7-server-extras-rpms || exit 1
    subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
fi
echo ""
echo "Enabling EPEL to enable packages required for this script to succeed, enter nN to skip this if you already have epel enabled."
read -p "Enter yY to setup epel" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    yum -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken
    yum -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-util* --skip-broken
    yum-config-manager --enable epel 
    yum-config-manager --save --setopt=*.skip_if_unavailable=true
    rm -fr /var/cache/yum/*
    yum clean all
fi
echo " "
echo "*********************************************************"
echo "INSTALLING PACKAGES ENABLING SCRIPT TO RUN"
echo "*********************************************************"
yum -q list installed gtk2-devel &>/dev/null && echo "gtk2-devel is installed" || yum install -y gtk2-devel --skip-broken
yum -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken
yum -q list installed firewalld &>/dev/null && echo "firewalld is installed" || yum install -y firewalld --skip-broken
yum -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken 
yum -q list installed gnome-terminal &>/dev/null && echo "gnome-terminal is installed" || yum install -y gnome-terminal --skip-broken
yum -q list installed yum &>/dev/null && echo "yum is installed" || yum install -y yum --skip-broken
yum -q list installed lynx &>/dev/null && echo "lynx is installed" || yum install -y lynx --skip-broken
yum -q list installed perl &>/dev/null && echo "perl is installed" || yum install -y perl --skip-broken
yum -q list installed dialog &>/dev/null && echo "dialog is installed" || yum install -y dialog --skip-broken
yum -q list installed xdialog &>/dev/null && echo "xdialog is installed" || yum localinstall -y xdialog-2.3.1-13.el7.centos.x86_64.rpm --skip-broken
yum -q list installed firefox &>/dev/null && echo "firefox is installed" || install -y firefox --skip-broken
yum install -y dconf*
touch ./SCRIPT
echo " "
}
ls ./SCRIPT
if [ $? -eq 0 ]; then
    echo 'The requirements to run this script have been met, proceeding'
else
    echo "Installing requirements to run script please stand by"
    SCRIPT
    sleep 5
echo " "
fi


#--------------------------Define Env----------------------------

#configures dialog command for proper environment

if [[ -n $DISPLAY ]]
then
# Assume script running under X:windows
DIALOG=`which Xdialog`
RC=$?
if [[ $RC != 0 ]]
then
DIALOG=`which dialog`
RC=$?
if [[ $RC != 0 ]]
then
echo "Error:: Could not locate suitable dialog command: Please install dialog or if running in a desktop install Xdialog."
subscription-manager unregister
subscription manager clean
exit 1
fi
fi
else
# If Display is no set assume ok to use dialog
DIALOG=`which dialog`
RC=$?
if [[ $RC != 0 ]]
then
echo "Error:: Could not locate suitable dialog command: Please install dialog or if running in a desktop install Xdialog."
subscription-manager unregister
subscription manager clean
exit 1
fi
fi
#------------------------------------------------------SCRIPT BEGINS-----------------------------------------------------
#------------------------------------------------------ Functions ------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------
function VARIABLES1 {
#-------------------------------
echo ""
echo "*********************************************************"
echo "COLLECT VARIABLES FOR SAT 6.X"
echo "*********************************************************"
cp -p /root/.bashrc /root/.bashrc.bak
export INTERNAL=$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2}' | sed s/:// )
export EXTERNAL=$(ip route show | sed -e 's/^default via [0-9.]* dev \(\w\+\).*/\1/' | head -1)
export INTERNALIP=$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')
export INTERNALSUBMASK=$(ifconfig "$INTERNAL" |grep netmask |awk -F " " {'print $4'})
export INTERNALGATEWAY=$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')
echo "INTERNALIP=$INTERNALIP" >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "ORGANIZATION"
echo "*********************************************************"
echo 'What is the name of your Organization?'
read ORG
echo 'ORG='$ORG'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "LOCATION OF YOUR SATELLITE"
echo "*********************************************************"
echo 'LOCATION'
echo 'What is the location of your Satellite server. Example DENVER'
read LOC
echo 'LOC='$LOC'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING DOMAIN"
echo "*********************************************************"
echo 'what is your domain name Example:'$(hostname -d)''
read DOM
echo 'DOM='$DOM'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "ADMIN PASSWORD - WRITE OR REMEMBER YOU WILL BE PROMPTED FOR 
USER: admin AND THIS PASSWORD WHEN WE IMPORT THE MANIFEST"
echo "*********************************************************"
sleep 5
echo 'ADMIN=admin'  >> /root/.bashrc
echo 'What will the password be for your admin user?'
read  ADMIN_PASSWORD
echo 'ADMIN_PASSWORD='$ADMIN_PASSWORD'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "NAME OF FIRST SUBNET"
echo "*********************************************************"
echo 'What would you like to call your first subnet for systems you are regestering to satellite?'
read  SUBNET
echo 'SUBNET_NAME='$SUBNET'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "PROVISIONED NODE PREFIX"
echo "*********************************************************"
# The host prefix is used to distinguish the demo hosts created at the end of this script.
echo 'What would you like the prefix to be for systems you are provisioning with Satellite Example poc- kvm- vm-? enter to skip'
read  PREFIX
echo 'HOST_PREFIX='$PREFIX'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "NODE PASSWORD"
echo "*********************************************************"
echo 'PROVISIONED HOST PASSWORD'
echo 'Please enter the default password you would like to use for root for your newly provisioned nodes'
read PASSWORD
for i in $(echo "$PASSWORD" | openssl passwd -apr1 -stdin); do echo NODEPASS=$i >> /root/.bashrc ; done

export "DHCPSTART=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."2}')"
export "DHCPEND=$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."254}')"
echo ""
echo "*********************************************************"
echo "FINDING NETWORK"
echo "*********************************************************"
echo 'INTERNALNETWORK='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."0}')'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "FINDING SAT INTERFACE"
echo "*********************************************************"
echo 'SAT_INTERFACE='$(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//)'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "FINDING SAT IP"
echo ""
echo "*********************************************************"
echo 'SAT_IP='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING RELM"
echo "*********************************************************"
echo 'REALM='$(hostname -d)'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING DNS"
echo "*********************************************************"
echo 'DNS='$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')'' >> /root/.bashrc
echo 'DNS_REV='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $3"."$2"."$1".""in-addr.arpa"}')'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "DNS PTR RECORD"
echo "*********************************************************"
'PTR='$(ifconfig "$INTERNAL" | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $4}')''  >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING SUBNET VARS"
echo "*********************************************************"
echo 'SUBNET='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."0"."0}')'' >> /root/.bashrc
echo 'SUBNET_MASK='$(ifconfig $INTERNAL |grep netmask |awk -F " " {'print $4'})'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "SETTING BGIN AND END IPAM RANGE"
echo "*********************************************************"
echo 'SETTING BEGIN AND END IPAM RANGE'
echo 'SUBNET_IPAM_BEGIN='$DHCPSTART'' >> /root/.bashrc
echo 'SUBNET_IPAM_END='$DHCPEND'' >> /root/.bashrc
echo ""
echo "*********************************************************"
echo "DHCP"
echo "*********************************************************"
echo 'DHCP_RANGE=''"'$DHCPSTART' '$DHCPEND'"''' >> /root/.bashrc
echo 'DHCP_GW='$(ip route list type unicast dev $(ip -o link | head -n 2 | tail -n 1 | awk '{print $2;}' | sed s/:$//) |awk -F " " '{print $7}')'' >> /root/.bashrc
echo 'DHCP_DNS='$(ifconfig $INTERNAL | grep "inet" | awk -F ' ' '{print $2}' |grep -v f |awk -F . '{print $1"."$2"."$3"."$4}')'' >> /root/.bashrc
echo ""
}

YMESSAGE="Adding to /root/.bashrc vars"
NMESSAGE="Skipping"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=10
DEFAULTVALUE=n
#-------------------------------
function IPA {
#-------------------------------
echo ""
echo "*********************************************************"
echo "IPA SERVER"
echo "*********************************************************"
read -n1 -p "Do you have an IPA server? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
yum install -y ipa-client ipa-admintools
echo 'What is the FQDN of the IPA Server?'
read  FQDNIPA
echo 'IPA_SERVER='$FQDNIPA'' >> /root/.bashrc
echo 'What is the location of the Capsule?'
echo 'What is the ip address of your IPA host?'
read  IPAIP
echo 'IPA_IP='$IPAIP'' >> /root/.bashrc
source /root/.bashrc
echo '$IPA_IP $FQDNIPA' >> /etc/hosts
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function CAPSULE {
#-------------------------------
echo ""
echo "*********************************************************"
echo "CAPSULE"
echo "*********************************************************"
read -n1 -p "Would you like to install a secondary capsule ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'PREPARE_CAPSULE=true' >> /root/.bashrc
echo 'What will the FQDN of the Capsule be?'
read CAPNAME
echo 'CAPSULE_NAME='$CAPNAME'' >> /root/.bashrc
echo 'What is the location of the Capsule?'
read CAPLOC
echo 'CAPSULE_LOC='$CAPLOC'' >> /root/.bashrc
#COMMANDEXECUTION
elif  [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function SATLIBVIRT {
#-------------------------------
echo ""
echo "*********************************************************"
echo "LIBVIRT COMPUTE RESOURCE"
echo "*********************************************************"
read -n1 -p "Would you like to set up LIBVIRT as a compute resourse ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'CONFIGURE_LIBVIRT_RESOURCE=true' >> /root/.bashrc
echo 'What is the fqdn of your libvirt host?'
read  LIBVIRTFQDN
echo 'COMPUTE_RES_FQDN='$LIBVIRTFQDN'' >> /root/.bashrc
echo 'What is the ip address of your libvirt host?'
read  LIBVIRTIP
echo 'COMPUTE_RES_IP='$LIBVIRTIP'' >> /root/.bashrc
echo 'What would you like to name your libvirt satellite resource? Example KVM'
read  KVM
echo 'COMPUTE_RES_NAME='$KVM'' >> /root/.bashrc
source /root/.bashrc
echo ''$COMPUTE_RES_IP' '$COMPUTE_RES_FQDN'' >> /etc/hosts
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'CONFIGURE_LIBVIRT_RESOURCE=false' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function SATRHV {
#-------------------------------
echo ""
echo "*********************************************************"
echo "RHV COMPUTE RESOURCE"
echo "*********************************************************"
read -n1 -p "Would you like to set up RHV as a compute resourse ? Y/N " INPUT
INPUT=${INPUT:-$DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'CONFIGURE_RHEV_RESOURCE=true' >> /root/.bashrc
echo 'What is the fqdn of your RHV host?'
read  RHVQDN
echo 'COMPUTE_RES_FQDN=$RHVFQDN' >> /root/.bashrc
echo 'What is the ip address of your RHV host?'
read  RHVIP
echo 'COMPUTE_RES_IP=$RHVIP' >> /root/.bashrc
echo 'What would you like to name your RHV satellite resource? Example RHV'
read  RHV
echo 'COMPUTE_RES_NAME=$RHV' >> /root/.bashrc
echo 'RHV_VERSION_4=true' >> /root/.bashrc
echo 'RHV_RES_USER=admin@internal' >> /root/.bashrc
echo 'RHV_RES_PASSWD='$ADMIN_PASSWORD'' >> /root/.bashrc
echo 'RHV_RES_UUID=Default' >> /root/.bashrc
source /root/.bashrc
echo '$COMPUTE_RES_IP " " $COMPUTE_RES_FQDN' >> /etc/hosts
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'CONFIGURE_RHEV_RESOURCE=false' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
# This script alternatively allows to use a RHV virtualization backend using the following parameters
#-------------------------------
function RHVORLIBVIRT {
#-------------------------------
echo ""
echo "*********************************************************"
echo "RHV or LIBVIRT=TRUE"
echo "*********************************************************"
source /root/.bashrc
if [ $CONFIGURE_RHEV_RESOURCE = 'true' -a $CONFIGURE_LIBVIRT_RESOURCE = 'true' ]; then
echo "Only one of CONFIGURE_RHEV_RESOURCE and CONFIGURE_LIBVIRT_RESOURCE may be true."
exit 1
fi
# FIRST_SATELLITE matters only if you want to have more than one Sat work with the same IPAREALM infrastructure.
# If this is the case, you need to make sure to set this to false for all subsequent Satellite instances.
echo 'FIRST_SATELLITE=false ' >> /root/.bashrc
echo ' '
echo 'In another terminal please check/correct any variables in /root/.bashrc
that are not needed or are wrong'
read -p "Press [Enter] to continue"
}
#-------------------------------
function DEFAULTMSG {
#-------------------------------
echo ""
echo "*********************************************************"
echo "BY DEFAULT IF YOU JUST LET THIS SCRIPT RUN YOU WILL 
ONLY SYNC THE CORE RHEL 7 (KICKSTART, 7SERVER, OPTIONAL, EXTRAS,
 SAT 6.4 TOOLS, SUPPLAMENTRY, AND RH COMMON ) THE PROGRESS 
 TO THIS STEP CAN BE TRACKED AT $(hostname)/katello/sync_management:"
echo "*********************************************************"
echo ""
}
#-------------------------------
function SYNCREL5 {
#-------------------------------
echo ""
echo "*********************************************************"
echo "SYNC RHEL 5?"
echo "*********************************************************"
read -n1 -p "Would you like to enable RHEL 5 content  ? Y/N" INPUT
INPUT=${INPUT:-$RHEL5DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'RHEL5DEFAULTVALUE=y' >> /root/.bashrc
#COMMANDEXECUTION
elif  [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'RHEL5DEFAULTVALUE=n' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function SYNCREL6 {
#-------------------------------
echo ""
echo "*********************************************************"
echo "SYNC RHEL 6?"
echo "*********************************************************"
read -n1 -p "Would you like to enable RHEL 6 content  ? Y/N" INPUT
INPUT=${INPUT:-$RHEL6DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo 'RHEL6DEFAULTVALUE=y' >> /root/.bashrc
#COMMANDEXECUTION
elif  [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
echo 'RHEL6DEFAULTVALUE=n' >> /root/.bashrc
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#---END OF VARIABLES 1 SCRIPT---

#---START OF SAT 6.X INSTALL SCRIPT---
#------------------------------
function INSTALLREPOS {
#------------------------------
echo ""
echo "*********************************************************"
echo "SET REPOS FOR INSTALLING AND UPDATING SATELLITE 6.4"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
subscription-manager repos --disable '*'
yum-config-manager --disable epel
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
subscription-manager repos --enable=rhel-server-rhscl-7-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-6.4-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms || exit 1
yum clean all 
rm -rf /var/cache/yum
}
#------------------------------
function INSTALLDEPS {
#------------------------------
echo ""
echo "*********************************************************"
echo "INSTALLING DEPENDENCIES FOR SATELLITE OPERATING ENVIRONMENT"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
yum-config-manager --enable epel
sleep 5
yum install -y screen yum-utils vim gcc gcc-c++ git rh-nodejs8-npm make automake kernel-devel ruby-devel libvirt-client bind dhcp tftp syslinux* xorg-x11-server-Xorg  xorg-x11-server-common ntp chrony sos
sleep 5
echo ""
echo "*********************************************************"
echo "INSTALLING DEPENDENCIES FOR CONTENT VIEW AUTO PUBLISH"
echo "*********************************************************"
yum -y install python-pip rubygem-builder
yum-config manager --disable epel
pip install --upgrade pip
yum clean all ; rm -rf /var/cache/yum
yum upgrade -y; yum update -y
}
#----------------------------------
function GENERALSETUP {
#----------------------------------
echo ""
echo "*********************************************************"
echo 'GENERAL SETUP'
echo "*********************************************************"
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo " "

echo "*********************************************************"
echo "GENERATE USERS AND SYSTEM KEYS FOR REQUIRED USERS"
echo "*********************************************************"
echo ""
echo "*********************************************************"
echo "SETTING UP ADMIN"
echo "*********************************************************"
groupadd admin
useradd admin -g admin -m -p $ADMIN
mkdir -p /home/admin/.ssh
mkdir -p /home/admin/git
chown -R admin:admin /home/admin
sudo -u admin ssh-keygen -f /home/admin/.ssh/id_rsa -N ''
echo " "

echo "*********************************************************"
echo "SETTING UP FOREMAN-PROXY"
echo "*********************************************************"
useradd -M foreman-proxy
usermod -L foreman-proxy
mkdir -p /usr/share/foreman-proxy/.ssh
sudo -u foreman-proxy ssh-keygen -f /usr/share/foreman-proxy/.ssh/id_rsa_foreman_proxy -N ''
chown -R foreman-proxy:foreman-proxy /usr/share/foreman-proxy
echo " "

echo "*********************************************************"
echo "ROOT"
echo "*********************************************************"
ssh-keygen -f /root/.ssh/id_rsa -t rsa -N ''
echo " "

echo "*********************************************************"
echo “SET DOMAIN”
echo "*********************************************************"
cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo 'inet.ipv4.ip_forward=1' >> /etc/sysctl.conf
echo "kernel.domainname=$DOM" >> /etc/sysctl.conf
echo " "

echo "*********************************************************"
echo "GENERATE /ETC/HOSTS"
echo "*********************************************************"
cp /etc/hosts /etc/hosts.bak
echo "${SAT_IP} $(hostname)" >>/etc/hosts
echo " "

echo "*********************************************************"
echo "ADDING KATELLO-CVMANAGER TO /HOME/ADMIN/GIT "
echo "*********************************************************"
cd /home/admin/git
git clone https://github.com/RedHatSatellite/katello-cvmanager.git
cd 
mkdir -p /root/.hammer
echo " "

echo "*********************************************************"
echo "SETTING ADMIN USER TO NO PASSWORD FOR SUDO"
echo "*********************************************************"
cp /etc/sudoers /etc/sudoers.bak
echo 'admin ALL = NOPASSWD: ALL' >> /etc/sudoers
echo " "
}
#  --------------------------------------
function SYSCHECK {
#  --------------------------------------
echo " "
echo "*********************************************************"
echo "CHECKING ALL REQUIREMENTS HAVE BEEN MET"
echo "*********************************************************"
echo " "
echo "*********************************************************"
echo "CHECKING FQDN"
echo "*********************************************************"
hostname -f 
if [ $? -eq 0 ]; then
    echo 'The FQDN is as expected $(hostname)'
else
    echo "The FQDN is not defined please correct and try again"
    mv /root/.bashrc.bak /root/.bashrc
    mv /etc/sudoers.bak /etc/sudoers
    mv /etc/hosts.bak /etc/hosts
    mv /etc/sysctl.conf.bak /etc/sysctl.conf
    rm -f ./SCRIPT
    subscription-manager unregister
    subscription manager clean
    sleep 10
    exit
sleep 5
echo " "
fi
echo "*********************************************************"
echo "CHECKING FOR ADMIN USER"
echo "*********************************************************"
getent passwd admin > /dev/null 2&>1
if [ $? -eq 0 ]; then
    echo "yes the admin user exists"
else
    echo "No, the user does not exist
    The user does not exist please create a admin user
    and try again."
    exit
sleep 5
echo " "
fi
}
#  --------------------------------------
function INSTALLNSAT {
#  --------------------------------------
echo " "
echo "*********************************************************"
echo "INSTALLING SATELLITE"
echo "*********************************************************"
echo " "
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo "Disabling EPEL repos"
yum-config-manager --disable epel
echo " "
echo "Enabling Repos -> RHEL 7, RHSCL 7, Optional, Satellite 6.4, and Satellite Maintenance 6.0"
subscription-manager repos --enable=rhel-7-server-rpms || exit 1
subscription-manager repos --enable=rhel-server-rhscl-7-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-optional-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-6.4-rpms || exit 1
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms || exit 1
yum clean all 
rm -rf /var/cache/yum

echo "Installing Satellite 6.4"
yum -q list installed satellite &>/dev/null && echo "satellite is installed" || time yum install satellite -y --skip-broken
echo "Installing puppetserver"
yum -q list installed puppetserver &>/dev/null && echo "puppetserver is installed" || time yum install puppetserver -y --skip-broken
echo "Installing puppet-agent-oauth"
yum -q list installed puppet-agent-oauth &>/dev/null && echo "puppet-agent-oauth is installed" || time yum install puppet-agent-oauth -y --skip-broken
echo "Installing puppet-agent"
yum -q list installed puppet-agent &>/dev/null && echo "puppet-agent is installed" || time yum install puppet-agent -y --skip-broken
}
#---END OF SAT 6.X INSTALL SCRIPT---

#---START OF SAT 6.X CONFIGURE SCRIPT---
#  --------------------------------------
function CONFSAT {
#  --------------------------------------
echo " "
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CONFIGURING SATELLITE"
echo "*********************************************************"
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE BASE"
echo "*********************************************************"
satellite-installer --scenario satellite -v \
--foreman-admin-password=$ADMIN_PASSWORD \
--foreman-admin-username=$ADMIN \
--foreman-initial-organization=$ORG \
--foreman-initial-location=$LOC \
--foreman-proxy-dns true \
--foreman-proxy-dns-managed=true \
--foreman-proxy-dns-provider=nsupdate \
--foreman-proxy-dns-server="127.0.0.1" \
--foreman-proxy-dns-interface $SAT_INTERFACE \
--foreman-proxy-dns-zone=$DOM \
--foreman-proxy-dns-forwarders $DNS \
--foreman-proxy-dns-tsig-principal="foreman-proxy $(hostname)@$DOM" \
--foreman-proxy-dns-tsig-keytab=/etc/foreman-proxy/dns.key \
--foreman-proxy-dns-listen-on both \
--foreman-proxy-dns-reverse $DNS_REV
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE DHCP"
echo "*********************************************************"
source /root/.bashrc
satellite-installer --scenario satellite -v \
--foreman-proxy-dhcp true \
--foreman-proxy-dhcp-server=$INTERNALIP \
--foreman-proxy-dhcp-interface=$SAT_INTERFACE \
--foreman-proxy-dhcp-range="$DHCP_RANGE" \
--foreman-proxy-dhcp-gateway=$DHCP_GW \
--foreman-proxy-dhcp-nameservers=$DHCP_DNS \
--foreman-proxy-dhcp-listen-on both \
--foreman-proxy-dhcp-search-domains=$DOM

echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE TFTP"
echo "*********************************************************"
source /root/.bashrc
satellite-installer --scenario satellite -v \
--foreman-proxy-tftp true \
--foreman-proxy-tftp-listen-on both \
--foreman-proxy-tftp-servername=$SAT_IP
echo " "
echo "*********************************************************"
echo "CONFIGURING ALL SATELLITE PLUGINS"
echo "*********************************************************"
yum groupinstall -y 'Red Hat Satellite'
yum -q list installed puppet-foreman_scap_client &>/dev/null && echo "puppet-foreman_scap_client is installed" || yum install -y puppet-foreman_scap_client* --skip-broken
yum -q list installed foreman-discovery-image &>/dev/null && echo "foreman-discovery-image is installed" || yum install -y foreman-discovery-image* --skip-broken
yum -q list installed rubygem-smart_proxy_discovery &>/dev/null && echo "rubygem-smart_proxy_discovery is installed" || yum install -y rubygem-smart_proxy_discovery* --skip-broken 

source /root/.bashrc
satellite-installer --scenario satellite -v \
--foreman-proxy-plugin-discovery-install-images true \
--enable-foreman-plugin-discovery \
--foreman-plugin-tasks-automatic-cleanup true \
--foreman-proxy-content-enable-ostree true \
--enable-foreman-plugin-docker \
--enable-foreman-plugin-hooks \
--enable-foreman-plugin-openscap \
--enable-foreman-plugin-templates \
--enable-foreman-plugin-tasks \
--enable-foreman-compute-ec2 \
--enable-foreman-compute-gce \
--enable-foreman-compute-libvirt \
--enable-foreman-compute-openstack \
--enable-foreman-compute-ovirt \
--enable-foreman-compute-rackspace \
--enable-foreman-compute-vmware \
--enable-foreman-plugin-bootdisk \
--foreman-proxy-http true \
--foreman-proxy-ssl=true \
--foreman-proxy-templates-listen-on both \
--foreman-proxy-puppet-listen-on both \
--foreman-proxy-templates=true



echo " "
echo "*********************************************************"
echo "ENABLE DEB"
echo "*********************************************************"
foreman-installer -v --foreman-proxy-content-enable-deb --katello-enable-deb
echo " "
echo "*********************************************************"
echo "CONFIGURING SATELLITE CACHE"
echo "*********************************************************"
foreman-rake apipie:cache:index --trace
echo " "
echo "*********************************************************"
echo "DHCP SATELLITE"
echo "*********************************************************"
echo " "
DEFAULTDHCP=y
COUNTDOWN=15
read -n1 -p "Would like to use the DHCP server provided by Satellite? y/n " INPUT
INPUT=${INPUT:-$DEFAULTDHCP}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo " "
echo "DHCPD ENABLED"
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo " "
echo "DHCPD DISABLED"
chkconfig dhcpd off
service dhcpd stop
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#------------------------------
function HAMMERCONF {
#------------------------------
echo "*********************************************************"
echo "CONFIGURING HAMMER"
echo "*********************************************************"
echo -ne "\e[8;40;170t"
source /root/.bashrc
echo "*********************************************************"
echo "Enabling Hammer for Satellite configuration tasks"
echo "Setting up hammer will list the Satellite username and password in the /root/.hammer/cli_config.yml file
with default permissions set to -rw-r--r--, if this is a security concern it is recommended the file is
deleted once the setup is complete"
echo "*********************************************************"
read -p "Press [Enter] to continue"
sleep 10
cat > /root/.hammer/cli_config.yml<< EOF
:foreman:
 :host: 'https://$(hostname -f)'
 :username: '$ADMIN'
 :password: '$ADMIN_PASSWORD'
:log_dir: '/var/log/foreman'
:log_level: 'error'
EOF
sed -i 's/example/redhat/g' /etc/hammer/cli.modules.d/foreman.yml
sed -i 's/#:password/:password/g' /etc/hammer/cli.modules.d/foreman.yml
}

#  --------------------------------------
function CONFIG2 {
#  --------------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo ' '
echo "*********************************************************"
echo 'Download manifest from https://access.redhat.com/management/subscription_allocations/
 so you can build and export the manifest (just in case).
This must be saved into the /home/admin/Downloads directory'
echo "*********************************************************"
echo ' '
read -p "Press [Enter] to continue"
echo ' '
echo ' '
echo "*********************************************************"
echo 'If you have put your manafest into /home/admin/Downloads/'
echo "*********************************************************"
read -p "Press [Enter] to continue"
sleep 5
echo "*********************************************************"
echo 'WHEN PROMPTED PLEASE ENTER YOUR SATELLITE ADMIN USERNAME AND PASSWORD'
echo "*********************************************************"
sleep 5
chown -R admin:admin /home/admin
source /root/.bashrc
for i in $(find /home/admin/Downloads/ |grep manifest* ); do sudo -u admin hammer subscription upload --file $i --organization $ORG ; done  || exit 1
hammer subscription refresh-manifest --organization $ORG
echo "*********************************************************"
echo 'REFRESHING THE CAPSULE CONTENT'
echo "*********************************************************"
for i in $(hammer capsule list |awk -F '|' '{print $1}' |grep -v ID|grep -v -) ; do hammer capsule refresh-features --id=$i ; done 
sleep 5
echo "*********************************************************"
echo 'SETTING SATELLITE EVN SETTINGS'
echo "*********************************************************"
hammer settings set --name default_download_policy --value on_demand
hammer settings set --name default_organization  --value $ORG
hammer settings set --name default_location  --value $LOC
hammer settings set --name discovery_organization  --value $ORG
hammer settings set --name discovery_organization  --value $ORG
hammer settings set --name root_pass --value $NODEPASS

mkdir -p /etc/puppet/environments/production/modules
}
#-------------------------------
function STOPSPAMMINGVARLOG {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "STOP THE LOG SPAMMING OF /VAR/LOG/MESSAGES WITH SLICE"
echo "*********************************************************"
echo 'if $programname == "systemd" and ($msg contains "Starting Session" or $msg contains "Started Session" or $msg contains "Created slice" or $msg contains "Starting user-" or $msg contains "Starting User Slice of" or $msg contains "Removed session" or $msg contains "Removed slice User Slice of" or $msg contains "Stopping User Slice of") then stop' > /etc/rsyslog.d/ignore-systemd-session-slice.conf
systemctl restart rsyslog 
}
#NOTE: Jenkins, CentOS-7  Puppet Forge, Icinga, and Maven are examples of setting up a custom repository
#---START OF REPO CONFIGURE AND SYNC SCRIPT---
source /root/.bashrc
QMESSAGE5="Would you like to enable and sync RHEL 5 Content
This will enable
 Red Hat Enterprise Linux 5 Server (Kickstart)
 Red Hat Enterprise Linux 5 Server
 Red Hat Satellite Tools 6.4 (for RHEL 5 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 5 Server
 Red Hat Enterprise Linux 5 Server - Extras
 Red Hat Enterprise Linux 5 Server - Optional
 Red Hat Enterprise Linux 5 Server - Supplementary
 Red Hat Enterprise Linux 5 Server - RH Common
 Extra Packages for Enterprise Linux 5"

QMESSAGE6="Would you like to enable and sync RHEL 6 Content
This will enable
 Red Hat Enterprise Linux 6 Server (Kickstart)
 Red Hat Enterprise Linux 6 Server
 Red Hat Satellite Tools 6.4 (for RHEL 6 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 6 Server
 Red Hat Enterprise Linux 6 Server - Extras
 Red Hat Enterprise Linux 6 Server - Optional
 Red Hat Enterprise Linux 6 Server - Supplementary
 Red Hat Enterprise Linux 6 Server - RH Common
 Extra Packages for Enterprise Linux 6"

QMESSAGE7="Would you like to enable and sync RHEL 7 Content
This will enable:
 Red Hat Enterprise Linux 7 Server (Kickstart)
 Red Hat Enterprise Linux 7 Server
 Red Hat Satellite Tools 6.4 (for RHEL 7 Server)
 Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server
 Red Hat Enterprise Linux 7 Server - Extras
 Red Hat Enterprise Linux 7 Server - Optional
 Red Hat Enterprise Linux 7 Server - Supplementary
 Red Hat Enterprise Linux 7 Server - RH Common
 Extra Packages for Enterprise Linux 7"

QMESSAGEJBOSS="Would you like to download JBoss Enterprise Application Platform 7 (RHEL 7 Server) content"
QMESSAGEVIRTAGENT="Would you like to download Red Hat Virtualization 4 Management Agents for RHEL 7 content"
QMESSAGESAT64="Would you like to download Red Hat Satellite 6.4 (for RHEL 7 Server) content"
QMESSAGECAP64="Would you like to download Red Hat Satellite Capsule 6.4 (for RHEL 7 Server) content"
QMESSAGEOSC="Would you like to download Red Hat OpenShift Container Platform 3.10 content"
QMESSAGECEPH="Would you like to download Red Hat Ceph Storage Tools 3.0 for Red Hat Enterprise Linux 7 Server content"
QMESSAGESNC="Would you like to download Red Hat Storage Native Client for RHEL 7 content"
QMESSAGECSI="Would you like to download Red Hat Ceph Storage Installer 3.0 for Red Hat Enterprise Linux 7 Server content"
QMESSAGEOSP="Would you like to download Red Hat OpenStack Platform 13 for RHEL 7 content"
QMESSAGEOSPT="Would you like to download Red Hat OpenStack Tools 7.0 for Red Hat Enterprise Linux 7 Server content"
QMESSAGERHVH="Would you like to download Red Hat Virtualization Host 7 content"
QMESSAGERHVM="Would you like to download Red Hat Virtualization Manager 4.2 (RHEL 7 Server) content"
QMESSAGEATOMIC="Would you like to download Red Hat Enterprise Linux Atomic Host content"
QMESSAGETOWER="Would you like to download Ansible Tower custom content"
QMESSAGEPUPPET="Would you like to download Puppet Forge custom content"
QMESSAGEJENKINS="Would you like to download JENKINS custom content"
QMESSAGEMAVEN="Would you like to download Maven custom content"
QMESSAGEICINGA="Would you like to download Icinga custom content"
QMESSAGEICENTOS7="Would you like to download CentOS-7 custom content"

YMESSAGE="Adding avalable content. This step will take the longest,
(Depending on your network)"
NMESSAGE="Skipping avalable content"
FMESSAGE="PLEASE ENTER Y or N"
COUNTDOWN=15
OTHER7REPOSDEFAULTVALUE=n
RHEL7DEFAULTVALUE=y
PUPPETDEFAULTVALUE=y

#-------------------------------
function REQUESTSYNCMGT {
#-------------------------------
echo "*********************************************************"
echo "Configuring Repositories"
echo "*********************************************************"
echo "*********************************************************"
echo "BY DEFAULT IF YOU JUST LET THIS SCRIPT RUN YOU WILL 
ONLY SYNC THE  CORE RHEL 7 (KICKSTART, 7SERVER, OPTIONAL, EXTRAS,
 SAT 6.4 TOOLS, SUPPLAMENTRY, AND RH COMMON ) THE PROGRESS 
 TO THIS STEP CAN BE TRACKED AT $(hostname)/katello/sync_management :"
echo "*********************************************************"
if ! xset q &>/dev/null; then
    echo "No X server at \$DISPLAY [$DISPLAY]" >&2
    echo 'In a system browser please goto the URL to view progress https://$(hostname)/katello/sync_management'
    sleep 10
else 
    firefox https://$(hostname)/katello/sync_management &
fi
}
#-------------------------------
function REQUEST5 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 5 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGE5 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL5DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5.11' --name 'Red Hat Enterprise Linux 5 Server (Kickstart)'
hammer repository update --organization $ORG --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server (Kickstart)' --download-policy immediate
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server Kickstart x86_64 5.11' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.4 (for RHEL 5 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Satellite Tools 6.4 (for RHEL 5 Server) (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Software Collections for RHEL Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 5 Server'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Software Collections for RHEL Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 5 Server' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 5 Server - Extras (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server - Extras (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server - Optional (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server - Optional (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server - Supplementary (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server - Supplementary (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='5Server' --name 'Red Hat Enterprise Linux 5 Server - RH Common (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 5 Server - RH Common (RPMs)' 2>/dev/null

wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-5 /root/RPM-GPG-KEY-EPEL-5
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-5 --name 'GPG-EPEL-5' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 5' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 5' --organization $ORG --product='Extra Packages for Enterprise Linux 5' --content-type=yum --publish-via-http=true --url=https://archives.fedoraproject.org/pub/archive/epel/5/x86_64/ --checksum-type=sha256 --gpg-key=GPG-EPEL-5
time hammer repository synchronize --organization "$ORG" --product 'Extra Packages for Enterprise Linux 5' --name 'Extra Packages for Enterprise Linux 5' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUEST6 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 6 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGE6 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL6DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (Kickstart)'
hammer repository update --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6.10' --name 'Red Hat Enterprise Linux 6 Server (Kickstart)' --download-policy immediate
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6.10'--name 'Red Hat Enterprise Linux 6 Server (Kickstart)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.4 (for RHEL 6 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Satellite Tools 6.4 (for RHEL 6 Server) (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Optional (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server - Optional (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 6 Server - Extras (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server - Extras (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - RH Common (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server - RH Common (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server - Supplementary (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server - Supplementary (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'RHN Tools for Red Hat Enterprise Linux 6 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'RHN Tools for Red Hat Enterprise Linux 6 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='6Server' --name 'Red Hat Enterprise Linux 6 Server (ISOs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 6 Server (ISOs)' 2>/dev/null

wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-6 -O /root/RPM-GPG-KEY-EPEL-6
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-6 --name 'GPG-EPEL-6' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 6' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 6' --organization $ORG --product='Extra Packages for Enterprise Linux 6' --content-type=yum --publish-via-http=true --url=http://dl.fedoraproject.org/pub/epel/6/x86_64/ --checksum-type=sha256 --gpg-key=GPG-EPEL-6
time hammer repository synchronize --organization "$ORG" --product 'Extra Packages for Enterprise Linux 6' --name 'Extra Packages for Enterprise Linux 6' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUEST7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHEL 7 STANDARD REPOS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGE7 ? Y/N " INPUT
INPUT=${INPUT:-$RHEL7DEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server (Kickstart):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7.6' --name 'Red Hat Enterprise Linux 7 Server (Kickstart)' 
hammer repository update --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6' --download-policy immediate
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6' 2>/dev/null
sleep 10
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server' 2>/dev/null
sleep 10
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Supplementary (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Supplementary (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server' 2>/dev/null
sleep 10
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Optional (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - Optional (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server' 2>/dev/null
sleep 10
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - Extras (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Enterprise Linux 7 Server - Extras (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64' 2>/dev/null
sleep 10
echo "*********************************************************"
echo "Red Hat Satellite Tools 6.4 (for RHEL 7 Server) (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.4 (for RHEL 7 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
sleep 10
echo "*********************************************************"
echo "Red Hat Enterprise Linux 7 Server - RH Common (RPMs):"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server - RH Common (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server' 2>/dev/null
sleep 10
echo "*********************************************************"
echo "'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server:"
echo "*********************************************************"
hammer repository-set enable --organization "$ORG" --product 'Red Hat Software Collections (for RHEL Server)' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Software Collections (for RHEL Server)' --name 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server' 2>/dev/null
sleep 10
echo "*********************************************************"
echo "'Extra Packages for Enterprise Linux 7:"
echo "*********************************************************"
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 -O /root/RPM-GPG-KEY-EPEL-7
wget -q https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7Server -O /root/RPM-GPG-KEY-EPEL-7Server
sleep 10
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7  --name 'GPG-EPEL-7' --organization $ORG
hammer gpg create --key /root/RPM-GPG-KEY-EPEL-7Server  --name 'GPG-EPEL-7Sever' --organization $ORG
sleep 10
hammer product create --name='Extra Packages for Enterprise Linux 7' --organization $ORG
hammer product create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 7' --organization $ORG --product='Extra Packages for Enterprise Linux 7' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/7/x86_64/
time hammer repository synchronize --organization "$ORG" --product 'Extra Packages for Enterprise Linux 7' --name 'Extra Packages for Enterprise Linux 7' 2>/dev/null
sleep 10
hammer repository create --name='Extra Packages for Enterprise Linux 7Server' --organization $ORG --product='Extra Packages for Enterprise Linux 7Server' --content-type yum --publish-via-http=true --url=https://dl.fedoraproject.org/pub/epel/7Server/x86_64/
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Extra Packages for Enterprise Linux 7Server' 2>/dev/null
sleep 10
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTJBOSS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "JBOSS ENTERPRISE APPLICATION PLATFORM 7:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEJBOSS ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'JBoss Enterprise Application Platform' --basearch='x86_64' --releasever='7Server' --name 'JBoss Enterprise Application Platform 7 (RHEL 7 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'JBoss Enterprise Application Platform' --name 'JBoss Enterprise Application Platform 7 (RHEL 7 Server) (RPMs)' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTVIRTAGENT {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT VIRTUALIZATION 4 MANAGEMENT AGENTS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEVIRTAGENT ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Virtualization' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Virtualization 4 Management Agents for RHEL 7 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Virtualization' --name 'Red Hat Virtualization 4 Management Agents for RHEL 7 (RPMs)' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTIONICINGA
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTSAT64 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT SATELLITE 6.4:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGESAT64 ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Satellite' --basearch='x86_64' --name 'Red Hat Satellite 6.4 (for RHEL 7 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Satellite' --name 'Red Hat Satellite 6.4 (for RHEL 7 Server) (RPMs)' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTOSC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT OPENSHIFT CONTAINER PLATFORM 3.10:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEOSC ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenShift Container Platform' --basearch='x86_64' --name 'Red Hat OpenShift Container Platform 3.10 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat OpenShift Container Platform' --name 'Red Hat OpenShift Container Platform 3.10 (RPMs)' 2>/dev/null
#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTCEPH {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT CEPH:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGECEPH ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --name 'Red Hat Ceph Storage 3 for Red Hat Enterprise Linux 7 Server (FILEs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Ceph Storage' --name 'Red Hat Ceph Storage 3 for Red Hat Enterprise Linux 7 Server (FILEs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage Tools 3 for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Ceph Storage Tools 3 for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage MON 3 for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product ' Red Hat Ceph Storage ' --name 'Red Hat Ceph Storage MON 3 for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage 3 Text-Only Advisories for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product ' Red Hat Ceph Storage' --name 'Red Hat Ceph Storage 3 Text-Only Advisories for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage OSD 3 for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Ceph Storage' --name 'Red Hat Ceph Storage OSD 3 for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTSNC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT STORAGE NATIVE CLIENT:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGESNC ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Storage Native Client for RHEL 7 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Server' --name 'Red Hat Storage Native Client for RHEL 7 (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTCSI {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RED HAT CEPH STORAGE:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGECSI ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Ceph Storage' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Ceph Storage Installer 1.3 for Red Hat Enterprise Linux 7 Server (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Ceph Storage' --name 'Red Hat Ceph Storage Installer 1.3 for Red Hat Enterprise Linux 7 Server (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTOSP {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "OPENSTACK PLATFORM 13:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEOSP ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenStack' --basearch='x86_64' --releasever='7Server' --name 'Red Hat OpenStack Platform 13 for RHEL 7 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat OpenStack' --name 'Red Hat OpenStack Platform 13 for RHEL 7 (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTOSPT {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "OPENSTACK PLATFORM 13 OPERATIONAL TOOLS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEOSPT ? Y/N " INPUT
NPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenStack' --basearch='x86_64' --releasever='7Server' --name 'Red Hat OpenStack Platform 13 Operational Tools for RHEL 7 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat OpenStack' --name 'Red Hat OpenStack Platform 13 Operational Tools for RHEL 7 (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTOSPD {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "OPENSTACK PLATFORM 13 DIRECTOR:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEOSPD ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat OpenStack' --basearch='x86_64' --releasever='7Server' --name 'Red Hat OpenStack Platform 13 director for RHEL 7 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat OpenStack' --name 'Red Hat OpenStack Platform 13 director for RHEL 7 (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTRHVH {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHVH:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGERHVH ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Virtualization Host' --basearch='x86_64' --name 'Red Hat Virtualization Host 7 (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Virtualization Host' --name 'Red Hat Virtualization Host 7 (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTRHVM {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "RHV:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGERHVM ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Virtualization' --basearch='x86_64' --name 'Red Hat Virtualization Manager 4.2 (RHEL 7 Server) (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Virtualization' --name 'Red Hat Virtualization Manager 4.2 (RHEL 7 Server) (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTATOMIC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "ATOMIC:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEATOMIC ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer repository-set enable --organization $ORG --product 'Red Hat Enterprise Linux Atomic Host' --basearch='x86_64' --name 'Red Hat Enterprise Linux Atomic Host (RPMs)'
time hammer repository synchronize --organization "$ORG" --product 'Red Hat Enterprise Linux Atomic Host' --name 'Red Hat Enterprise Linux Atomic Host (RPMs)' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTTOWER {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "ANSIBLE TOWER:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGETOWER ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer product create --name='Ansible-Tower' --organization $ORG
hammer repository create --name='Ansible-Tower' --organization $ORG --product='Ansible-Tower' --content-type yum --publish-via-http=true --url=http://releases.ansible.com/ansible-tower/rpm/epel-7-x86_64/
time hammer repository synchronize --organization "$ORG" --product 'Ansible-Tower' --name 'Ansible-Tower' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTPUPPET {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "PUPPET FORGE:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEPUPPET ? Y/N " INPUT
INPUT=${INPUT:-$PUPPETDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer product create --name='Puppet Forge' --organization $ORG
hammer repository create --name='Puppet Forge' --organization $ORG --product='Puppet Forge' --content-type puppet --publish-via-http=true --url=https://forge.puppetlabs.com
time hammer repository synchronize --organization "$ORG" --product 'Puppet Forge' --name 'Puppet Forge' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTJENKINS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "JENKINS:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEJENKINS ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
wget http://pkg.jenkins.io/redhat-stable/jenkins.io.key
hammer gpg create --organization $ORG --name GPG-JENKINS --key jenkins.io.key
hammer product create --name='JENKINS' --organization $ORG
hammer repository create  --organization $ORG --name='JENKINS' --product=$ORG --gpg-key='GPG-JENKINS' --content-type='yum' --publish-via-http=true --url=https://pkg.jenkins.io/redhat/ --download-policy immediate
time hammer repository synchronize --organization "$ORG" --product 'JENKINS' --name 'JENKINS' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTMAVEN {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "MAVEN:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEMAVEN ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
hammer product create --name='Maven' --organization $ORG
hammer repository create  --organization $ORG --name='Maven 7Server' --product='Maven' --content-type='yum' --publish-via-http=true --url=https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-7Server/x86_64/ --download-policy immediate
time hammer repository synchronize --organization "$ORG" --product 'Maven 7Server' --name 'Maven 7Server' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTICINGA {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "ICINGA:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEICINGA ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
wget http://packages.icinga.org/icinga.key
hammer gpg create --organization $ORG --name GPG-ICINGA --key icinga.key
hammer product create --name='Icinga' --organization $ORG
hammer repository create  --organization $ORG --name='Icinga 7Server' --product='Icinga' --content-type='yum' --gpg-key='GPG-ICINGA' --publish-via-http=true --url=http://packages.icinga.org/epel/7Server/release --download-policy immediate
time hammer repository synchronize --organization "$ORG" --product 'Icinga 7Server' --name 'Icinga 7Server' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function REQUESTCENTOS7 {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CentOS-7:"
echo "*********************************************************"
read -n1 -t$COUNTDOWN -p "$QMESSAGEICENTOS7 ? Y/N " INPUT
INPUT=${INPUT:-$OTHER7REPOSDEFAULTVALUE}
if  [ "$INPUT" = "y" -o "$INPUT" = "Y" ] ;then
echo -e "\n$YMESSAGE\n"
cd /root/Downloads
wget http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7
hammer gpg create --organization $ORG --name RPM-GPG-KEY-CentOS-7 --key RPM-GPG-KEY-CentOS-7
hammer product create --name='CentOS-7' --organization $ORG
hammer repository create  --organization $ORG --name='CentOS-7 (Kickstart)' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/os/x86_64/ --download-policy immediate --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 (Kickstart)' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 CentOSplus' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/centosplus/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 CentOSplus' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 DotNET' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/dotnet/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 DotNET' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 Extras' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/extras/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 Extras' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 Fasttrack' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/fasttrack/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 Fasttrack' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 ISO' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://centos.host-engine.com/7.6.1810/isos/x86_64/CentOS-7-x86_64-DVD-1810.iso --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 ISO' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 Openshift-Origin' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/paas/x86_64/openshift-origin/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 Openshift-Origin' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 OpsTools' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/opstools/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 OpsTools' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 Gluster 5' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/storage/x86_64/gluster-5/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 Gluster 5' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 Ceph-Luminous' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/storage/x86_64/ceph-luminous/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 Ceph-Luminous' 2>/dev/null

hammer repository create  --organization $ORG --name='CentOS-7 Updates' --product='CentOS-7' --content-type='yum' --gpg-key='RPM-GPG-KEY-CentOS-7' --publish-via-http=true --url=http://mirror.centos.org/centos/7.6.1810/updates/x86_64/ --checksum-type=sha256
time hammer repository synchronize --organization "$ORG" --product 'CentOS-7' --name 'CentOS-7 Updates' 2>/dev/null

#COMMANDEXECUTION
elif [ "$INPUT" = "n" -o "$INPUT" = "N" ] ;then
echo -e "\n$NMESSAGE\n"
#COMMANDEXECUTION
else
echo -e "\n$FMESSAGE\n"
REQUEST
fi
}
#-------------------------------
function SYNC {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "SYNC ALL REPOSITORIES (WAIT FOR THIS TO COMPLETE BEFORE CONTINUING):"
echo "*********************************************************"
for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID'); do hammer repository synchronize --id ${i} --organization $ORG ; done
sleep 5
echo " "
}
#-------------------------------
function SYNCMSG {
#------------------------------
echo " "
if ! xset q &>/dev/null; then
    echo "No X server at \$DISPLAY [$DISPLAY]" >&2
    echo 'In a system browser please goto the URL to view progress https://$(hostname)/katello/sync_management'
    sleep 10
else 
    firefox https://$(hostname)/katello/sync_management &
fi
echo " "
}
#-------------------------------
function PRIDOMAIN {
#------------------------------
hammer domain update --id 1 --organizations $ORG --locations $LOC
}
#-------------------------------
function CREATESUBNET {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "CREATE THE FIRST OR PRIMARY SUBNET TO CONNECT THE NODES TO THE SATELLITE:"
echo "*********************************************************"
echo " "
hammer subnet create --name $SUBNET_NAME --network $INTERNALNETWORK --mask $SUBNET_MASK --gateway $DHCP_GW --dns-primary $DNS --ipam 'Internal DB' --from $SUBNET_IPAM_BEGIN --to $SUBNET_IPAM_END --tftp-id 1 --dhcp-id 1 --dns-id 1 --domain-ids 1 --organizations $ORG --locations "$LOC"
}
#-------------------------------
function ENVIRONMENTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "CREATE ENVIRONMENTS DEV_RHEL->TEST_RHEL->PROD_RHEL:"
echo "*********************************************************"
echo "DEVLOPMENT_RHEL_7"
hammer lifecycle-environment create --name='DEV_RHEL_7' --prior='Library' --organization $ORG
echo "TEST_RHEL_7"
hammer lifecycle-environment create --name='TEST_RHEL_7' --prior='DEV_RHEL_7' --organization $ORG
echo "PRODUCTION_RHEL_7"
hammer lifecycle-environment create --name='PROD_RHEL_7' --prior='TEST_RHEL_7' --organization $ORG
echo "DEVLOPMENT_RHEL_6"
hammer lifecycle-environment create --name='DEV_RHEL_6' --prior='Library' --organization $ORG
echo "TEST_RHEL_6"
hammer lifecycle-environment create --name='TEST_RHEL_6' --prior='DEV_RHEL_6' --organization $ORG
echo "PRODUCTION_RHEL_6"
hammer lifecycle-environment create --name='PROD_RHEL_6' --prior='TEST_RHEL_6' --organization $ORG
echo "DEVLOPMENT_RHEL_5"
hammer lifecycle-environment create --name='DEV_RHEL_5' --prior='Library' --organization $ORG
echo "TEST_RHEL_5"
hammer lifecycle-environment create --name='TEST_RHEL_5' --prior='DEV_RHEL_5' --organization $ORG
echo "PRODUCTION_RHEL_5"
hammer lifecycle-environment create --name='PROD_RHEL_5' --prior='TEST_RHEL_5' --organization $ORG
echo "DEVLOPMENT_CentOS_7"
hammer lifecycle-environment create --name='DEV_CentOS_7' --prior='Library' --organization $ORG
echo "TEST_CentOS_7"
hammer lifecycle-environment create --name='TEST_CentOS_7' --prior='DEV_CentOS_7' --organization $ORG
echo "PRODUCTION_CentOS_7"
hammer lifecycle-environment create --name='PROD_CentOS_7' --prior='TEST_CentOS_7' --organization $ORG
echo " "
hammer lifecycle-environment list --organization $ORG
echo " "
}
#-------------------------------
function DAILYSYNC {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create a daily sync plan:"
echo "*********************************************************"
hammer sync-plan create --name 'Daily_Sync' --description 'Daily Synchronization Plan' --organization $ORG --interval daily --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled no
hammer sync-plan create --name 'Weekly_Sync' --description 'Weekly Synchronization Plan' --organization $ORG --interval weekly --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled yes
hammer sync-plan list --organization $ORG
echo " "

}
#-------------------------------
function SYNCPLANCOMPONENTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
hammer product set-sync-plan --name 'Red Hat Enterprise Linux Server' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'Extra Packages for Enterprise Linux 7' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'Extra Packages for Enterprise Linux 6' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'Extra Packages for Enterprise Linux 5' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'Puppet Forge' --organization $ORG --sync-plan 'Weekly_Sync'
hammer product set-sync-plan --name 'CentOS-7' --organization $ORG --sync-plan 'Weekly_Sync'
}
#-------------------------------
function ASSOCPLANTOPRODUCTS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Associate plan to products:"
echo "*********************************************************"
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Oracle Java for RHEL Server'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Red Hat Enterprise Linux Server'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Puppet Forge'
hammer product set-sync-plan --sync-plan-id=2 --organization $ORG --name='Extra Packages for Enterprise Linux 5'
hammer product set-sync-plan --sync-plan-id=2 --organization $ORG --name='Extra Packages for Enterprise Linux 6'
hammer product set-sync-plan --sync-plan-id=1 --organization $ORG --name='Extra Packages for Enterprise Linux 7'
hammer product set-sync-plan --sync-plan-id=2 --organization $ORG --name='CentOS-7'
}
#-------------------------------
function CONTENTVIEWS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "***********************************************"
echo "Create a content view for CentOS-7:"
echo "***********************************************"
#hammer content-view create --name='RHEL7-server-x86_64' --organization $ORG
#sleep 20
#for i in $(hammer --csv repository list --organization $ORG | awk -F, {'print $1'} | grep -vi '^ID'); do hammer content-view add-repository --name RHEL7-Base --organization $ORG --repository-id=${i}; done  
hammer content-view create --organization $ORG --name 'CentOS 7' --label 'CentOS7' --description 'CentOS 7'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 (Kickstart)'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Gluster 5'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Extras'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 ISO'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Openshift-Origin'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 DotNET'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 CentOSplus'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Ceph-Luminous'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Fasttrack'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 OpsTools'
hammer content-view add-repository --organization $ORG --name 'CentOS 7' --product 'CentOS-7' --repository 'CentOS-7 Updates'
time hammer content-view publish --organization $ORG --name 'CentOS 7' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'CentOS 7' --to-lifecycle-environment DEV_CentOS_7  2>/dev/null
echo " "
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL 7' --label RHEL7 --description 'RHEL 7'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL 7' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL 7' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL 7' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL 7' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL 7' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL 7' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL 7' --to-lifecycle-environment DEV_RHEL_7  2>/dev/null
echo " "
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 CAPSULES:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Capsule' --label 'RHEL7-Capsule' --description 'Satellite Capsule'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Satellite Capsule' --repository 'Red Hat Satellite Capsule 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Capsule' --product 'Red Hat Satellite Capsule' --repository 'Red Hat Satellite Capsule 6.4 - Puppet 4 for RHEL 7 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Capsule' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL7-Capsule' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Capsule' --to-lifecycle-environment DEV_RHEL_7  2>/dev/null
echo " "
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 Hypervisor:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Hypervisor' --label 'RHEL7-Hypervisor' --description ''
hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Hypervisor' --product 'Red Hat Virtualization' --repository 'Red Hat Virtualization 4 Management Agents for RHEL 7 RPMs x86_64 7Server'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Hypervisor' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Hypervisor' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Hypervisor' --author puppetlabs --name ntp
time hammer content-view publish --organization $ORG --name 'RHEL7-Hypervisor' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Hypervisor' --to-lifecycle-environment DEV_RHEL_7  2>/dev/null
echo " "
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 Builder:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Builder' --label RHEL7-Builder --description 'RHEL7-Builder'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.6'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Supplementary RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - RH Common RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'JBoss Enterprise Application Platform' --repository 'JBoss Enterprise Application Platform 7 RHEL 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'Maven' --repository 'Maven 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product 'EPEL' --repository 'EPEL 7 - x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product $ORG --repository "Packages"
hammer content-view add-repository --organization $ORG --name 'RHEL7-Builder' --product $ORG --repository "Jenkins"
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author saz --name ssh
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name postgresql
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author puppetlabs --name java
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author rtyler --name jenkins
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Builder' --author camptocamp --name archive
time hammer content-view publish --organization $ORG --name 'RHEL7-Builder' --description 'Initial Publishing'
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Builder' --to-lifecycle-environment DEV_RHEL_7
echo " "
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 OSCP:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Oscp' --label 'RHEL7-Oscp' --description ''
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Oscp' --product 'Red Hat OpenShift Container Platform' --repository 'Red Hat OpenShift Container Platform 3.9 RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --conten30t-view 'RHEL7-Oscp' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author saz --name ssh
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author cristifalcas --name kubernetes
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author cristifalcas --name etcd
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author LunetIX --name docker
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Oscp' --author crayfishx --name firewalld
time hammer content-view publish --organization $ORG --name 'RHEL7-Oscp' --description 'Initial Publishing'
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Oscp' --to-lifecycle-environment DEV_RHEL_7
echo " "
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 7 DOCKER:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL7-Docker' --label 'RHEL7-Docker' --description ''
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 7 Server RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Software Collections for RHEL Server' --repository 'Red Hat Software Collections RPMs for Red Hat Enterprise Linux 7 Server x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Optional RPMs x86_64 7Server'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server - Extras RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'Red Hat OpenShift Container Platform' --repository 'Red Hat OpenShift Container Platform 3.9 RPMs x86_64'
hammer content-view add-repository --organization $ORG --name 'RHEL7-Docker' --product 'JBoss Enterprise Application Platform' --repository 'JBoss Enterprise Application Platform 7 RHEL 7 Server RPMs x86_64 7Server'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author saz --name ssh
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author cristifalcas --name kubernetes
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author cristifalcas --name etcd
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author cristifalcas --name docker
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author crayfishx --name firewalld
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL7-Docker' --author LunetIX --name dockerhost
time hammer content-view publish --organization $ORG --name 'RHEL7-Docker' --description 'Initial Publishing'
time hammer content-view version promote --organization $ORG --content-view 'RHEL7-Docker' --to-lifecycle-environment DEV_RHEL_7
echo '#-------------------------------'
echo 'RHEL6 CONTENT VIEW'
echo '#-------------------------------'
echo " "
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 6:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL6' --label 'RHEL6' --description 'Core Build for RHEL 6'
hammer content-view add-repository --organization $ORG --name 'RHEL6_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 6 Server RPMs x86_64 6Server'
hammer content-view add-repository --organization $ORG --name 'RHEL6_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 6 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL6_Base' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL6_Base' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL6_Base' --to-lifecycle-environment DEV_RHEL_6  2>/dev/null
echo '#-------------------------------'
echo 'RHEL5 CONTENT VIEW'
echo '#-------------------------------'
echo " "
echo "***********************************************"
echo "CREATE A CONTENT VIEW FOR RHEL 5:"
echo "***********************************************"
hammer content-view create --organization $ORG --name 'RHEL5' --label 'RHEL5' --description 'Core Build for RHEL 5'
hammer content-view add-repository --organization $ORG --name 'RHEL5' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 5 Server RPMs x86_64 6Server'
hammer content-view add-repository --organization $ORG --name 'RHEL5' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.4 for RHEL 5 Server RPMs x86_64'
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5' --author puppetlabs --name stdlib
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5' --author puppetlabs --name concat
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5' --author puppetlabs --name ntp
hammer content-view puppet-module add --organization $ORG --content-view 'RHEL5' --author saz --name ssh
time hammer content-view publish --organization $ORG --name 'RHEL5' --description 'Initial Publishing' 2>/dev/null
time hammer content-view version promote --organization $ORG --content-view 'RHEL5' --to-lifecycle-environment DEV_RHEL_5  2>/dev/null
}
#-------------------------------
#function PUBLISHCONTENT {
#-------------------------------
#source /root/.bashrc
#echo -ne "\e[8;40;170t"
#echo " "
#echo "********************************"
#echo "Publish content view to Library:"
#echo "********************************"
#echo " "
#echo "********************************"
#echo "
#  There may be an error that the (content-view publish) task has failed however the process takes longer to complete than the command timeout.
#Please see https://$(hostname)/content_views/2/versions to watch the task complete.“
# echo "********************************"
# echo " "
# hammer content-view publish --name 'rhel-7-server-x86_64' --organization $ORG --async
# sleep 2000
# echo " "
# echo "*********************************************************"
# echo "Promote content views to DEV_RHEL,TEST_RHEL,PROD_RHEL:"
# echo "*********************************************************"
# hammer content-view version promote --organization $ORG --from-lifecycle-environment ='Library' --to-lifecycle-environment 'DEV_RHEL' --id 2 --async
# sleep 700
# hammer content-view version promote --organization $ORG --from-lifecycle-environment ='DEV_RHEL' --to-lifecycle-environment 'TEST_RHEL' --id 2 --async
# sleep 700
# hammer content-view version promote --organization $ORG --from-lifecycle-environment ='TEST_RHEL' --to-lifecycle-environment 'PROD_RHEL' --id 2 --async
# sleep 700
#}
#-------------------------------
function HOSTCOLLECTION {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "***********************************"
echo "Create a host collection for RHEL:"
echo "***********************************"
hammer host-collection create --name='RHEL 7 x86_64' --organization $ORG
hammer host-collection create --name='CentOS 7 x86_64' --organization $ORG
hammer host-collection create --name='RHEL 5 x86_64' --organization $ORG
hammer host-collection create --name='RHEL 6 x86_64' --organization $ORG
sleep 10
hammer host-collection list --organization $ORG
}
#-------------------------------
function KEYSFORENV {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create an activation keys for environments:"
echo "*********************************************************"
hammer activation-key create --name 'RHEL7-x86_64' --organization $ORG --content-view='RHEL 7' --lifecycle-environment 'DEV_RHEL_7'
hammer activation-key create --name 'CentOS7-x86_64' --organization $ORG --content-view='CentOS 7' --lifecycle-environment 'DEV_CentOS_7'
#hammer activation-key create --name 'rhel-7-server-x86_64'-DEV_RHEL_7 --organization $ORG --content-view='RHEL7-server-x86_64' --lifecycle-environment 'DEV_RHEL_7'
#sleep 5
#hammer activation-key create --name 'rhel-7-server-x86_64'-TEST_RHEL_7 --organization $ORG --content-view='RHEL7-server-x86_64' --lifecycle-environment 'TEST_RHEL_7'
#sleep 5
#hammer activation-key create --name 'rhel-7-server-x86_64'-PROD_RHEL_7 --organization $ORG --content-view='RHEL7-server-x86_64' --lifecycle-environment 'PROD_RHEL_7'
#sleep 5
}
#-------------------------------
function KEYSTOHOST {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Associate each activation key to host collection:"
echo "*********************************************************"
hammer activation-key add-host-collection --name 'RHEL7-x86_64' --host-collection='RHEL 7 x86_64' --organization $ORG
sleep 5
hammer activation-key add-host-collection --name 'CentOS7-x86_64' --host-collection='CentOS 7 x86_64' --organization $ORG
sleep 5
hammer activation-key add-host-collection --name 'rhel-7-server-x86_64'-PROD_RHEL_7 --host-collection='RHEL 7 x86_64' --organization $ORG
sleep 5
}
#-------------------------------
function SUBTOKEYS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "********************************"
echo "
  There may be errors in the next step (Could not add subscription to activation key) Please ignore these as
  long as your primary keys for your enabled subscriptions have been added"
  
echo " "
echo "********************************"
echo " "
echo "*********************************************************"
echo "Add all subscriptions available to keys:"
echo "*********************************************************"
for i in $(hammer --csv activation-key list --organization $ORG | awk -F "," {'print $1'} | grep -vi '^ID'); do for j in $(hammer --csv subscription list --organization $ORG | awk -F "," {'print $1'} | grep -vi '^ID'); do hammer activation-key add-subscription --id ${i} --subscription-id ${j}; done; done
}
#-------------------------------
function MEDIUM {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create Media:"
echo "*********************************************************"
hammer medium create --path=http://repos/${ORG}/Library/content/dist/rhel/server/7/7.6/x86_64/kickstart/ --organizations=$ORG --locations="$LOC" --os-family=Redhat --name="RHEL 7.6 Kickstart" --operatingsystems="RedHat 7.6"
}
#----------------------------------
function VARSETUP2 {
#----------------------------------
echo "*********************************************************"
echo "CREATING THE NEXT SET OF VARIABLES."
echo "*********************************************************"
source /root/.bashrc
echo -ne "\e[8;40;170t"

ENVIROMENT=$(hammer --csv environment list |awk -F "," {'print $2'}|grep -v Name |grep -v production)
LEL=$(hammer --csv lifecycle-environment list  |awk -F "," {'print $2'} |grep -v NAME)
echo "CAID=1" >> /root/.bashrc
echo "MEDID1=$(hammer --csv medium list |grep 'RHEL 7.6' |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
#echo "MEDID2=$(hammer --csv medium list |grep 'CentOS 7' |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "SUBNETID=$(hammer --csv subnet list |awk -F "," {'print $1'}| grep -v Id)" >> /root/.bashrc
echo "OSID1=$(hammer os list |grep -i "RedHat 7.6"  |awk -F "|" {'print $1'})" >> /root/.bashrc
#echo "OSID2=$(hammer os list |grep -i "CentOS 7.6"  |awk -F "|" {'print $1'})" >> /root/.bashrc
echo "PROXYID=$(hammer --csv proxy list |awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "PARTID=$(hammer --csv partition-table list | grep "Kickstart default" | grep -i -v thin |cut -d, -f1)" >> /root/.bashrc
echo "PXEID=$(hammer --csv template list --per-page=1000 | grep "Kickstart default PXELinux" | cut -d, -f1)" >> /root/.bashrc
echo "SATID=$(hammer --csv template list --per-page=1000 | grep ",Kickstart default,provision" | grep "Kickstart default" | cut -d, -f1)" >> /root/.bashrc
echo "ORGID=$(hammer --csv organization list|awk -F "," {'print $1'}|grep -v Id)" >> /root/.bashrc
echo "LOCID=$(hammer --csv location list|awk -F "," {'print $1'} |grep -v Id)" >> /root/.bashrc
echo "ARCH=$(uname -i)" >> /root/.bashrc
echo "ARCHID=$(hammer --csv architecture list|grep x86_64 |awk -F "," {'print $1'})"  >> /root/.bashrc
echo "DOMID=$(hammer --csv domain list |grep -v Id |grep -v Name |awk -F "," {'print $1'})"  >> /root/.bashrc
echo "SUBNETID=$(hammer --csv subnet list |awk -F "," {'print $1'}| grep -v Id)" >> /root/.bashrc
echo "CVID=$(hammer --csv content-view list --organization $ORG |grep 'RHEL 7' |awk -F "," {'print $1'})" >>  /root/.bashrc
echo "*********************************************************"
echo "VERIFY VARIABLES IN /root/.bashrc"
echo "*********************************************************"
cat /root/.bashrc
echo " "
sleep 5
read -p "Press [Enter] to continue"
}
#-----------------------------------
function PARTITION_OS_PXE_TEMPLATE {
#-----------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "Setting Default Templates."
echo "*********************************************************"
for i in $OSID
do
hammer partition-table add-operatingsystem --id="${PARTID}" --operatingsystem-id="${i}"
hammer template add-operatingsystem --id="${PXEID}" --operatingsystem-id="${i}"
hammer os set-default-template --id="${i}" --config-template-id="${PXEID}"
hammer os add-config-template --id="${i}" --config-template-id="${SATID}"
hammer os set-default-template --id="${i}" --config-template-id="${SATID}"
done
}
#-------------------------------
function HOSTGROUPS {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Create a RHEL hostgroup(s):"
echo "*********************************************************"
#MAKES ROOTPASSWORD ON NODES rreeddhhaatt BECAUSE THE SYSTEM REQUIRES IT TO BE 8+ CHAR (--root-pass rreeddhhaatt)
ENVIROMENT=$(hammer --csv lifecycle-environment list |awk -F "," {'print $2'}|grep -v Name |grep -v production)
LEL=$(hammer --csv environment list  |awk -F "," {'print $2'}|grep -v Name)
for i in $LEL; do for j in $(hammer --csv environment list |awk -F "," {'print $2'}| awk -F "_" {'print $1'}|grep -v Name); do hammer hostgroup create --name RHEL-7.6-$j --environment $i --architecture-id $ARCHID --content-view-id $CVID --domain-id $DOMID --location-ids $LOCID --medium-id $MEDID1 --operatingsystem-id $OSID1 --organization-id=$ORGID  --partition-table-id $PARTID --puppet-ca-proxy-id $PROXYID --subnet-id $SUBNETID --root-pass=rreeddhhaatt ; done; done
#for i in $LEL; do for j in $(hammer --csv environment list |awk -F "," {'print $2'}| awk -F "_" {'print $1'}|grep -v Name); do hammer hostgroup create --name CentOS-7.6-$j --environment $i --architecture-id $ARCHID --content-view-id $CVID --domain-id $DOMID --location-ids $LOCID --medium-id $MEDID2 --operatingsystem-id $OSID2 --organization-id=$ORGID  --partition-table-id $PARTID --puppet-ca-proxy-id $PROXYID --subnet-id $SUBNETID --root-pass=redhat ; done; done
}
#-------------------------------
function MODPXELINUXDEF {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "Setting up and Modifying default template for auto discovery"
echo "*********************************************************"
#sed -i 's/SATELLITE_CAPSULE_URL/'$(hostname)'/g' /usr/share/foreman/app/views/unattended/pxe/PXELinux_default.erb
#sed -i 's/'$(hostname -f)'/$SAT_IP/g' /etc/foreman-proxy/settings.d/tftp.yml
hammer template update --id 1
}
#-------------------------------
function ADD_OS_TO_TEMPLATE {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "ASSOCIATE OS TO TEMPLATE"
echo "*********************************************************"
hammer template add-operatingsystem --operatingsystem-id 1 --id 1
}
#-------------------------------
function SATDONE {
#-------------------------------
for i in $(hammer capsule list |awk -F '|' '{print $1}' |grep -v ID|grep -v -) ; do hammer capsule refresh-features --id=$i ; done 
hammer template build-pxe-default
foreman-rake foreman_tasks:cleanup TASK_SEARCH='label = Actions::Katello::Repository::Sync' STATES='paused,pending,stopped' VERBOSE=true
foreman-rake katello:delete_orphaned_content --trace
foreman-rake katello:reindex --trace
echo 'YOU HAVE NOW COMPLETED INSTALLING SATELLITE!'
clear
}
#NOTE You can remove or dissasociate templates Remove is perm (Destricutve) dissasociate you can re associate if you need 

#-------------------------------
function REMOVEUNSUPPORTED {
#-------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo " "
echo "*********************************************************"
echo "REMOVING UNSUPPORTED COMPONENTS DESTRUCTIVE"
echo "*********************************************************"
for i in $(hammer template list |grep -i FreeBSD |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i CoreOS |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i salt |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i waik |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i NX-OS |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Alterator |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Junos |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Jumpstart |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i Preseed |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i chef |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer template list |grep -i AutoYaST |awk -F "|" {'print $1'}) ; do hammer template delete --id $i ;done
for i in $(hammer partition-table list |grep -i AutoYaST |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i CoreOS |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i FreeBSD |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i Jumpstart |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i Junos |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i NX-OS |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer partition-table list |grep -i Preseed |awk -F "|" {'print $1'}) ; do hammer partition-table delete --id $i ;done
for i in $(hammer medium list |grep -i CentOS |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i CoreOS |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i Debian |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i Fedora |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i FreeBSD |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i OpenSUSE |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
for i in $(hammer medium list |grep -i Ubuntu |awk -F "|" {'print $1'}) ; do hammer medium delete --id $i ;done
}
#-------------------------------
function DISASSOCIATE_TEMPLATES {
#------------------------------
source /root/.bashrc
echo -ne "\e[8;40;170t"
echo "*********************************************************"
echo "DISASSOCIATE UNSUPPORTED COMPONENTS NONDESTRUCTIVE"
echo "*********************************************************"
echo " "
declare -a TEMPLATES=(
"Alterator default"
"Alterator default finish"
"Alterator default PXELinux"
"alterator_pkglist"
"AutoYaST default"
"AutoYaST default user data"
"AutoYaST default iPXE"
"AutoYaST default PXELinux"
"AutoYaST SLES default"
"chef_client"
"coreos_cloudconfig"
"CoreOS provision"
"CoreOS PXELinux"
"Discovery Debian kexec"
"FreeBSD (mfsBSD) finish"
"FreeBSD (mfsBSD) provision"
"FreeBSD (mfsBSD) PXELinux"
"Jumpstart default"
"Jumpstart default finish"
"Jumpstart default PXEGrub"
"Junos default finish"
"Junos default SLAX"
"Junos default ZTP config"
"NX-OS default POAP setup"
"Preseed default"
"Preseed default finish"
"Preseed default PXEGrub2"
"Preseed default iPXE"
"Preseed default PXELinux"
"Preseed default user data"
"preseed_networking_setup"
"saltstack_minion"
"WAIK default PXELinux"
"XenServer default answerfile"
"XenServer default finish"
"XenServer default PXELinux"
 )
for INDEX in "${TEMPLATES[@]}"
do
echo disassoction of ${INDEX} from ${ORG}@${LOC}
hammer organization remove-config-template --config-template "${INDEX}" --name "${ORG}"
hammer location remove-config-template --config-template "${INDEX}" --name "${LOC}"
done
}
#-------------------------------
function SATUPDATE {
#-------------------------------
echo " "
echo "*********************************************************"
echo "Upgrading/Updating Satellite 6.3 to 6.4"
echo "*********************************************************"
echo " "
subscription-manager repos --disable '*'
subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-server-rhscl-7-rpms
subscription-manager repos --enable=rhel-7-server-satellite-6.4-rpms
subscription-manager repos --enable=rhel-7-server-satellite-maintenance-6-rpms
yum-config-manager --setopt=\*.skip_if_unavailable=1 --save \* 
foreman-rake foreman_tasks:cleanup TASK_SEARCH='label = Actions::Katello::Repository::Sync' STATES='paused,pending,stopped' VERBOSE=true
foreman-rake katello:delete_orphaned_content --trace
foreman-rake katello:reindex --trace
katello-service stop
katello-selinux-disable
setenforce 0
service firewalld stop 
yum upgrade -y --skip-broken --setopt=protected_multilib=false ; yum update -y --skip-broken --setopt=protected_multilib=false
yum -q list installed puppetserver &>/dev/null && echo "puppetserver is installed" || time yum install puppetserver -y --skip-broken --setopt=protected_multilib=false
yum -q list installed puppet-agent-oauth &>/dev/null && echo "puppet-agent-oauth is installed" || time yum install puppet-agent-oauth -y --skip-broken --setopt=protected_multilib=false
yum -q list installed puppet-agent &>/dev/null && echo "puppet-agent is installed" || time yum install puppet-agent -y --skip-broken --setopt=protected_multilib=false
satellite-installer -v --scenario satellite --upgrade
foreman-rake apipie:cache:index --trace
hammer template build-pxe-default
for i in $(hammer capsule list |awk -F '|' '{print $1}' |grep -v ID|grep -v -) ; do hammer capsule refresh-features --id=$i ; done 
}
#-------------------------------
function INSIGHTS {
#-------------------------------
yum update python-requests -y
yum install redhat-access-insights -y
redhat-access-insights --register
}

#-------------------------------
function CLEANUP {
#-------------------------------
rm -rf /home/admin/FILES
rm -rf /root/FILES
rm -rf /tmp/*
mv -f /root/.bashrc.bak /root/.bashrc
}

#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------Ansible Tower---------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------------------
#-------------------------------
#-------------------------------
function ANSIBLETOWER {
echo -ne "\e[8;33;120t"
reset 

HNAME=$(hostname)
echo " "
echo " "
echo " "
echo " "
echo "
ANSIBLE-TOWER BASE REQUIREMENTS

1. Ansible-Tower will require a license.
Please register and download your lincense at http://www.ansible.com/tower-trial

2. Hardware requirement depends, however whether 
  it is a KVM or physical-Tower will require atleast 1 node with:

Min Storage 30 GB
DirectoryRecommended
/Rest of drive
/boot  1024MB
/swap  8192MB

Min RAM 4096
Min CPU2 (4 Reccomended)"
echo " "
echo " "
echo " "
echo " "
echo " "
read -p "Press [Enter] to continue"
echo "

REQUIREMENTS CONTINUED
3. Network
Connection to the internet so the instller can download the required packages

4. For this POC you must have a RHN User ID and password with entitlements
    to channels below. (item 6)

5. Install ansible tgz will be downloaded and placed into the FILES directory created by the sript on the host machine:

* Ansible-Tower download will be pulled from https://releases.ansible.com/awx/setup/ansible-tower-setup-latest.tar.gz

6. This install was tested with:
          * RHEL_7.6 in a KVM environment.
          * Red Hat subscriber channels:
             rhel-7-server-ansible-2.7-rpms
             rhel-7-server-extras-rpms
             rhel-7-server-optional-rpms
             rhel-7-server-rpms
             https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm


7. Additional resources, packages, and documentation may be found at
                    http://www.ansible.com
                    https://www.ansible.com/tower-trial
                    http://docs.ansible.com/ansible-tower/latest/html/quickinstall/index.html"
echo " "
echo " "
read -p "If you have met the minimum requirement from above please Press [Enter] to continue"

#!/bin/bash
echo "************************************"
echo "installing prereq"
echo "************************************"
if grep -q -i "release 7.6" /etc/redhat-release ; then
rhel7only=1
echo "RHEL 7.6"
yum --noplugins -q list installed epel-release-latest-7 &>/dev/null && echo "epel-release-latest-7 is installed" || yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm --skip-broken --noplugins
else
echo "Not Running RHEL 7.x !"
fi
echo " "
yum --noplugins -q list installed yum-utils &>/dev/null && echo "yum-utils is installed" || yum install -y yum-utils --skip-broken --noplugins
yum --noplugins -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken --noplugins
yum --noplugins -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken --noplugins
yum --noplugins -q list installed bash-completion-extras &>/dev/null && echo "bash-completion-extras" || yum install -y bash-completion-extras --skip-broken --noplugins
yum --noplugins -q list installed openssh-clients &>/dev/null && echo "openssh-clients" || yum install -y openssh-clients --skip-broken --noplugins
sleep 10

echo " "
echo '************************************'
echo 'Creating FILES dir here'
echo '************************************'
mkdir -p FILES
cd FILES
pwd
sleep 10

echo " "
echo '************************************'
echo 'Wget Ansible Tower'
echo '************************************'
if grep -q -i "release 7" /etc/redhat-release ; then
 rhel7only=1
echo "RHEL 7 supporting latest release"
wget https://releases.ansible.com/awx/setup/ansible-tower-setup-latest.tar.gz
else
 echo "Not Running RHEL 7.x !"
fi
echo " "
sleep 10

echo " "
echo '************************************'
echo 'Expanding Ansible Tower and installing '
echo '************************************'

cd FILES
tar -zxvf ansible-tower-*.tar.gz
cd ansible-tower*
sed -i 's/admin_password="''"/admin_password="'redhat'"/g' inventory
sed -i 's/redis_password="''"/redis_password="'redhat'"/g' inventory
sed -i 's/pg_password="''"/pg_password="'redhat'"/g' inventory
sed -i 's/rabbitmq_password="''"/rabbitmq_password="'redhat'"/g' inventory
sh setup.sh
}

#--------------------------End Primary Functions--------------------------

#-----------------------
function dMainMenu {
#-----------------------
$DIALOG --stdout --title "Red Hat Sat 6.4 P.O.C. - RHEL 7.X" --menu "********** Red Hat Tools Menu ********* \n Please choose [1 -> 6]?" 30 90 10 \
1 "INSTALL SATELLITE 6.4" \
2 "UPGRADE/UPDATE THE SATELLITE 6.X" \
3 "SYNC ALL ACTIVATED REPOSITORIES" \
4 "LATEST ANSIBLE TOWER INSTALL" \
5 "POST INSTALL CLEANUP" \
6 "EXIT"
}

#----------------------
function dYesNo {
#-----------------------
$DIALOG --title " Prompt " --yesno "$1" 10 80
}

#-----------------------
function dMsgBx {
#-----------------------
$DIALOG --infobox "$1" 10 80
sleep 10
}

#----------------------
function dInptBx {
#----------------------
#Requires 2 mandatory options and 3rd is preset variable 
$DIALOG --title "$1" --inputbox "$2" 20 80 "$3" 
}

#----------------------------------End-Functions-------------------------------
######################
#### MAIN LOGIC ####
######################
#set -o xtrace
clear
# Sets a time value for Xdialog
[[ -z $DISPLAY ]] || TV=3000
$DIALOG --infobox "

**************************
**** Red Hat - Config Tools****
**************************

`hostname`" 20 80 $TV
[[ -z $DISPLAY ]] && sleep 2 

#---------------------------------Menu----------------------------------------
HNAME=$(hostname)
TMPd=FILES/TMP
while true
do
[[ -e "$TMPd" ]] || mkdir -p $TMPd
TmpFi=$(mktemp $TMPd/xcei.XXXXXXX )
dMainMenu > $TmpFi
RC=$?
[[ $RC -ne 0 ]] && break
Flag=$(cat $TmpFi)
case $Flag in
1) dMsgBx "INSTALL SATELLITE 6.4" \
sleep 10
VARIABLES1
IPA
CAPSULE
SATLIBVIRT
SATRHV
RHVORLIBVIRT
SYNCREL5
SYNCREL6
INSTALLREPOS
INSTALLDEPS
GENERALSETUP
SYSCHECK
INSTALLNSAT
CONFSAT
HAMMERCONF
CONFIG2
STOPSPAMMINGVARLOG
REQUESTSYNCMGT
#DEFAULTMSG
REQUEST5
REQUEST6
REQUEST7
REQUESTJBOSS
REQUESTVIRTAGENT
REQUESTSAT64
REQUESTOSC
REQUESTCEPH
REQUESTSNC
REQUESTCSI
REQUESTOSP
REQUESTOSPT
REQUESTOSPD
REQUESTRHVH
REQUESTRHVM
REQUESTATOMIC
REQUESTTOWER
REQUESTPUPPET
REQUESTJENKINS
REQUESTMAVEN
REQUESTICINGA
REQUESTCENTOS7
SYNC
SYNCMSG
PRIDOMAIN
CREATESUBNET
ENVIRONMENTS
DAILYSYNC
SYNCPLANCOMPONENTS
ASSOCPLANTOPRODUCTS
CONTENTVIEWS
#PUBLISHCONTENT
HOSTCOLLECTION
KEYSFORENV
KEYSTOHOST
SUBTOKEYS
MEDIUM
VARSETUP2
PARTITION_OS_PXE_TEMPLATE
HOSTGROUPS
MODPXELINUXDEF
ADD_OS_TO_TEMPLATE
SATDONE
sleep 10 
exit
;;
2) dMsgBx "UPGRADE/UPDATE THE SATELLITE 6.X" \
SATUPDATE
INSIGHTS
;;
3) dMsgBx "SYNC ALL ACTIVATED REPOSITORIES" \
SYNC
;;
4) dMsgBx "LATEST ANSIBLE TOWER INSTALL" \
ANSIBLETOWER
;;
5)  dMsgBx "POST INSTALL CLEANUP" \
#REMOVEUNSUPPORTED
DISASSOCIATE_TEMPLATES
CLEANUP
;;
6) dMsgBx "*** EXITING - THANK YOU ***"
break
;;
esac

done

exit 0
