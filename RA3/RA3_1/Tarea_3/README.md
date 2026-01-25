# Tarea 3

En esta tarea se han aplicado diversas medidas de **hardening** (fortalecimiento) en nuestro servidor Apache, basándonos en las recomendaciones de seguridad de la guía de Geekflare. Estas medidas buscan minimizar la superficie de ataque y proteger el servidor contra vulnerabilidades comunes.

## Explicación

Para comenzar, se ha configurado el servidor para restringir el acceso y la visibilidad de archivos críticos. Mediante la directiva `AllowOverride None`, deshabilitamos el uso de archivos `.htaccess`, lo que evita que configuraciones locales puedan saltarse las directivas de seguridad globales. Además, se desactivó el listado automático de directorios con `Options -Indexes` para que los usuarios no puedan ver la estructura de carpetas si no existe un archivo de índice, y se han eliminado los *Server Side Includes* con `-Includes` para reducir riesgos de ejecución de código.

```dockerfile
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride.*/AllowOverride None/' /etc/apache2/apache2.conf && \
    sed -i 's/Options Indexes FollowSymLinks/Options -Indexes -Includes/' /etc/apache2/apache2.conf
```

Para evitar la fuga de información sensible, se han desactivado los **ETags** con la directiva `FileETag None`. Esto impide que el servidor revele atributos internos de los archivos, como el número de inodo, que podrían ser utilizados para deducir detalles del sistema de archivos.

```dockerfile
RUN echo "FileETag None" >> /etc/apache2/apache2.conf
```

En cuanto a la gestión de peticiones, se han restringido los métodos HTTP permitidos únicamente a **GET, POST y HEAD**. Al definir este límite en un archivo de configuración específico, bloqueamos métodos potencialmente peligrosos como `PUT`, `DELETE` o `CONNECT` que no son necesarios para el funcionamiento normal de la web.

```apache
<Directory "/var/www/html">
    <LimitExcept GET POST HEAD>
        deny from all
    </LimitExcept>
</Directory>
```

Asimismo, se ha deshabilitado explícitamente el método **TRACE** (`TraceEnable off`), protegiendo al servidor contra ataques de *Cross-Site Tracing* (XST) que intentan robar cookies de sesión HTTP.

```dockerfile
RUN echo "TraceEnable off" >> /etc/apache2/apache2.conf
```

Para fortalecer la seguridad en el navegador del usuario, se han inyectado varias **cabeceras de seguridad**. La cabecera `X-Frame-Options SAMEORIGIN` previene ataques de *Clickjacking* al prohibir que nuestro sitio sea embebido en iframes externos. Con `X-XSS-Protection`, activamos los filtros contra ataques XSS en navegadores antiguos, y mediante la edición de `Set-Cookie`, se asegura que todas las cookies se envíen con los flags `HttpOnly` (inaccesibles para scripts) y `Secure` (solo transmitidas por HTTPS).

```dockerfile
RUN echo 'Header always append X-Frame-Options SAMEORIGIN' >> /etc/apache2/conf-available/security-headers.conf && \
    echo 'Header set X-XSS-Protection "1; mode=block"' >> /etc/apache2/conf-available/security-headers.conf && \
    echo 'Header edit Set-Cookie ^(.*)$ $1;HttpOnly;Secure' >> /etc/apache2/conf-available/security-headers.conf
```

Para mitigar ataques de **Denegación de Servicio (DoS)** como *Slowloris*, se ha reducido el tiempo de `Timeout` a 60 segundos, forzando el cierre de conexiones inactivas más rápidamente y liberando recursos para otros usuarios legítimos.

```dockerfile
RUN sed -i 's/^Timeout .*/Timeout 60/' /etc/apache2/apache2.conf
```

La seguridad de las comunicaciones se ha reforzado mediante el **Hardening de Ciphers SSL**. Se ha configurado el servidor para aceptar exclusivamente TLS 1.2 o superior, eliminando protocolos obsoletos, y se ha definido una suite de cifrado fuerte (`HIGH:!MEDIUM:!aNULL:!MD5:!RC4`) para evitar el uso de algoritmos vulnerables.

