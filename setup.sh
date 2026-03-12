#!/bin/bash
docker compose up -d
docker compose cp ~/.ssh/id_rsa.pub personal-blog:/root/.ssh/authorized_keys
docker compose exec personal-blog chown root:root /root/.ssh/authorized_keys
docker compose exec personal-blog chmod 600 /root/.ssh/authorized_keys
echo "Listo! Conectate con: ssh NycTaxi"
