#!/bin/bash


cd `dirname $0`
CAMIP=`cat ./CAMIP.txt`
#This bash need screen, bc and omxplayer. Please install them at first
#sudo apt install -y screen bc omxplayer


# Camera Feeds & Positions
THERMAL="screen -dmS THERMAL sh -c 'omxplayer rtsp://admin:soya4462@"$CAMIP"/Streaming/Channels/201 --win \"0 0 1080 960\" --live -n -1'";
VISIBLE="screen -dmS VISIBLE sh -c 'omxplayer rtsp://admin:soya4462@"$CAMIP"/Streaming/Channels/102 --win \"0 1080 1080 1800\" --live -b -n -1'";


# Camera Feed Names
# (variable names from above, separated by a space)
camera_feeds=("THERMAL" "VISIBLE")

#For watching CPU useage
declare -i threshold
declare -i thermalCPU
declare -i visibleCPU
threshold=30

case "$1" in
#---------------------------------------------------------------------
# Start displaying camera feeds
start)
isAlive=`ps -ef | grep omxplayer.bin | grep -v grep | wc -l`

if [ $isAlive -eq ${#camera_feeds[*]} ]; then
    echo "Camera Display looks OK... NO NEED TO START AGAIN"
    for i in "${camera_feeds[@]}"
    do
        if [ `sudo screen -list | grep $i | wc -l` == 1 ]; then
        echo "$i is running."
        fi
    done

else
    for i in "${camera_feeds[@]}"
    do
    eval eval '$'$i
    sleep 0.5
    done
    echo "Camera Display Started"
fi
;;
#---------------------------------------------------------------------
# Stop displaying camera feeds
stop)
sudo killall omxplayer
echo "Camera Display KILLED"
;;
#---------------------------------------------------------------------
# Restart all camera feeds that have died
repair)
isAlive=`ps -ef | grep omxplayer.bin | grep -v grep | wc -l`
echo "Threshold : $threshold "
    #---------------------------------------------------------------------
    #get each CPU USEAGE for THERMAL AND VISIBLE omxplayers
    ps aux |grep /usr/bin/omxplayer.bin | grep 201 |grep -v grep |while read tUSER tPID tCPU tMEM 
        #VSZ RSS TTY STAT STARTDATE STARTTIME
    do
	   #echo $tCPU
       #echo "THERMAL CPU : $tCPU %"
       thermalCPU=`echo "$tCPU * 10/1"|bc`
       echo $thermalCPU  > ./CPUt.txt
       echo "THERMAL CPUx10 :  $(echo `cat ./CPUt.txt`) "
    done

    ps aux |grep /usr/bin/omxplayer.bin | grep 102 |grep -v grep |while read vUSER vPID vCPU vMEM 
        #VSZ RSS TTY STAT STARTDATE STARTTIME
    do
	   #echo $vCPU
       #echo "VISIBLE CPU : $vCPU %"
       visibleCPU=`echo "$vCPU * 10/1"|bc`
       echo $visibleCPU  > ./CPUv.txt
       echo "VISIBLE CPUx10 :  $(echo `cat ./CPUv.txt`) "
    done

    
    #---------------------------------------------------------------------
	
if [ $isAlive -eq ${#camera_feeds[*]} ];then
    echo "DISPLAY LOOKS OK. Checking CPU Useage..."
    
        if [ $threshold -gt `cat ./CPUt.txt` ]; then
            echo "THERMAL DISPLAY IS DEAD. Need to reboot the App."
            sudo killall omxplayer
            sleep 0.5
            sudo ./thermalcameras start
        else
            if [ $threshold -gt `cat ./CPUv.txt` ]; then
                echo "VISIBLE DISPLAY IS DEAD. Need to reboot the App."
                sudo killall omxplayer
                sleep 0.5
                sudo sudo ./thermalcameras start
            else
            echo "OK"
            fi
        fi
    
else
    echo "DISPLAY IS DEAD"
    sudo killall omxplayer.bin
    sleep 0.5
    sudo ./thermalcameras start

        
fi
;;

#---------------------------------------------------------------------
# Check CPU Useage
chk)

    #get each CPU USEAGE for THERMAL AND VISIBLE omxplayers
    ps aux |grep /usr/bin/omxplayer.bin | grep 201 |grep -v grep |while read tUSER tPID tCPU tMEM 
        #VSZ RSS TTY STAT STARTDATE STARTTIME
    do
	   #echo $tCPU
       echo "THERMAL CPU : $tCPU %"
       thermalCPU=`echo "$tCPU * 10/1"|bc`
       echo $thermalCPU  > ./CPUt.txt
       echo "THERMAL CPUx10 :  $(echo `cat ./CPUt.txt`) "
    done

    ps aux |grep /usr/bin/omxplayer.bin | grep 102 |grep -v grep |while read vUSER vPID vCPU vMEM 
        #VSZ RSS TTY STAT STARTDATE STARTTIME
    do
	   #echo $vCPU
       echo "VISIBLE CPU : $vCPU %"
       visibleCPU=`echo "$vCPU * 10/1"|bc`
       echo $visibleCPU  > ./CPUv.txt
       echo "VISIBLE CPUx10 :  $(echo `cat ./CPUv.txt`) "
    done

;;
#---------------------------------------------------------------------
# Make logfile
log)
  LOG_TIME=`date '+%Y/%m/%d_%H:%M:%S'`
  LOG_DATE=`date '+%Y%m%d'`
  LOG_FILE="/home/pi/log/log${LOG_DATE}.log"

# ps command
  echo -e "\nps cmd: ${LOG_TIME} \n*******************" >> $LOG_FILE
  sudo ps aux |egrep 'PID|omxplayer.bin' |grep -v 'grep' >> $LOG_FILE

;;

*)
echo "Usage: ./thermalcameras {start|stop|repair|log}"
exit 1
;;
esac

