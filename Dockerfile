FROM appleboy/drone-ssh:1.6.2-linux-amd64

RUN apt update
RUN apt -yq install rsync openssh-client
rsync -version

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
