# Uses Alpine Linux v3.12
FROM appleboy/drone-ssh:1.6.2-linux-amd64

# Install rsync
RUN apk --update add --no-cache rsync openssh && rm -rf /var/cache/apk/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
