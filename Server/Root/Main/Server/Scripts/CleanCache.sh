#!/bin/bash
set -e
rm -rf /root/.cache /home/*/.cache || true
rm -rf /var/log/*.{4,5,6,7,8,9}.* || true
