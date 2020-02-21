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

COPY ./php.ini /usr/local/etc/php/

RUN usermod -u 1000 www-data

WORKDIR /var/www
