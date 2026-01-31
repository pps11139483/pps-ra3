FROM ubuntu:latest

# Evitar preguntas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalamos Apache y los módulos necesarios: ModSecurity y ModEvasive
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install apache2 -y && \
    apt-get clean

# EJERCICIO 1: HARDENING BÁSICO Y CSP

# Deshabilitar el módulo autoindex para evitar listado de directorios
RUN a2dismod autoindex -f

# Habilitar módulos necesarios
RUN a2enmod headers ssl

# Habilitar cabeceras y ocultar versión del servidor
COPY apache2.conf /etc/apache2/apache2.conf

# Configurar CSP básica
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Activar el sitio SSL por defecto
RUN a2ensite default-ssl

# Expone los puertos
EXPOSE 80 443

# Arrancar Apache en primer plano
CMD ["apachectl", "-D", "FOREGROUND"]