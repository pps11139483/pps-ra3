FROM pps11139483/pps-ra3:ra3_1-tarea-1.2

# Instalamos Git para poder clonar el repositorio de OWASP
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean

# EJERCICIO 3: REGLAS DE OWASP

# Descargamos las reglas OWASP CRS (Core Rule Set)
WORKDIR /tmp
RUN git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git

# Movemos las reglas a /etc/m
RUN mkdir -p /etc/modsecurity/crs/rules && \
    cp -r owasp-modsecurity-crs/rules/* /etc/modsecurity/crs/rules && \
    mv owasp-modsecurity-crs/crs-setup.conf.example /etc/modsecurity/crs/crs-setup.conf && \
    rm -rf owasp-modsecurity-crs

# Carga explícita de reglas (sin duplicados)
RUN sed -i '/IncludeOptional \/etc\/modsecurity\/\*\.conf/a \
Include /etc/modsecurity/crs/crs-setup.conf\n\
Include /etc/modsecurity/crs/rules/*.conf' \
/etc/apache2/mods-enabled/security2.conf

# Bloquea si el parámetro "testparam" contiene "test" (ID 1234)
RUN sed -i "s|</VirtualHost>|    SecRule ARGS:testparam \"@contains test\" \"id:1234,phase:2,deny,status:403,msg:'Cazado por Ciberseguridad'\"\n</VirtualHost>|" \
/etc/apache2/sites-available/default-ssl.conf

# Volvemos al directorio web por defecto
WORKDIR /var/www/html

# CMD y EXPOSE se heredan