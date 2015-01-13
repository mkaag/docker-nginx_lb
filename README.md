docker-nginx_lb
===============

[![Docker Hub](https://img.shields.io/badge/docker-mkaag%2Fnginx_lb-008bb8.svg)](https://registry.hub.docker.com/u/mkaag/nginx_lb/)

This repository contains the **Dockerfile** and the configuration files to build a Load Balancer based on Nginx for [Docker](https://www.docker.com/).
The configuration is performed with [confd](https://github.com/kelseyhightower/confd) and monitoring can be enabled to use [NewRelic](https://newrelic.com)

### Base Docker Image

* [phusion/baseimage](https://github.com/phusion/baseimage-docker), the *minimal Ubuntu base image modified for Docker-friendliness*...
* ...[including image's enhancement](https://github.com/racker/docker-ubuntu-with-updates) from [Paul Querna](https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/)

### Installation

```bash
docker build -t mkaag/nginx_lb github.com/mkaag/docker-nginx_lb
```

### Usage

#### Basic usage

```bash
docker run -d -p 443:443 -p 80:80 \
mkaag/nginx_lb /sbin/my_init -- bash /usr/local/bin/confd-watch
```

#### Using persistent volume

```bash
docker run -d \
-v /opt/apps/public:/var/www \
-p 443:443 -p 80:80 \
mkaag/nginx_lb /sbin/my_init -- bash /usr/local/bin/confd-watch
```

#### Using NewRelic

```bash
docker run -d \
-e "NEWRELIC_LICENSE=your_license" \
-e "NEWRELIC_APP=domain.com" \
-p 443:443 -p 80:80 \
mkaag/nginx_lb /sbin/my_init -- bash /usr/local/bin/confd-watch
```

### etcd structure

```bash
etcdctl set /services/production/domain domain.com
etcdctl set /services/production/root /opt/apps/public
etcdctl set /services/production/upstream/127.0.0.1 127.0.0.1:9001
```
