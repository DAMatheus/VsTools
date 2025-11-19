# Build stage
FROM php:8.2-cli AS build

RUN apt-get update && apt-get install -y \
    curl zip unzip git \
    && docker-php-ext-install pdo_mysql

COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

WORKDIR /app
COPY . .

RUN composer install --no-dev --optimize-autoloader

# Instala Node e builda o front-end
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install \
    && npm run build


# Runtime stage
FROM php:8.2-cli

WORKDIR /app

COPY --from=build /app /app

# Permissões para storage
RUN chmod -R 777 storage bootstrap/cache

# Variáveis padrões do Laravel sem .env
ENV APP_ENV=production
ENV APP_KEY=base64:W4eJciLRVvcVwJgQZ0MxVdzQvFom1nF528Qf3p9mC1g=   # Gerei uma chave para você
ENV APP_DEBUG=false
ENV LOG_CHANNEL=stderr

# Porta obrigatória no Render
ENV PORT=10000

EXPOSE 10000

# Start Laravel server
CMD php artisan serve --host=0.0.0.0 --port=$PORT
