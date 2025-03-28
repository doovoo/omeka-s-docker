FROM php:8.0.18-apache

RUN a2enmod rewrite

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get -qq update && apt-get -qq -y --no-install-recommends install \
    curl \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng-dev \
    libjpeg-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick

# install the PHP extensions we need
RUN docker-php-ext-install -j$(nproc) iconv \
    pdo pdo_mysql mysqli gd
RUN	docker-php-ext-configure gd --with-freetype --with-jpeg

RUN curl -J -L -s -k \
    'https://github.com/omeka/omeka-s/releases/download/v3.2.0/omeka-s-3.2.0.zip' \
    -o /var/www/omeka-s.zip \
&&  unzip -q /var/www/omeka-s.zip -d /var/www/ \
&&  rm /var/www/omeka-s.zip \
&&  rm -rf /var/www/html \
&&  mv /var/www/omeka-s /var/www/html \
&&  chown -R www-data:www-data /var/www/html

COPY ./database.ini /var/www/html/config/database.ini
COPY ./imagemagick-policy.xml /etc/ImageMagick/policy.xml
COPY ./.htaccess /var/www/html/.htaccess

VOLUME /var/www/html

CMD ["apache2-foreground"]
