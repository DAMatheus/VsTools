# --- Build stage ---------------------------------------------------
FROM php:8.2-fpm AS build

RUN apt-get update && apt-get install -y \
    curl zip unzip git \
    && docker-php-ext-install pdo_mysql

# Instala Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Copia arquivos do projeto
WORKDIR /var/www/html
COPY . .

# Instala dependências PHP
RUN composer install --optimize-autoloader --no-dev

# Instala dependências Node e builda assets
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install \
    && npm run build

# --- Production stage ------------------------------------------------
FROM php:8.2-fpm

RUN docker-php-ext-install pdo_mysql

WORKDIR /var/www/html

COPY --from=build /var/www/html /var/www/html

# Laravel permissions
RUN chown -R www-data:www-data storage bootstrap/cache

CMD ["php", "-S", "0.0.0.0:10000", "-t", "public"]
