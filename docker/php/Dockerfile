FROM php:7.3-fpm

#UPDATE
RUN apt-get update && apt-get install -y \
	git \
	unzip

#LIBS EXTRAS
RUN apt-get install -y \
	libzip-dev \
	libpq-dev \
	libicu-dev g++ \
	libbz2-dev \
	libxml2-dev \
	libmagickwand-dev --no-install-recommends \
	zlib1g-dev

RUN docker-php-ext-install bcmath
RUN docker-php-ext-install bz2
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install intl
RUN docker-php-ext-install exif

#IMAGICK
RUN pecl install imagick
RUN docker-php-ext-enable imagick 

#SOAP
RUN docker-php-ext-install soap

#GD
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng16-16
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-install gd

#PDO
RUN docker-php-ext-install pdo pdo_mysql mysqli zip

# Instalação e configuração do XDebug
RUN yes | pecl install xdebug-2.9.8 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_handler=dbgp" >>  /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_connect_back=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.idekey=docker" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_log=/var/log/xdebug.log" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.default_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.var_display_max_depth = -1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.var_display_max_children = -1" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.var_display_max_data = -1" >> /usr/local/etc/php/conf.d/xdebug.ini 

COPY ./php.ini /usr/local/etc/php/

RUN usermod -u 1000 www-data

WORKDIR /var/www