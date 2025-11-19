# --- Build stage ---------------------------------------------------
FROM php:8.2-fpm AS build

RUN apt-get update && apt-get install -y \
    curl zip unzip git \
    && docker-php-ext-install pdo_mysql

# Composer
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --optimize-autoloader --no-dev

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install \
    && npm run build

# --- Production stage ----------------------------------------------
FROM php:8.2-fpm

RUN docker-php-ext-install pdo_mysql

WORKDIR /srv/app
COPY --from=build /var/www/html /srv/app

# Variáveis de ambiente obrigatórias (SEM comentários ao lado)
ENV APP_ENV=production
ENV APP_KEY=base64:W4eJciLRVvcVwJgQZ0MxVdzQvFom1nF528Qf3p9mC1g=
ENV APP_DEBUG=false
ENV LOG_CHANNEL=stderr

RUN chmod -R 777 /srv/app/storage /srv/app/bootstrap/cache

# Inicia o PHP interno
CMD ["php", "-S", "0.0.0.0:10000", "-t", "public"]
