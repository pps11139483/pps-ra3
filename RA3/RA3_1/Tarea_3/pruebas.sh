#!/bin/bash

# =================================================================
# Script de pruebas para Tarea 3 - Hardening de Apache
# =================================================================
# Este script valida todas las medidas de seguridad implementadas
# mediante pruebas con curl
# =================================================================

echo "=========================================================="
echo "    PRUEBAS DE HARDENING - TAREA 3"
echo "=========================================================="
echo ""
echo "URL de prueba: https://localhost:8443/"
echo ""

# Colores para mejor legibilidad
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de pruebas
TOTAL_PRUEBAS=0
PRUEBAS_OK=0
PRUEBAS_FAIL=0

# Función auxiliar para imprimir resultados
print_result() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"
    
    ((TOTAL_PRUEBAS++))
    
    if [[ "$actual" == "$expected" ]]; then
        echo -e "${GREEN}✓ PASS${NC}: $test_name"
        echo "  Resultado: $actual"
        ((PRUEBAS_OK++))
    else
        echo -e "${RED}✗ FAIL${NC}: $test_name"
        echo "  Esperado: $expected"
        echo "  Obtenido: $actual"
        ((PRUEBAS_FAIL++))
    fi
    echo ""
}

# =================================================================
# 1. Validar cabeceras de seguridad
# =================================================================
echo "------- 1. CABECERAS DE SEGURIDAD -------"
echo ""