```dockerfile
RUN sed -i 's/SSLCipherSuite .*/SSLCipherSuite HIGH:!MEDIUM:!aNULL:!MD5:!RC4/' /etc/apache2/sites-available/default-ssl.conf && \
    sed -i 's/SSLProtocol .*/SSLProtocol -all +TLSv1.2/' /etc/apache2/sites-available/default-ssl.conf
```

Una medida adicional de ofuscación ha sido camuflar el banner del servidor. Aunque inicialmente se configuró `ServerTokens Prod`, en esta tarea se ha utilizado **ModSecurity** para modificar la firma del servidor a "Servidor_Seguro_PPS", dificultando el reconocimiento de la tecnología subyacente por parte de atacantes.

```dockerfile
RUN mkdir -p /etc/apache2/modsecurity && \
    sed -i 's/ServerTokens Prod/ServerTokens Full/' /etc/apache2/apache2.conf && \
    echo 'SecServerSignature "Servidor_Seguro_PPS"' >> /etc/apache2/modsecurity/modsecurity.conf
```

También se ha bloqueado el protocolo **HTTP 1.0**, obligando a todos los clientes a utilizar HTTP 1.1. Esto se consigue mediante reglas de reescritura que deniegan cualquier petición que no cumpla con esta versión del protocolo, asegurando que se beneficien de las mejoras de seguridad y rendimiento de las versiones más modernas.

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{THE_REQUEST} !HTTP/1\.1$
    RewriteRule .* - [F]
</IfModule>
```

Finalmente, se han aplicado principios de mínimos privilegios en los sistemas de archivos, restringiendo los **permisos de directorios** críticos. Al establecer el permiso `750` en las carpetas de configuración, binarios y logs, garantizamos que solo el propietario y su grupo tengan acceso controlado, protegiendo al sistema de accesos no autorizados por parte de otros usuarios locales.

```dockerfile
RUN chmod -R 750 /etc/apache2 /var/log/apache2 /usr/sbin/apache2
```

Para elevar aún más la seguridad, se ha configurado Apache para ejecutarse con un **usuario no privilegiado** creado específicamente para esta tarea (`apache:apache`). Al no utilizar el usuario por defecto del sistema (`www-data`), reducimos el impacto potencial en caso de que un atacante logre comprometer el proceso del servidor, limitando su capacidad de movimiento lateral dentro del contenedor.

```dockerfile
RUN groupadd apache && useradd -g apache apache
ENV APACHE_RUN_USER apache
ENV APACHE_RUN_GROUP apache
RUN chown -R apache:apache /var/www/html /var/log/apache2 /var/run/apache2 /var/lock/apache2
```

### Tabla resumen

| Tarea | Implementación |
| --- | --- |
| Remove Server Version Banner | Implementado en Tarea 1.1 |
| Disable directory browser listing | x |
| Etag | x |
| Run Apache from a non-privileged account | x |
| Protect binary and configuration directory permissions | x |
| System Settings Protection | x |
| HTTP Request Methods | x |
| Disable Trace HTTP Request | x |
| Set cookie with HttpOnly and Secure flag | x |
| Clickjacking Attack | x |
| Server Side Include | x |
| X-XSS Protection | x |
| Disable HTTP 1.0 Protocol | x |
| Timeout value configuration | x |
| SSL Key | Implementado en Tarea 2 |
| SSL Cipher | x |
| Disable SSL v2 & v3 | x |
| ModSecurity | Implementado en Tareas 1.2 y 1.3 |
| ModSecurity Logging | x |
| Change Server Banner | x |
| Configure Listen Port | x |
| Access Logging | x |
| Disable Loading unwanted modules | x |

## Pull

```bash
docker pull pps11139483/pps-ra3:ra3_1-tarea-3
```

## Ejecución

```bash
docker run -d -p 8443:443 --name tarea2 pps11139483/pps-ra3:ra3_1-tarea-3
```

## Pruebas y validación

### 1. Prueba 1
**Comando:** 

```bash
curl -I http://localhost:8080/
```

**Resultado esperado:**

```bash
HTTP/1.1 301 Moved Permanently
```

## Capturas

> Captura de la prueba 1
![Prueba 1](capturas/prueba1.png)

## Fuentes

*   [GeekFlare - Apache Web Server Hardening and Security Gudie](https://geekflare.com/cybersecurity/apache-web-server-hardening-security/)
