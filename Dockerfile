# Base image: Ubuntu 20.04
FROM ubuntu:20.04
LABEL maintainer="CPSWT Team"

# Set it to noninteractive mode
ARG DEBIAN_FRONTEND=noninteractive

# Install node version manager
RUN apt-get update && apt-get install -y curl && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

# Install node
RUN bash -c "source /root/.nvm/nvm.sh && nvm install 8.10.0 && nvm install node"

RUN mkdir -p /home/cpswt
WORKDIR /home/cpswt

# Clone webgme-engine
RUN git clone https://github.com/webgme/webgme-engine.git
RUN cd webgme-engine && nvm use node && npm install

# Clone cpswt-meta
WORKDIR /home/cpswt
RUN git clone https://github.com/SimIntToolkit/cpswt-meta.git
RUN cd cpswt-meta && sudo apt-get install -y python-is-python2
RUN nvm use 8.10.0 && npm install
RUN sudo apt-get install -y python-is-python3

COPY experiment_wrapper.sh /home/cpswt/

CMD [ "/bin/bash" ]



