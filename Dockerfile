FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install system tools, SSH and Node.js
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    procps \
    passwd \
    ca-certificates \
    curl \
    && mkdir -p /var/run/sshd \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# SSH configuration
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

WORKDIR /app

COPY webui/package.json /app/webui/package.json
RUN cd /app/webui && npm install --omit=dev

COPY webui/server.js /app/webui/server.js
COPY webui/index.html /app/webui/index.html
COPY ssh-user-config.sh /app/ssh-user-config.sh
COPY start.sh /app/start.sh

RUN chmod +x /app/ssh-user-config.sh /app/start.sh

EXPOSE 8080 22

CMD ["/app/start.sh"]
