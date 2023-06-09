#!/bin/bash
chmod 755 /www/serv/nginx/var/www/_letsencrypt/
docker compose -f docker-compose-www.example.com.yml up
echo "y" | docker compose -f docker-compose-www.example.com.yml rm
docker exec -it nginx bash -c "nginx -t && nginx -s reload"