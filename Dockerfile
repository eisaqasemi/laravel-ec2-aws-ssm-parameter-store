FROM php:7.3-apache-buster
RUN apt-get update -y && apt-get install -y libmcrypt-dev openssl
RUN docker-php-ext-install pdo mbstring
RUN pecl install mcrypt-1.0.3
RUN docker-php-ext-enable mcrypt
RUN apt-get install -y curl
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
WORKDIR /app
COPY . /app
RUN composer install
CMD php artisan config:cache && php artisan serve --host=0.0.0.0 --port=8000
EXPOSE 8000
