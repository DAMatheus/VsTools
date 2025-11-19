FROM php:8.2-apache

# Instala extensões básicas PHP
RUN docker-php-ext-install pdo pdo_mysql

# Ativa mod_rewrite (importante para Laravel)
RUN a2enmod rewrite

WORKDIR /var/www/html

# Copia o projeto
COPY . .

# Gera chave do Laravel direto no arquivo env do container
RUN echo "<?php return ['key' => 'base64:Vg7DmwPhlF3Qn7mSdG4aEoUo2I0Y8yvTanU5XkWxMSo='];" > config/app-key.php

# Força Laravel a usar essa chave
RUN sed -i "s/'key' => env('APP_KEY', ''),/'key' => require __DIR__.'\/app-key.php',/" config/app.php

# Dá permissão
RUN chown -R www-data:www-data storage bootstrap/cache

# Configura o Apache para permitir URLs amigáveis
RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Builda o frontend
RUN apt-get update && apt-get install -y npm
RUN npm install
RUN npm run build

EXPOSE 80

CMD ["apache2-foreground"]
