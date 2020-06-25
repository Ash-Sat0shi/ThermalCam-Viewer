#!/bin/bash

cd `dirname $0`

sudo chmod 755 thermalcameras
sudo cp config.txt /boot/
sudo cp rc.local /etc/
sudo cp timesyncd.conf /etc/systemd/
sudo cp dhcpcd.conf /etc/

sudo systemctl daemon-reload
sudo timedatectl set-ntp true
sudo systemctl restart systemd-timesyncd.service

sudo crontab -r
(sudo crontab -l; echo "*/1 * * * * sudo /home/pi/thermalcameras repair") | sudo crontab -
#(sudo crontab -l; echo "*/10 * * * * sudo /home/pi/thermalcameras log") | sudo crontab -
(sudo crontab -l; echo "01 00 * * * sudo /sbin/reboot") | sudo crontab -
(sudo crontab -l; echo "02 */1 * * * sudo /home/pi/thermalcameras mail") | sudo crontab -
(sudo crontab -l; echo "03 */3 * * * sudo killall omxplayer && sudo /home/pi/thermalcameras repair") | sudo crontab -


sudo apt update && sudo apt install -y omxplayer screen bc arp-scan && sudo reboot now

