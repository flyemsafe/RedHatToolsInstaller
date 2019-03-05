






#--------------------------required packages for script to run----------------------------
#------------------
function SCRIPT {


yum -q list installed wget &>/dev/null && echo "wget is installed" || yum install -y wget --skip-broken
yum -q list installed firewalld &>/dev/null && echo "firewalld is installed" || yum install -y firewalld --skip-broken
yum -q list installed ansible &>/dev/null && echo "ansible is installed" || yum install -y ansible --skip-broken
yum -q list installed yum &>/dev/null && echo "yum is installed" || yum install -y yum --skip-broken


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
