#!/bin/bash

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

# STREAMS="push ${STREAMS//;/;\npush }"

echo "rtmp {
    server {
        listen 1935;
        chunk_size 4000;
        application $RTMPSECRET {
            live on;" > /usr/local/nginx/conf/nginx.conf

IFS=';' #setting comma as delimiter
read -a streamarr <<<"$STREAMS"

for stream in "${streamarr[@]}"
do
   echo "push $stream;" >> /usr/local/nginx/conf/nginx.conf
done

echo "        }
    }
}
events {}
http {
	index index.sh;
    server {
		listen              443 ssl;
		keepalive_timeout   70;
		ssl_certificate     /usr/local/nginx/fah.cert;
		ssl_certificate_key /usr/local/nginx/fah.key;
		ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
		ssl_ciphers         HIGH:!aNULL:!MD5;
		

	
        location / {
			auth_basic 'Administrators Area';
			auth_basic_user_file /usr/local/nginx/.htpasswd;		
			gzip off;
			fastcgi_pass  unix:/var/run/fcgiwrap.sock;
			fastcgi_intercept_errors on;
			include /usr/local/nginx/conf/fastcgi_params;
        }
    }
}"  >> /usr/local/nginx/conf/nginx.conf


if [ -S /var/run/fcgiwrap.sock ]; then
    /usr/local/nginx/sbin/nginx -s reload
else
	openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=US/ST=WA/L=REDMOND/O=Dis/CN=www.example.com" -keyout /usr/local/nginx/fah.key  -out /usr/local/nginx/fah.cert
	htpasswd -b -c /usr/local/nginx/.htpasswd admin $PASSWORD
    spawn-fcgi -s /var/run/fcgiwrap.sock /usr/sbin/fcgiwrap
	/usr/local/nginx/sbin/nginx -g 'daemon off;'
fi
exit 0