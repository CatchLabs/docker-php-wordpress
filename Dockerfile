# mainly from: https://github.com/docker-library/wordpress/blob/master/php5.6/fpm/Dockerfile
FROM php:5.6-fpm

# Use apt mirror server in china
RUN sed -i 's/httpredir.debian.org/mirrors.aliyun.com/' /etc/apt/sources.list

# install the PHP extensions we need
RUN apt-get update && apt-get install -y php5 libpng12-dev libjpeg-dev && rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

# set upload size
RUN sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php5/fpm/php.ini
RUN sed -i 's/upload_max_filesize = 100M/upload_max_filesize= 100M/' /etc/php5/fpm/php.ini

# set listen port
RUN sed -i 's/^listen =/;listen =/' /etc/php5/fpm/pool.d/www.conf
RUN echo "listen = 127.0.0.1:9000" >> /etc/php5/fpm/pool.d/www.conf
	
RUN mkdir -p /var/www/html && chown -R www-data: /var/www/html
VOLUME /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat

EXPOSE 9000

# ENTRYPOINT resets CMD
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
