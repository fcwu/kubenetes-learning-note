FROM jenkins/inbound-agent:4.3-4

USER root
RUN wget http://s3.moxa.online/v3/edge/builds/thanos-sysman/release/iotedge/v2.1.0/1592/amd64/appmanutil -O /usr/local/bin/appmanutil \
    && chmod +x /usr/local/bin/appmanutil \
    && apt update \
    && apt install -y --no-install-recommends jq python3 python3-pip python3-setuptools \
    && pip3 install tavern==1.6.0 pytest==6.0.1 pytest-html \
    && rm -rf /var/lib/apt/lists/*
USER jenkins
