FROM pps11139483/pps-ra3:ra3_1-tarea-1.4

# Creamos el directorio para el certificado y lo generamos
# Usamos -subj para que no se pare a hacernos preguntas durante el build
RUN mkdir -p /etc/apache2/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/apache.key \
    -out /etc/apache2/ssl/apache.crt \
    -subj "/C=ES/ST=Castellon/L=Castellon de la Plana/O=Caminas Web Projects/OU=Departammento de Informatica/CN=www.midominioseguro.com"

# Editamos default-ssl.conf reemplazando las rutas 'snakeoil' por las nuevas
RUN sed -i 's|/etc/ssl/certs/ssl-cert-snakeoil.pem|/etc/apache2/ssl/apache.crt|g' /etc/apache2/sites-available/default-ssl.conf && \
    sed -i 's|/etc/ssl/private/ssl-cert-snakeoil.key|/etc/apache2/ssl/apache.key|g' /etc/apache2/sites-available/default-ssl.conf

# Redirección permanente de HTTP (80) a HTTPS (443) modificando el sitio por defecto
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Exponemos ambos puertos
EXPOSE 80 443

# El comando de inicio sigue siendo el mismo que en la imagen base