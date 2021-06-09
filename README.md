# docker-aspnetcore-s6-5.0.6

# thanks for https://github.com/Roxedus

```
docker run --rm -itd -p 80:80 -v /root/tmp/app:/app -e DLL="publish.dll" mydocker/aspnetcoresingle:5.0.6
```

```
version: '3.6'

services:

  aspnetcoreapp:
    image: mydocker/aspnetcoresingle:5.0.6
    environment:
      - DLL=publish.dll
    networks:
      - traefik
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.docker.network=traefik"
      - "traefik.http.routers.aspnetcoreappweb.middlewares=https-redirect@file"
      - "traefik.http.routers.aspnetcoreappweb.entrypoints=http"
      - "traefik.http.routers.aspnetcoreappweb.rule=Host(`aspnetcoreapp.yourdomain.com`)"
      - "traefik.http.routers.aspnetcoreappssl.middlewares=content-compress@file"
      - "traefik.http.routers.aspnetcoreappssl.entrypoints=https"
      - "traefik.http.routers.aspnetcoreappssl.tls=true"
      - "traefik.http.routers.aspnetcoreappssl.rule=Host(`aspnetcoreapp.yourdomain.com`)"
      - "traefik.http.services.aspnetcoreappbackend.loadbalancer.server.scheme=http"
      - "traefik.http.services.aspnetcoreappbackend.loadbalancer.server.port=80"
    volumes:
      - /root/tmp/app:/app
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
    extra_hosts:
      - "aspnetcoreapp.yourdomain.com:127.0.0.1"

networks:
  traefik:
    external: true

```