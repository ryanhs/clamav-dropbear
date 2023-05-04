#!/bin/sh

# automagically add new authorization_keys based on environment variable, easier to integrate with docker-compose
if [ -n "$SSH_PUB_KEY" ]; then
  echo "env SSH_PUB_KEY exists!, use for authorization_keys";

  # use clamav default home /var/lib/clamav
  # mkdir -p /var/lib/${SSH_USERNAME}/.ssh
  # echo "$SSH_PUB_KEY" > /var/lib/${SSH_USERNAME}/.ssh/authorized_keys
  
  mkdir -p /home/${SSH_USERNAME}/.ssh
  echo "$SSH_PUB_KEY" > /home/${SSH_USERNAME}/.ssh/authorized_keys
fi;

# chown to ensure
chown -R ${SSH_USERNAME}:${SSH_USERNAME} /var/lib/clamav

/usr/sbin/dropbear -RFEmwsgjk -K 3600 -I 3600 -G ${SSH_USERNAME} -p 22