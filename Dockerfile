# --- Build stage ---------------------------------------------------
FROM php:8.2 as build

RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev \
    && docker-php-ext-install pdo_mysql

COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY . .

RUN composer install --optimize-autoloader --no-dev

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install \
    && npm run build

# --- Production stage ---------------------------------------------------
FROM php:8.2

WORKDIR /var/www/html
COPY --from=build /var/www/html /var/www/html

RUN chmod -R 777 storage bootstrap/cache

ENV PORT 10000

CMD php -S 0.0.0.0:$PORT -t public
