# Uses Alpine Linux v3.12
FROM appleboy/drone-ssh:1.6.3-linux-amd64

# Install rsync
RUN apk --update add --no-cache rsync openssh-client git dpkg && rm -rf /var/cache/apk/*

ADD backup.sh /backup.sh
RUN chmod +x /backup.sh
ENTRYPOINT ["/backup.sh"]