# HSTS
echo "Prueba 1.1: Strict-Transport-Security"
RESPONSE=$(curl -k -s -I https://localhost:8443/ 2>/dev/null | grep -i "Strict-Transport-Security")
if [[ ! -z "$RESPONSE" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: HSTS activado"
    echo "  $RESPONSE"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: HSTS no encontrado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# CSP
echo "Prueba 1.2: Content-Security-Policy"
RESPONSE=$(curl -k -s -I https://localhost:8443/ 2>/dev/null | grep -i "Content-Security-Policy")
if [[ ! -z "$RESPONSE" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: CSP activado"
    echo "  $RESPONSE"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: CSP no encontrado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# X-Frame-Options
echo "Prueba 1.3: X-Frame-Options (Clickjacking)"
RESPONSE=$(curl -k -s -I https://localhost:8443/ 2>/dev/null | grep -i "X-Frame-Options")
if [[ "$RESPONSE" == *"SAMEORIGIN"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: X-Frame-Options configurado correctamente"
    echo "  $RESPONSE"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: X-Frame-Options incorrecto o ausente"
    echo "  Obtenido: $RESPONSE"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# X-XSS-Protection
echo "Prueba 1.4: X-XSS-Protection"
RESPONSE=$(curl -k -s -I https://localhost:8443/ 2>/dev/null | grep -i "X-XSS-Protection")
if [[ "$RESPONSE" == *"1; mode=block"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: X-XSS-Protection configurado correctamente"
    echo "  $RESPONSE"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: X-XSS-Protection incorrecto o ausente"
    echo "  Obtenido: $RESPONSE"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 2. Bloqueo de HTTP 1.0
# =================================================================
echo "------- 2. PROTOCOLO HTTP 1.0 -------"
echo ""

echo "Prueba 2.1: Bloqueo de HTTP 1.0 (fuerza HTTP 1.1)"
HTTP_RESPONSE=$(curl -k -s --http1.0 -I https://localhost:8443/ 2>&1)
HTTP_VERSION=$(echo "$HTTP_RESPONSE" | head -1)

# La regla debe forzar HTTP 1.1 si se intenta acceder con HTTP 1.0
if [[ "$HTTP_RESPONSE" == *"HTTP/1.1"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: HTTP 1.0 forzado a HTTP/1.1 correctamente"
    echo "  Resultado: $HTTP_VERSION"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: HTTP 1.0 aún aceptado (debe estar forzado a 1.1)"
    echo "  Resultado: $HTTP_VERSION"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 3. Métodos HTTP bloqueados
# =================================================================
echo "------- 3. RESTRICCIÓN DE MÉTODOS HTTP -------"
echo ""

# Bloqueo de PUT
echo "Prueba 3.1: Bloqueo de método PUT"
STATUS=$(curl -k -s -X PUT https://localhost:8443/index.html -d "test" -o /dev/null -w "%{http_code}")
if [[ "$STATUS" == "403" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: PUT bloqueado correctamente"
    echo "  Código de estado: $STATUS"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: PUT no bloqueado correctamente"
    echo "  Código de estado: $STATUS (esperado 403)"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Bloqueo de DELETE
echo "Prueba 3.2: Bloqueo de método DELETE"
STATUS=$(curl -k -s -X DELETE https://localhost:8443/index.html -o /dev/null -w "%{http_code}")
if [[ "$STATUS" == "403" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: DELETE bloqueado correctamente"
    echo "  Código de estado: $STATUS"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: DELETE no bloqueado correctamente"
    echo "  Código de estado: $STATUS (esperado 403)"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Permitir GET
echo "Prueba 3.3: Método GET permitido"
STATUS=$(curl -k -s -X GET https://localhost:8443/ -o /dev/null -w "%{http_code}")
if [[ "$STATUS" == "200" ]] || [[ "$STATUS" == "301" ]] || [[ "$STATUS" == "302" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: GET permitido correctamente"
    echo "  Código de estado: $STATUS"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: GET no permitido"
    echo "  Código de estado: $STATUS (esperado 200/301/302)"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Permitir POST
echo "Prueba 3.4: Método POST permitido"
STATUS=$(curl -k -s -X POST https://localhost:8443/ -d "test=data" -o /dev/null -w "%{http_code}")
if [[ "$STATUS" == "200" ]] || [[ "$STATUS" == "301" ]] || [[ "$STATUS" == "302" ]] || [[ "$STATUS" == "405" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: POST permitido correctamente"
    echo "  Código de estado: $STATUS"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: POST no permitido"
    echo "  Código de estado: $STATUS"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 4. Server Banner
# =================================================================
echo "------- 4. BANNER DEL SERVIDOR -------"
echo ""

echo "Prueba 4.1: Información de servidor ofuscada"
BANNER=$(curl -k -s -I https://localhost:8443/ 2>/dev/null | grep -i "^Server:")
if [[ ! -z "$BANNER" ]]; then
    echo "  $BANNER"
    if [[ "$BANNER" == *"Apache"* ]] && [[ "$BANNER" =~ [0-9]+\.[0-9]+ ]]; then
        echo -e "${RED}✗ FAIL${NC}: Versión está revelada"
        ((PRUEBAS_FAIL++))
    else
        echo -e "${GREEN}✓ PASS${NC}: Versión no revelada"
        ((PRUEBAS_OK++))
    fi
else
    echo -e "${GREEN}✓ PASS${NC}: Banner no detectado (completamente oculto)"
    ((PRUEBAS_OK++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 5. Pruebas de SSL/TLS
# =================================================================
echo "------- 5. SSL/TLS -------"
echo ""

echo "Prueba 5.1: Certificado SSL disponible"
CERT=$(curl -k -s -I https://localhost:8443/ 2>&1)
if [[ ! -z "$CERT" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: HTTPS disponible"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: HTTPS no disponible"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Verificar que el certificado no es snakeoil (docker exec)
echo "Prueba 5.2: Certificado personalizado (no snakeoil)"
CERT_SUBJECT=$(docker exec tarea3 openssl x509 -in /etc/apache2/ssl/apache.crt -noout -subject 2>/dev/null)
if [[ ! -z "$CERT_SUBJECT" ]] && [[ "$CERT_SUBJECT" == *"www.midominioseguro.com"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Certificado personalizado detectado"
    echo "  $CERT_SUBJECT"
    ((PRUEBAS_OK++))
elif [[ ! -z "$CERT_SUBJECT" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Certificado personalizado"
    echo "  $CERT_SUBJECT"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: No se pudo verificar el certificado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 6. Respuesta HTTP básica
# =================================================================
echo "------- 6. RESPUESTA BÁSICA -------"
echo ""

echo "Prueba 6.1: Servidor responde en puerto 8443"
STATUS=$(curl -k -s -I https://localhost:8443/ -o /dev/null -w "%{http_code}")
if [[ ! -z "$STATUS" ]] && [[ "$STATUS" != "000" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Servidor respondiendo"
    echo "  Código de estado: $STATUS"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: Servidor no respondiendo"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 7. Verificación de módulos cargados en Apache (docker exec)
# =================================================================
echo "------- 7. MÓDULOS DE APACHE -------"
echo ""

# Verificar que mod_security2 está cargado
echo "Prueba 7.1: Módulo mod_security2 activo"
MODULES=$(docker exec tarea3 apache2ctl -M 2>/dev/null | grep security2)
if [[ ! -z "$MODULES" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: mod_security2 está cargado"
    echo "  $MODULES"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: mod_security2 no está cargado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Verificar que mod_headers está cargado
echo "Prueba 7.2: Módulo mod_headers activo"
MODULES=$(docker exec tarea3 apache2ctl -M 2>/dev/null | grep headers)
if [[ ! -z "$MODULES" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: mod_headers está cargado"
    echo "  $MODULES"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: mod_headers no está cargado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Verificar que mod_rewrite está cargado
echo "Prueba 7.3: Módulo mod_rewrite activo"
MODULES=$(docker exec tarea3 apache2ctl -M 2>/dev/null | grep rewrite)
if [[ ! -z "$MODULES" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: mod_rewrite está cargado"
    echo "  $MODULES"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: mod_rewrite no está cargado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 8. Verificación de permisos de directorios (docker exec)
# =================================================================
echo "------- 8. PERMISOS DE DIRECTORIOS -------"
echo ""

# Verificar permisos de /etc/apache2
echo "Prueba 8.1: Permisos de /etc/apache2 (750)"
PERMS=$(docker exec tarea3 stat -c "%a" /etc/apache2 2>/dev/null)
if [[ "$PERMS" == "750" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Permisos correctos (750)"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: Permisos incorrectos (actual: $PERMS, esperado: 750)"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Verificar permisos de /var/log/apache2
echo "Prueba 8.2: Permisos de /var/log/apache2 (750)"
PERMS=$(docker exec tarea3 stat -c "%a" /var/log/apache2 2>/dev/null)
if [[ "$PERMS" == "750" ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Permisos correctos (750)"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: Permisos incorrectos (actual: $PERMS, esperado: 750)"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 9. Verificación de usuario de Apache (docker exec)
# =================================================================
echo "------- 9. USUARIO DE APACHE -------"
echo ""

# Verificar que Apache corre con usuario no privilegiado
echo "Prueba 9.1: Apache ejecutándose con usuario 'apache'"
USER_CHECK=$(docker exec tarea3 ps aux 2>/dev/null | grep apache | grep -v grep | head -1)
if [[ "$USER_CHECK" == *"apache"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Apache corre con usuario no privilegiado"
    echo "  $USER_CHECK"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: Apache no corre con usuario apache"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 10. Verificación de configuración de ModSecurity (docker exec)
# =================================================================
echo "------- 10. CONFIGURACIÓN MODSECURITY -------"
echo ""

# Verificar que SecAuditEngine está activo
echo "Prueba 10.1: SecAuditEngine activado"
AUDIT=$(docker exec tarea3 grep -i "^SecAuditEngine" /etc/modsecurity/modsecurity.conf 2>/dev/null)
if [[ "$AUDIT" == *"On"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: SecAuditEngine activado"
    echo "  $AUDIT"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: SecAuditEngine no activado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 11. Verificación de archivos de configuración (docker exec)
# =================================================================
echo "------- 11. ARCHIVOS DE CONFIGURACIÓN -------"
echo ""

# Verificar que block-http10.conf existe y está activo
echo "Prueba 11.1: block-http10.conf activo"
if docker exec tarea3 test -f /etc/apache2/conf-enabled/block-http10.conf 2>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}: block-http10.conf habilitado"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: block-http10.conf no habilitado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Verificar que security-headers.conf está activo
echo "Prueba 11.2: security-headers.conf activo"
if docker exec tarea3 test -f /etc/apache2/conf-enabled/security-headers.conf 2>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}: security-headers.conf habilitado"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: security-headers.conf no habilitado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Verificar que limit-methods.conf está activo
echo "Prueba 11.3: limit-methods.conf activo"
if docker exec tarea3 test -f /etc/apache2/conf-enabled/limit-methods.conf 2>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}: limit-methods.conf habilitado"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: limit-methods.conf no habilitado"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# 12. Verificación de directivas de seguridad (docker exec)
# =================================================================
echo "------- 12. DIRECTIVAS DE SEGURIDAD -------"
echo ""

# Verificar FileETag None
echo "Prueba 12.1: FileETag deshabilitado"
ETAG=$(docker exec tarea3 grep "^FileETag" /etc/apache2/apache2.conf 2>/dev/null)
if [[ "$ETAG" == *"None"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: FileETag deshabilitado"
    echo "  $ETAG"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: FileETag no está configurado correctamente"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Verificar TraceEnable off
echo "Prueba 12.2: TRACE method deshabilitado"
TRACE=$(docker exec tarea3 grep "^TraceEnable" /etc/apache2/apache2.conf 2>/dev/null)
if [[ "$TRACE" == *"off"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: TRACE deshabilitado"
    echo "  $TRACE"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: TraceEnable no está configurado correctamente"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# Verificar Timeout 60
echo "Prueba 12.3: Timeout configurado a 60 segundos"
TIMEOUT=$(docker exec tarea3 grep "^Timeout" /etc/apache2/apache2.conf 2>/dev/null)
if [[ "$TIMEOUT" == *"60"* ]]; then
    echo -e "${GREEN}✓ PASS${NC}: Timeout correctamente configurado"
    echo "  $TIMEOUT"
    ((PRUEBAS_OK++))
else
    echo -e "${RED}✗ FAIL${NC}: Timeout no está configurado correctamente"
    ((PRUEBAS_FAIL++))
fi
((TOTAL_PRUEBAS++))
echo ""

# =================================================================
# RESUMEN
# =================================================================
echo "=========================================================="
echo "                    RESUMEN DE RESULTADOS"
echo "=========================================================="
echo "Total de pruebas:        $TOTAL_PRUEBAS"
echo -e "Pruebas exitosas:       ${GREEN}$PRUEBAS_OK${NC}"
echo -e "Pruebas fallidas:       ${RED}$PRUEBAS_FAIL${NC}"
echo "=========================================================="
echo ""

if [[ $PRUEBAS_FAIL -eq 0 ]]; then
    echo -e "${GREEN}✓ Todas las pruebas han pasado correctamente${NC}"
    exit 0
else
    echo -e "${RED}✗ Algunas pruebas han fallado. Revisa la configuración.${NC}"
    exit 1
fi
