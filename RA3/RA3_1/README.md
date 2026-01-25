# RA3_1: Hardening de Apache

Este repositorio contiene las tareas prácticas correspondientes al Resultado de Aprendizaje 3.1, enfocado en la implementación de medidas de seguridad en servidores web (Apache y Nginx).

## Índice de Tareas

A continuación se detallan las tareas realizadas junto con un enlace a su desarrollo.

### Práctica 1: Apache Hardening
*   **[Tarea 1.1: CSP](./Tarea_1.1/README.md)**: Configuración de seguridad básica, eliminación de información del servidor e implementación de cabeceras HTTP de seguridad (HSTS, CSP)
*   **[Tarea 1.2: Web Application Firewall](./Tarea_1.2/README.md)**: Configuración de ModSecurity para Apache con las reglas por defecto.
*   **[Tarea 1.3: OWASP](./Tarea_1.3/README.md)**: Instalación de las reglas Core Rule Set (CRS) de OWASP para proteger contra ataques comunes.
*   **[Tarea 1.4: Evitar ataques DDoS](./Tarea_1.4/README.md)**: Implementación de `mod_evasive` para mitigar ataques de denegación de servicio.
*   **[Tarea 1.5: Migración a Nginx](./Tarea_1.5/README.md)**: Replicación de todas las medidas anteriores (SSL, WAF, Anti-DoS) utilizando Nginx y PHP-FPM.

### Práctica 2: Certificados
*   **[Tarea 2: Instalar un certificado digital en Apache](./Tarea_2/README.md)**: Configuración de certificados propios y redirección forzosa de HTTP a HTTPS.

### Práctica 3: Apache Hardening Best Practices
*   **[Tarea 3: Securizar el servidor Apache](./Tarea_3/Dockerfile)**: Configuración avanzada para limitar los verbos HTTP permitidos (GET, POST) y minimizar la superficie de exposición.

## Estructura del Proyecto

Cada carpeta contiene:
1.  **Dockerfile**: Definición de la imagen con todas las dependencias e instalaciones.
2.  **Configuraciones**: Archivos `.conf` específicos para Apache o Nginx.
3.  **README.md**: Documentación detallada de la tarea, explicación técnica y guía de pruebas.
4.  **Capturas**: Evidencias del funcionamiento y validación de las medidas implementadas.

---
*Puesta en Producción Segura- RA3*
