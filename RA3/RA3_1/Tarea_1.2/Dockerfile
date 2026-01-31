FROM pps11139483/pps-ra3:ra3_1-tarea-1.1

# Instalamos paquetes necesarios
RUN apt-get update && \
    apt-get install -y libapache2-mod-security2 php libapache2-mod-php && \
    apt-get clean

# EJERCICIO 2: INSTALANDO EL WAF

# Habilitamos la configuración por defecto de modsecurity con "DetectionOnly" a "On" (bloquea ataques)
COPY modsecurity.conf /etc/modsecurity/modsecurity.conf

# Copiamos el fichero PHP al servidor
COPY post.php /var/www/html/post.php

# El CMD y EXPOSE se heredan