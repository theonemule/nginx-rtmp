FROM ubuntu:18.04
COPY conf.sh /usr/local/nginx/html/conf.sh
COPY index.sh /usr/local/nginx/html/index.sh
RUN apt-get update && \
	apt-get install -y wget tar apt-utils autoconf automake build-essential git libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre++-dev libtool libxml2-dev libssl-dev libyajl-dev pkgconf zlib1g-dev fcgiwrap apache2-utils openssl && \
	git clone https://github.com/arut/nginx-rtmp-module.git && \
	wget http://nginx.org/download/nginx-1.18.0.tar.gz && \
	tar zxvf nginx-1.18.0.tar.gz && \
	cd nginx-1.18.0 && \
	./configure  --user=root --group=root --with-ipv6 --with-http_ssl_module  --with-compat --add-module=/nginx-rtmp-module  && \
	make && \
	make install && \
	cd / && \	
	apt-get remove -y --purge apt-utils autoconf automake build-essential git pkgconf && \
	apt-get autoremove -y && \
	rm /nginx-1.18.0.tar.gz && \
	chmod +x /usr/local/nginx/html/conf.sh && \
	chmod +x /usr/local/nginx/html/index.sh
CMD /usr/local/nginx/html/conf.sh
EXPOSE 1935 443
