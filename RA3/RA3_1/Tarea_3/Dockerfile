# Partimos de la imagen que ya tiene SSL y Hardening
FROM pps11139483/pps-ra3:ra3_1-tarea-2

# TAREA 3: HARDENING DE APACHE

# Deshabilitar el listado de directorios y lectura de .htaccess 
# Cambiamos 'AllowOverride All' a 'None' para que no se salten nuestra seguridad con .htaccess
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride.*/AllowOverride None/' /etc/apache2/apache2.conf && \
    sed -i 's/Options Indexes FollowSymLinks/Options -Indexes -Includes/' /etc/apache2/apache2.conf

# Protección contra ETag (evita fuga de información de inodos) 
RUN echo "FileETag None" >> /etc/apache2/apache2.conf

# Limitar métodos HTTP (Solo permitir GET, POST y HEAD) 
# Esto bloquea métodos peligrosos como TRACE, PUT o DELETE
COPY limit-methods.conf /etc/apache2/conf-available/limit-methods.conf
RUN a2enconf limit-methods

# Deshabilitar TRACE para evitar ataques Cross-Site Tracing (XST) 
RUN echo "TraceEnable off" >> /etc/apache2/apache2.conf

# Cabeceras de seguridad adicionales (Best Practices) 
# - X-Frame-Options: Evita Clickjacking
# - X-XSS-Protection: Filtro contra XSS en el navegador
# - Cookies: Añade flags Secure y HttpOnly (requiere mod_headers ya activo)
RUN echo 'Header always append X-Frame-Options SAMEORIGIN' >> /etc/apache2/conf-available/security-headers.conf && \
    echo 'Header set X-XSS-Protection "1; mode=block"' >> /etc/apache2/conf-available/security-headers.conf && \
    echo 'Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure' >> /etc/apache2/conf-available/security-headers.conf

# Configurar Timeouts para mitigar ataques DoS (Slowloris) 
# Bajamos el tiempo de espera de 300 a 60 segundos
RUN sed -i 's/^Timeout .*/Timeout 60/' /etc/apache2/apache2.conf

# Hardening de Ciphers SSL (Solo algoritmos fuertes) 
# Esto sobreescribe la configuración de la Práctica 2 con valores más estrictos
RUN sed -i 's/SSLCipherSuite .*/SSLCipherSuite HIGH:!MEDIUM:!aNULL:!MD5:!RC4/' /etc/apache2/sites-available/default-ssl.conf && \
    sed -i 's/SSLProtocol .*/SSLProtocol -all +TLSv1.2/' /etc/apache2/sites-available/default-ssl.conf

# Cambiar el Banner del servidor con ModSecurity 
# Requiere que ServerTokens esté en 'Full' para que ModSecurity pueda manipularlo
RUN mkdir -p /etc/apache2/modsecurity && \
    sed -i 's/ServerTokens Prod/ServerTokens Full/' /etc/apache2/apache2.conf && \
    echo 'SecServerSignature "Servidor_Seguro_PPS"' >> /etc/apache2/modsecurity/modsecurity.conf

# Bloqueo de protocolo HTTP 1.0 (Obligar uso de HTTP 1.1)
# Requiere mod_rewrite habilitado
RUN a2enmod rewrite
COPY block-http10.conf /etc/apache2/conf-available/block-http10.conf
RUN a2enconf block-http10

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

# Los puertos y el arranque se heredan de la imagen anterior

# TAREA 3.1: Deshabilitar módulos no deseados (WebDAV e Info)
RUN a2dismod -f autoindex dav dav_fs info

# TAREA 3.2: Configurar Access Logging (Tiempo de respuesta y SessionID)
# Modificamos el formato 'common' para incluir %T (tiempo) y %{sessionID}C (cookie de sesión)
RUN sed -i 's/LogFormat .* common/LogFormat "%h %l %u %t \\"%{sessionID}C\\" \\"%r\\" %>s %b %T" common/' /etc/apache2/apache2.conf

# TAREA 3.3: Configurar ModSecurity Audit Log
# Activamos el motor de auditoría y definimos la ruta del log
RUN echo "SecAuditEngine On" >> /etc/apache2/modsecurity/modsecurity.conf && \
    echo "SecAuditLog /var/log/apache2/modsec_audit.log" >> /etc/apache2/modsecurity/modsecurity.conf