FROM debian:10-slim

ARG BORG_VERSION=1.1.15

RUN set -x \
    && apt-get update \
    && apt-get install -y curl openssh-server python3-pip build-essential libssl-dev libssl1.1 liblz4-dev liblz4-1 libacl1-dev libacl1 \
    && rm -f /etc/ssh/ssh_host_* \
    && pip3 install borgbackup==$BORG_VERSION \
    && apt-get remove -y --purge build-essential libssl-dev liblz4-dev libacl1-dev \
    && apt-get autoremove -y --purge \
    && adduser --uid 500 --disabled-password --gecos "Borg Backup" --quiet borg \
    && mkdir /var/run/sshd \
    && mkdir /var/backups/borg \
    && chown borg.borg /var/backups/borg \
    && mkdir /home/borg/.ssh \
    && chmod 700 /home/borg/.ssh \
    && chown borg.borg /home/borg/.ssh \
    && rm -rf /var/lib/apt/lists/*

RUN set -x \
    && sed -i \
        -e 's/^#PasswordAuthentication yes$/PasswordAuthentication no/g' \
        -e 's/^#PermitRootLogin prohibit-password$/PermitRootLogin no/g' \
        -e 's/^X11Forwarding yes$/X11Forwarding no/g' \
        -e 's/^#LogLevel .*$/LogLevel ERROR/g' \
        /etc/ssh/sshd_config

VOLUME /var/backups/borg

ADD ./entrypoint.sh /

EXPOSE 22
CMD ["/entrypoint.sh"]
