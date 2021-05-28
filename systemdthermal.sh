#!/bin/bash


cd `dirname $0`


#This bash need screen, bc and omxplayer. Please install them at first
#sudo apt install -y screen bc omxplayer

case "$1" in
start)

#info=$(echo `arp-scan -l --interface eth0 | grep "a4:14:37:"`)
info=$(echo `arp-scan -l --interface eth0 | grep "58:50:ed:"`)
ip=$(echo $info | cut -d " " -f1)
echo $ip > ./CAMIP.txt

CAMIP=`cat ./CAMIP.txt`

echo "Camera IP : "
echo $CAMIP

omxplayer rtsp://admin:soya4462@"$CAMIP":554/Streaming/Channels/102 --win "0 1115 1080 1920" --aspect-mode stretch --live -b -n -1 --display 5 | sleep 0.5 |
omxplayer rtsp://admin:soya4462@"$CAMIP":554/Streaming/Channels/202 --win "0 250 1080 1115" --aspect-mode stretch --live -b -n -1 --display 5 | sleep 0.5 |
omxplayer /home/pi/2.mp4 --win "0 0 1080 250" --loop -n -1 --display 5

;;

stop)
killall omxplayer
;;

chk)
omxnum=`ps aux |grep /usr/bin/omxplayer.bin |grep -v grep | wc -l`
if [ $omxnum = 3 ]; then
    echo "ALL GREEN"
else
    echo "SOMETHING WITH WRONG..."
    sudo ./systemdthermal.sh stop
fi
;;

mail)
sudo python3 ./sendGmailPi.py
sudo python3 ./sendTodamailPi.py
;;

*)
echo "Usage: ./thermalcameras {start|stop|chk|mail}"
exit 1
;;
esac
