#!/bin/bash

NEWRELIC_LICENSE=${NEWRELIC_LICENSE:-false}
if [ "$NEWRELIC_LICENSE" != "false" ]; then
    sed -i "s/^newrelic_license_key=.*/newrelic_license_key=${NEWRELIC_LICENSE}/" /etc/nginx-nr-agent/nginx-nr-agent.ini
    sed -i "s/^license_key=.*/license_key=${NEWRELIC_LICENSE}/" /etc/newrelic/nrsysmond.cfg
fi

NEWRELIC_APP=${NEWRELIC_APP:-false}
if [ "$NEWRELIC_APP" != "false" ]; then
    echo -e "[source0]\nname=${NEWRELIC_APP}\nurl=http://localhost/nginx_stub_status\n\n" >> /etc/nginx-nr-agent/nginx-nr-agent.ini
fi

if [ "$NEWRELIC_LICENSE" != "false" ] && [ "$NEWRELIC_APP" != "false" ]; then
    /usr/bin/service nginx-nr-agent start
fi

exit 0
