#!/bin/bash

NEWRELIC_LICENSE=${NEWRELIC_LICENSE:-false}
if [ "$NEWRELIC_LICENSE" != "false" ]; then
    sed -i "s/^newrelic_license_key=.*/newrelic_license_key=${NEWRELIC_LICENSE}/" /etc/nginx-nr-agent/nginx-nr-agent.ini
    sed -i "s/^license_key=.*/license_key=${NEWRELIC_LICENSE}/" /etc/newrelic/nrsysmond.cfg
fi

exit 0
