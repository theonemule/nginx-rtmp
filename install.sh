#!/bin/bash
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io


for i in "$@"
do
	case $i in
			--secret=*)
			RTMPSECRET="${i#*=}"
			;;
			--streams=*)
			STREAMS="${i#*=}"
			;;
			--password=*)
			PASSWORD="${i#*=}"
			;;			
			*)
			;;
	esac
done

docker run -p 1935:1935 -p 443:443 -e STREAMS=$STREAMS  -e RTMPSECRET=$RTMPSECRET -e PASSWORD=$PASSWORD --restart always blaize/nginx-rtmp
exit 0