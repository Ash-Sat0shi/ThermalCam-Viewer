#!/usr/bin python3
# -*- coding: utf-8 -*-
import smtplib
import os
from email.utils import formatdate

# for Japanese content
from email.mime.text import MIMEText

f = open('CAMIP.txt')
camip = f.read()
# print(camip)
f.close()
myip = os.popen('ip addr show eth0').read().split("inet ")[1].split("/")[0]

if __name__ == "__main__":
	# Gmail Account Settings
	gmail_addr = "shinshuthermal@gmail.com"
	gmail_pass = "soya4462"
	SMTP = "smtp.gmail.com"
	PORT = 587
		
	# Sending mail

	from_addr = gmail_addr				# sender addr
	to_addr = "satoshi.yatabe@shin-shu.co.jp"
	subject = "体温検知システム　ThermalCAM-Viewer-09"
	body = "Camera  IP Address is : {0} \n RasPi IP Address is : {1}".format(camip,myip)

	msg = MIMEText(body, "plain", "utf-8")
        # prevent 'ascii' codec can't encode characters in position 0-14: ordinal not in range(128) というエラーがでる
	msg["From"] = from_addr
	msg["To"] = to_addr
	msg["Date"] = formatdate()
	msg["Subject"] = subject
		
	# send mail
	try:
		print("sending mail...")
		send = smtplib.SMTP(SMTP, PORT)		# create SMTP object
		send.ehlo()
		send.starttls()
		send.ehlo()
		send.login(gmail_addr, gmail_pass)	# Login to Gmail
		send.send_message(msg)
		send.close()
	except Exception as e:
		print("except: " + str(e))		# in case of error
	else:
		print("Successfully sent mail to {0}".format(to_addr))	# when succeed