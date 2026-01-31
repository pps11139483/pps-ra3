#!/bin/bash
set -e

# Source the environment variables that Apache needs
source /etc/apache2/envvars

# Update envvars to use our non-privileged user
export APACHE_RUN_USER=apache
export APACHE_RUN_GROUP=apache

# Start Apache in foreground
exec apache2 -D FOREGROUND
