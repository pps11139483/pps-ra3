FROM ubuntu:latest

# Evitar preguntas
ENV DEBIAN_FRONTEND=noninteractive

# Instalar Nginx, ModSecurity, PHP-FPM, Git y Curl
RUN apt-get update && \
    apt-get install -y nginx libnginx-mod-http-modsecurity php-fpm ssl-cert git curl ca-certificates && \
    apt-get clean

# Configuración WAF (OWASP CRS)
# Borramos carpeta por si acaso y clonamos OWASP
RUN rm -rf /usr/share/modsecurity-crs && \
    git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs

# Copiamos el setup de ejemplo del CRS
RUN mv /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf

# Configuración del Motor ModSecurity
# Descargamos el archivo de configuración
RUN mkdir -p /etc/modsecurity && \
    curl -o /etc/modsecurity/modsecurity.conf https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended && \
    curl -o /etc/modsecurity/unicode.mapping https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/unicode.mapping

# Activamos el modo bloqueo (SecRuleEngine On)
RUN sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf

# Archivo maestro de inclusión de reglas para Nginx
RUN echo "Include /etc/modsecurity/modsecurity.conf" > /etc/nginx/modsec_includes.conf && \
    echo "Include /usr/share/modsecurity-crs/crs-setup.conf" >> /etc/nginx/modsec_includes.conf && \
    echo "Include /usr/share/modsecurity-crs/rules/*.conf" >> /etc/nginx/modsec_includes.conf

# Copiamos nuestra configuración personalizada de Nginx
COPY default.conf /etc/nginx/conf.d/default.conf

# Eliminamos el default de nginx para evitar conflictos
RUN rm /etc/nginx/sites-enabled/default

# Copiamos el index.html y post.php
COPY index.html /var/www/html/index.html
COPY post.php /var/www/html/post.php
RUN chown -R www-data:www-data /var/www/html /var/run/php

EXPOSE 80 443

# Necesitamos arrancar fpm y nginx
CMD ["sh", "-c", "service php8.3-fpm start && nginx -g 'daemon off;'"]