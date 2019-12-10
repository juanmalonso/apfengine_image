FROM php:7.3-apache

#ADITIONAL PHP ESTENSIONS
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libpq-dev \
        g++ \
        git \
        libicu-dev \
        libxml2-dev \
		libxslt-dev \
        libzip-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
	&& docker-php-ext-install zip \
	&& docker-php-ext-install xsl \
	&& docker-php-ext-install xmlrpc \
	&& docker-php-ext-install bcmath \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install pdo_pgsql \
    && docker-php-ext-install soap \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd

#IMAGICK
RUN apt-get update && apt-get install -y \
    libmagickwand-dev --no-install-recommends

RUN pecl install imagick \
	&& docker-php-ext-enable imagick

#REDIS
RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

#PHALCON
ARG PHALCON_VERSION=3.4.5
ARG PHALCON_EXT_PATH=php7/64bits

RUN set -xe && \
        # Compile Phalcon
        curl -LO https://github.com/phalcon/cphalcon/archive/v${PHALCON_VERSION}.tar.gz && \
        tar xzf ${PWD}/v${PHALCON_VERSION}.tar.gz && \
        docker-php-ext-install -j $(getconf _NPROCESSORS_ONLN) ${PWD}/cphalcon-${PHALCON_VERSION}/build/${PHALCON_EXT_PATH} && \
        # Remove all temp files
        rm -r \
            ${PWD}/v${PHALCON_VERSION}.tar.gz \
            ${PWD}/cphalcon-${PHALCON_VERSION}

COPY docker-phalcon-* /usr/local/bin/

#CLEAN
RUN apt-get clean \
	&& apt-get purge --auto-remove -y g++ \
	&& rm -rf /var/lib/apt/lists/*

# COMPOSER
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#CONFIGURE
RUN a2enmod rewrite

#CREATE DIRECTORIES
WORKDIR /var/www/

RUN mkdir share/

WORKDIR html/

COPY .htaccess ./

#INSTALL APPENGINE
#RUN git clone https://github.com/juanmalonso/apfengine.git

#APPLY PERMISSIONS
RUN chgrp -R www-data /var/www/html/ \
    && chmod -R 775 /var/www/html \
    && chmod -R g+s /var/www/html \
    && chown -R www-data:www-data /var/www/html