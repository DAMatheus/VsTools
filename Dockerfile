# --------------------------
# Build Stage
# --------------------------
FROM php:8.2-fpm AS build

RUN apt-get update && apt-get install -y \
    curl zip unzip git \
    && docker-php-ext-install pdo_mysql

COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html
COPY . .

RUN composer install --optimize-autoloader --no-dev

# Node + Vite build
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install \
    && npm run build

# --------------------------
# Production Stage
# --------------------------
FROM caddy:2.7

# Copia arquivos do Laravel
COPY --from=build /var/www/html /srv/app

# Copia config do Caddy
COPY Caddyfile /etc/caddy/Caddyfile

# Permissões
RUN chmod -R 777 /srv/app/storage /srv/app/bootstrap/cache

# Executa migrations no start (opcional)
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile"]
