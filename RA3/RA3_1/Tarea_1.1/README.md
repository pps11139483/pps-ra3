# Tarea 1.1

La tarea consiste en desplegar mediante Docker un Apache HTTP Server con configuración de seguridad básica (Hardening), SSL habilitado y cabeceras de seguridad.

## Explicación

El contenedor se basa en la última versión de Ubuntu, para evitar problemas de compatibilidad de paquetes.

El primer paso ha sido la actualización de todos los paquetes y la adición de apache2:

```yaml
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install apache2 -y && \
    apt-get clean
```

Tal y como se menciona en la práctica, se ha deshabilitado el módulo autoindex, a fin de evitar que puedan listarse directorios.

```yaml
RUN a2dismod autoindex -f
```

Para la parte de HTTPS, se ha decidido utilizar los certificados `snakeoil` que Apache incluye en lugar de generar unos unos nuevos y utilizar el sitio `default-ssl`.

```yaml
# Habilitar módulos necesarios
RUN a2enmod headers ssl
...
# Activar el sitio SSL por defecto
RUN a2ensite default-ssl
```

En cuanto a la configuración de HS y CSP, se ha optado por incluir un fichero `default-ssl.conf` con las cabeceras incluídas y copiarlo dentro de la imagen:

```yaml
    # HSTS (2 años)
    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains"

    # CSP básica y restrictiva
    Header set Content-Security-Policy "default-src 'self'; img-src 'self'; script-src 'self'; style-src 'self'"
```

Por último, en cuanto a la activación de las cabeceras y la ocultación de la versión de Apache, se han incluído las siguientes directivas en `/etc/apache2/apache2.conf`:

```bash
# Habilitar cabeceras y ocultar versión del servidor
RUN echo "ServerTokens ProductOnly" >> /etc/apache2/apache2.conf && \
    echo "ServerSignature Off" >> /etc/apache2/apache2.conf
```
## Pull

```bash
docker pull pps11139483/pps-ra3:ra3_1-tarea-1.1
```

## Ejecución

```bash
docker run -p 8080:80 -p 8443:443 pps11139483/pps-ra3:ra3_1-tarea-1.1
```

## Pruebas y validación

Dado que usamos certificados *snakeoil*, es necesario usar el flag `-k` (insecure) para ignorar la advertencia de certificado no confiable.

**Comando de prueba:**

```bash
curl -k -I https://localhost:8443
```

**Output Esperado:**
Obtener un estado `200 OK` y la presencia de las cabeceras `Strict-Transport-Security` y `Content-Security-Policy`.

```http
HTTP/1.1 200 OK
Date: Thu, 22 Jan 2026 21:35:00 GMT
Server: Apache
Strict-Transport-Security: max-age=63072000; includeSubDomains
Content-Security-Policy: default-src 'self'; img-src 'self'; script-src 'self'; style-src 'self'
Content-Type: text/html
```

## Capturas



## Fuentes

- [Hardening del Servidor](https://psegarrac.github.io/Ciberseguridad-PePS/tema3/seguridad/web/2021/03/01/Hardening-Servidor.html#apache-extra)
- [AskUbuntu - What is the purpose of snakeoil](https://askubuntu.com/questions/396120/what-is-the-purpose-of-the-ssl-cert-snakeoil-key)
- [AskUbuntu - How do I turn on SSL for test server](https://askubuntu.com/questions/24829/how-do-i-turn-on-ssl-for-test-server)