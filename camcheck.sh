#!/bin/bash


cd `dirname $0`
CAMIP=`cat ./CAMIP.txt`

# Camera Feeds & Positions
THERMAL="screen -dmS THERMAL sh -c 'omxplayer rtsp://admin:soya4462@"$CAMIP"/Streaming/Channels/201 --win \"0 0 1080 960\" --live -n -1'";
VISIBLE="screen -dmS VISIBLE sh -c 'omxplayer rtsp://admin:soya4462@"$CAMIP"/Streaming/Channels/102 --win \"0 1080 1080 1800\" --live -b -n -1'";


# Camera Feed Names
camera_feeds=("THERMAL" "VISIBLE")

#For watching CPU useage
declare -i threshold
declare -i thermalCPU
declare -i visibleCPU
threshold=55


#isAlive=`ps -ef | grep omxplayer.bin | grep -v grep | wc -l`


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
       echo "VISIBLE CPUx10 : $(echo `cat ./CPUv.txt`) "
    done

#if [ $isAlive -eq ${#camera_feeds[*]} ];then
#echo "DISPLAY LOOKS OK"
#else
#echo "DISPLAY IS DEAD"
#sudo ./thermalcameras start
#sleep 1
#echo "I think Display is now going on"
echo "Threshold : $threshold "
if [ $threshold -gt `cat ./CPUt.txt` ]; then
    echo "THERMAL DISPLAY IS DEAD. Need to reboot the App."
else
    if [ $threshold -gt `cat ./CPUv.txt` ]; then
    echo "VISIBLE DISPLAY IS DEAD. Need to reboot the App."
    else
    echo "OK"
    fi
fi
#fi


