#!/bin/bash

# defaults
RTMPSECRET="stream"
ADMINPASSWORD="password1"

for i in "$@"
do
	case $i in
		--secret=*)
		RTMPSECRET="${i#*=}"
		;;
		--streams=*)
		STREAMS="${i#*=}"
		;;
		*)
		;;
	esac
done

STREAMS="push ${STREAMS//;/;\npush }"

echo "rtmp {
    server {
        listen 1935;
        chunk_size 4000;
        application $RTMPSECRET {
            live on;
			$STREAMS;
        }
    }
}
events {}
http {
    server {
        listen      8080;
        location / {
			gzip off;
			fastcgi_pass  unix:/var/run/fcgiwrap.sock;
			fastcgi_intercept_errors on;
			include /usr/local/nginx/conf/fastcgi_params;
        }
    }
}" > /usr/local/nginx/conf/nginx.conf


if [ -S /var/run/fcgiwrap.sock ]; then
    /usr/local/nginx/sbin/nginx -s reload
else
    spawn-fcgi -s /var/run/fcgiwrap.sock /usr/sbin/fcgiwrap
	/usr/local/nginx/sbin/nginx -g 'daemon off;'
fi
exit 0