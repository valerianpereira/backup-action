# Uses Alpine Linux v3.12
FROM appleboy/drone-ssh:1.6.2-linux-amd64

# Install rsync
RUN apk --update add --no-cache rsync openssh-client git dpkg && rm -rf /var/cache/apk/*

# Install github-cli
RUN wget https://github.com/cli/cli/releases/download/v0.11.1/gh_0.11.1_linux_amd64.deb
RUN dpkg -i *.deb

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
