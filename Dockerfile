FROM phusion/baseimage:latest

MAINTAINER Maurice Kaag <mkaag@me.com>

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV DEBIAN_PRIORITY critical
ENV DEBCONF_NOWARNINGS yes
# Workaround initramfs-tools running on kernel 'upgrade': <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189>
ENV INITRD No

# Workaround initscripts trying to mess with /dev/shm: <https://bugs.launchpad.net/launchpad/+bug/974584>
# Used by our `src/ischroot` binary to behave in our custom way, to always say we are in a chroot.
ENV FAKE_CHROOT 1
RUN mv /usr/bin/ischroot /usr/bin/ischroot.original
ADD build/ischroot /usr/bin/ischroot

# Configure no init scripts to run on package updates.
ADD build/policy-rc.d /usr/sbin/policy-rc.d

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Ensure UTF-8
RUN locale-gen en_US.UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

CMD ["/sbin/my_init"]

# Nginx Installation
ENV NEWRELIC_LICENSE false
ENV NEWRELIC_APP false
ENV CONFD_VERSION 0.7.1

RUN \
    sed -i 's/^# \(.*-backports\s\)/\1/g' /etc/apt/sources.list && \
    apt-get update -qqy && \
    apt-get install -qqy wget curl && \
    wget -O - http://nginx.org/keys/nginx_signing.key | apt-key add - && \
    wget -O - https://download.newrelic.com/548C16BF.gpg | apt-key add - && \
    echo "deb http://nginx.org/packages/ubuntu/ trusty nginx" > /etc/apt/sources.list.d/nginx.list && \
    echo "deb-src http://nginx.org/packages/ubuntu/ trusty nginx" >> /etc/apt/sources.list.d/nginx.list && \
    echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list && \
    apt-get update -qqy

RUN \
    apt-get install -qqy \
        nginx-common \
        nginx-extras \
        nginx-nr-agent \
        newrelic-sysmond

ADD build/newrelic.sh /etc/my_init.d/10_setup_newrelic.sh
ADD build/confd-watch /usr/local/bin/confd-watch
ADD build/nginx.toml /etc/confd/conf.d/nginx.toml
ADD build/nginx.tmpl /etc/confd/templates/nginx.tmpl
ADD build/nginx.conf /etc/nginx/nginx.conf
ADD build/ee_fastcgi_params /etc/nginx/ee_fastcgi_params

WORKDIR /usr/local/bin
RUN \
    curl -s -L https://github.com/kelseyhightower/confd/releases/download/v$CONFD_VERSION/confd-$CONFD_VERSION-linux-amd64 -o confd; \
    chmod +x confd; \
    chmod +x confd-watch; \
    chmod +x /etc/my_init.d/10_setup_newrelic.sh; \
    rm /etc/nginx/sites-enabled/default

EXPOSE 80 443
VOLUME ["/var/www"]
# End Nginx

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
