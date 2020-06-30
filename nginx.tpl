rtmp {
    server {
        listen 1935;
        chunk_size 4000;
        application stream {
            live on;
            push rtmp://a.rtmp.youtube.com/live2/6gak-rcme-d5tq-r72j-5jmb;
        }
    }
}
events {}
http {
    server {
        listen      80;
		location /stream/ {
			gzip off;
			root  /usr/lib/cgi-bin/;
			fastcgi_pass  unix:/var/run/fcgiwrap.socket;
			include /usr/local/nginx/fastcgi_params;
			fastcgi_param $document_root$fastcgi_script_name;
		}				
    }
}