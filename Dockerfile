# Dockerfile
FROM php:8.2-apache

# System deps (intl, zip, gd, mbstring, soap, xml) + unzip + curl + git + wget
RUN apt-get update && apt-get install -y \
    libicu-dev libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libonig-dev libxml2-dev unzip curl git wget \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" gd intl zip mysqli pdo pdo_mysql mbstring xml soap \
 && a2enmod rewrite headers \
 && rm -rf /var/lib/apt/lists/*

# --- SuiteCRM version (match an official release tag) ---
ARG SUITECRM_VERSION=8.8.1

# Project root inside the container
WORKDIR /var/www/html

# Download & extract the official prebuilt package (safe across folder names)
RUN set -eux; \
    url="https://github.com/salesagility/SuiteCRM-Core/releases/download/v${SUITECRM_VERSION}/SuiteCRM-${SUITECRM_VERSION}.zip"; \
    echo "Downloading: $url"; \
    curl -fL -o /tmp/suitecrm.zip "$url"; \
    mkdir -p /tmp/src; \
    unzip -q /tmp/suitecrm.zip -d /tmp/src; \
    SUITE_DIR="$(find /tmp/src -maxdepth 1 -type d -name 'SuiteCRM-*' | head -n1)"; \
    test -n "$SUITE_DIR"; \
    cp -a "$SUITE_DIR"/. /var/www/html/; \
    rm -rf /tmp/suitecrm.zip /tmp/src

# Point Apache DocumentRoot to /public (SuiteCRM 8 requirement)
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/public#g' /etc/apache2/sites-available/000-default.conf \
 && printf '<Directory "/var/www/html/public">\n\tAllowOverride All\n\tRequire all granted\n</Directory>\n' \
    > /etc/apache2/conf-available/suitecrm-public.conf \
 && a2enconf suitecrm-public

# Default permissions (installer will also adjust as needed)
RUN chown -R www-data:www-data /var/www/html \
 && find . -type d -not -perm 2755 -exec chmod 2755 {} \; \
 && find . -type f -not -perm 0644 -exec chmod 0644 {} \; \
 && chmod +x bin/console || true

ENV APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data
EXPOSE 80
CMD ["apache2-foreground"]
