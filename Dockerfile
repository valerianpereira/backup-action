# Uses Alpine Linux v3.12
FROM appleboy/drone-ssh:1.6.2-linux-amd64

# Install rsync
RUN apk --update add --no-cache rsync openssh-client git dpkg \
	&& apk add hub --repository=http://dl-cdn.alpinelinux.org/alpine/v3.3/community \
	&& rm -rf /var/cache/apk/*

RUN hub version

# Install github-cli
# RUN wget https://github.com/cli/cli/releases/download/v0.11.1/gh_0.11.1_linux_amd64.deb
# RUN dpkg -i *.deb

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
