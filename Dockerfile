FROM punkrock/ubuntu:20.04

RUN apt update && \
    DEBIAN_FRONTEND=noninteractive \
    apt install --no-install-recommends -y apache2 php7.2 libapache2-mod-php7.2 php7.2-mysql php7.2-gd && \
    rm -rf /var/lib/apt/lists/* && \
    chown -R www-data:www-data /var/www/html && \
    chmod 755 /var/www/html

COPY docker-entrypoint.sh /

VOLUME ["/var/www/html"]

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
