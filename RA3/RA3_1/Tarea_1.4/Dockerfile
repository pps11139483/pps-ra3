FROM pps11139483/pps-ra3:ra3_1-tarea-1.3

# Instalar mod_evasive
RUN apt-get update && \
    apt-get install -y libapache2-mod-evasive && \
    apt-get clean

# EJERCICIO 4: ANTI DDOS CON MOD_EVASIVE

# Preparar el directorio de logs
RUN mkdir -p /var/log/mod_evasive && \
    chown -R www-data:www-data /var/log/mod_evasive

# Sobrescribimos la configuración por defecto
COPY evasive.conf /etc/apache2/mods-available/evasive.conf

# Habilitar el módulo
RUN a2enmod evasive

# CMD y EXPOSE se heredan