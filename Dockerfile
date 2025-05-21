FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install -y software-properties-common \
                   sshpass \
                   git && \
    add-apt-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible ansible-lint && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /ansible