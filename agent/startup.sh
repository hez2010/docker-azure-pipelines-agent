#!/bin/bash
source /opt/bash-utils/logger.sh

INFO "Starting supervisor"
/usr/bin/supervisord -n >> /dev/null 2>&1 &
