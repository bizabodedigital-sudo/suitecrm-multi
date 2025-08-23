FROM php:8.2-apache

# System deps (intl, zip, gd, mbstring, soap, xml) + cron + unzip + curl
RUN apt-get update && apt-get install -y \
    libicu-dev libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
    libonig-dev libxml2-dev cron unzip curl git rsync wget \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd intl zip mysqli pdo pdo_mysql mbstring xml soap \
 && a2enmod rewrite headers && rm -rf /var/lib/apt/lists/*

# SuiteCRM version from official releases (see SuiteCRM-Core GitHub releases)
ARG SUITECRM_VERSION=8.7.1
WORKDIR /var/www/html

# Download + unpack official release archive
RUN wget -qO /tmp/suitecrm.zip \
    "https://github.com/salesagility/SuiteCRM-Core/releases/download/v${SUITECRM_VERSION}/SuiteCRM-${SUITECRM_VERSION}.zip" \
 && unzip -q /tmp/suitecrm.zip -d /tmp \
 && rsync -a /tmp/SuiteCRM-${SUITECRM_VERSION}/ . \
 && rm -rf /tmp/suitecrm.zip /tmp/SuiteCRM-${SUITECRM_VERSION}

# Apache vhost: point DocumentRoot to /public (SuiteCRM 8 requirement)
RUN sed -i 's#DocumentRoot /var/www/html#DocumentRoot /var/www/html/public#g' /etc/apache2/sites-available/000-default.conf \
 && printf '<Directory "/var/www/html/public">\n\tAllowOverride All\n\tRequire all granted\n</Directory>\n' \
    >> /etc/apache2/conf-available/suitecrm-public.conf \
 && a2enconf suitecrm-public

# Default permissions (installer will also adjust)
RUN chown -R www-data:www-data /var/www/html \
 && find . -type d -not -perm 2755 -exec chmod 2755 {} \; \
 && find . -type f -not -perm 0644 -exec chmod 0644 {} \; \
 && chmod +x bin/console

ENV APACHE_RUN_USER=www-data APACHE_RUN_GROUP=www-data
EXPOSE 80
CMD ["apache2-foreground"]
