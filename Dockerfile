FROM clamav/clamav:1.0.1-2_base as avBase
# clamav:1.0.1-2 docker based on alpine3.17, use _base tag to get image without signature database

#id to be created, since clamav user already created from base image, then we create another one, default for node
ENV SSH_USERID=1000 
ENV SSH_GROUPID=1000 
ENV SSH_USERNAME=node

# add packages
RUN apk add --update --no-cache \
  tini git curl ca-certificates \
  dropbear dropbear-dbclient dropbear-scp \
  jq

# configure dropbear
RUN mkdir /etc/dropbear

# setup new user
RUN addgroup -g ${SSH_USERID} ${SSH_USERNAME} \
  && adduser -u ${SSH_GROUPID} -G ${SSH_USERNAME} -s /bin/sh -D ${SSH_USERNAME} 

# setup profile system-wide, no-history, [TODO!]
# RUN echo 'unset HISTFILE' >> /etc/profile.d/disable.history.sh


# add azure devops-scan.sh
COPY --chown=${SSH_USERNAME}:${SSH_USERNAME} ./devops-scan.sh /home/${SSH_USERNAME}/devops-scan.sh
RUN chmod +x /home/${SSH_USERNAME}/devops-scan.sh

# override clamav healthcheck
HEALTHCHECK --interval=10s CMD exit 0

# setup boot
EXPOSE 22
COPY run.sh /run.sh
RUN chmod +x /run.sh
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/run.sh"]