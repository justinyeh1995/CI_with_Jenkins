# Base image: Ubuntu 20.04
FROM ubuntu:20.04
LABEL maintainer="CPSWT Team"

# Set it to noninteractive mode
ARG DEBIAN_FRONTEND=noninteractive

# Install node version manager
RUN apt-get update && apt-get install -y \
                                    apt-transport-https \
                                    build-essential \
                                    ca-certificates \
                                    clang \
                                    curl \
                                    doxygen \
                                    flex \
                                    gcc \
                                    gdb \
                                    git \
                                    gnupg \
                                    make \
                                    pip \
                                    systemctl \
                                    zip \
                                    upzip
                                    
# Install MongoDB
RUN curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -

RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | \
   tee /etc/apt/sources.list.d/mongodb-org-4.4.list

RUN apt-get update && apt-get install -y \
                                    mongodb-org=4.4.22 \
                                    mongodb-org-server=4.4.22 \
                                    mongodb-org-shell=4.4.22 \
                                    mongodb-org-mongos=4.4.22 \
                                    mongodb-org-tools=4.4.22

RUN systemctl daemon-reload && systemctl enable mongod

# Install node version manager
RUN touch ~/.bashrc && chmod +x ~/.bashrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
RUN bash -c "source ~/.nvm/nvm.sh && nvm install node && nvm install 8.10.0"

RUN mkdir -p /home/cpswt
WORKDIR /home/cpswt

# Clone webgme-engine
RUN git clone https://github.com/webgme/webgme-engine.git 
RUN bash -c "source ~/.nvm/nvm.sh && nvm use node && cd /home/cpswt/webgme-engine && npm install"


# Clone cpswt-meta
WORKDIR /home/cpswt
RUN mkdir ~/.ssh
ARG ssh_prv_key
ARG ssh_pub_key
RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    git clone git@github.com:SimIntToolkit/cpswt-meta.git && \
    rm /root/.ssh/id_rsa*

RUN cd cpswt-meta && apt-get install -y python-is-python2
RUN bash -c "source ~/.nvm/nvm.sh && nvm use 8.10.0 && cd /home/cpswt/cpswt-meta && npm install"
RUN apt-get install -y python-is-python3

RUN python3 -m pip install jinja2 webgme-bindings

COPY experiment_wrapper.sh /home/cpswt/

CMD [ "/bin/bash" ]



