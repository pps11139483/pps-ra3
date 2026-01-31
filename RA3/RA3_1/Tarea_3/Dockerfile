# Partimos de la imagen que ya tiene SSL y Hardening
FROM pps11139483/pps-ra3:ra3_1-tarea-2

# TAREA 3: HARDENING DE APACHE

# Protección contra ETag, Trace deshabilitado, Timeout reducido
# 'AllowOverride All' cambiado a 'None' para que no se salten nuestra seguridad con .htaccess
# y formato declogs 'common' modificado para incluir información de tiempo y cookie de sesión
COPY apache2.conf /etc/apache2/apache2.conf

# Limitar métodos HTTP (Solo permitir GET, POST y HEAD) 
# Esto bloquea métodos peligrosos como TRACE, PUT o DELETE
COPY limit-methods.conf /etc/apache2/conf-available/limit-methods.conf
RUN a2enconf limit-methods

# Cabeceras de seguridad adicionales (Best Practices) 
# - X-Frame-Options: Evita Clickjacking
# - X-XSS-Protection: Filtro contra XSS en el navegador
# - Cookies: Añade flags Secure y HttpOnly (requiere mod_headers ya activo)
RUN a2enmod headers
COPY security-headers.conf /etc/apache2/conf-available/security-headers.conf
RUN a2enconf security-headers

# Sitio seguro con hardening de Ciphers SSL (Solo algoritmos fuertes) 
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Cambiar el Banner del servidor con ModSecurity 
# Requiere que ServerTokens esté en 'Full' para que ModSecurity pueda manipularlo
# Activamos el motor de auditoría y definimos la ruta del log
RUN a2enmod security2
RUN mkdir -p /etc/apache2/modsecurity
COPY modsecurity.conf /etc/modsecurity/modsecurity.conf

# Bloqueo de protocolo HTTP 1.0 (Obligar uso de HTTP 1.1)
# Requiere mod_rewrite habilitado
RUN a2enmod rewrite
COPY block-http10.conf /etc/apache2/conf-available/block-http10.conf
RUN a2enconf block-http10

# Deshabilitar módulos no deseados (WebDAV e Info)
RUN a2dismod -f autoindex dav dav_fs info

# Protección de permisos de directorios de sistema y configuración
# Restringimos acceso a binarios y carpetas de configuración (750)
RUN chmod -R 750 /etc/apache2 /var/log/apache2 /usr/sbin/apache2

# Ejecutar Apache con un usuario no privilegiado (Hardening)
# Creamos el usuario y grupo 'apache' y configuramos Apache para usarlo
RUN groupadd apache && useradd -g apache apache
ENV APACHE_RUN_USER apache
ENV APACHE_RUN_GROUP apache

# Ajustamos la propiedad de directorios críticos para el nuevo usuario
RUN chown -R apache:apache /var/www/html /var/log/apache2 /var/run/apache2 /var/lock/apache2

# Crear un script de entrada que source las variables de entorno y ejecute Apache como usuario no privilegiado
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Usar el script de entrada que configurará el usuario no privilegiado
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

