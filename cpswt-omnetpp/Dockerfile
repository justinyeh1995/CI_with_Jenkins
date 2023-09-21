# Base image: Ubuntu 20.04
FROM ubuntu:20.04
LABEL maintainer="CPSWT Team"

# Set it to noninteractive mode
ARG DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        apt-transport-https \
        bison \
        build-essential \
        ca-certificates \
        clang \
        curl \
        doxygen \
        flex \
        gcc \
        gdb \
        git \
        graphviz \
        libboost1.71-all-dev \
        libcppunit-dev \
        libjsoncpp-dev \
        libosgearth-dev \
        libqt5opengl5-dev \
        libwebkit2gtk-4.0-37 \
        libxml2-dev \
        lld \
        make \
        mongodb \
        mpi-default-dev \
        netcat \
        openjdk-8-jdk \
        openjdk-17-jdk \
        openscenegraph-plugin-osgearth \
        perl \
        python2 \
        python3 \
        python3-pip \
        python-is-python2 \
        qt5-qmake \
        qtbase5-dev \
        qtbase5-dev-tools \
        qtchooser \
        software-properties-common \
        wget \
        xterm \
        zlib1g-dev \
        unzip \
        zip

#install Gradle
ARG GRADLE_VERSION=7.5
RUN wget -O gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    mkdir /opt/gradle && \
    unzip -d /opt/gradle gradle.zip && \
    rm gradle.zip
# Set Gradle in the environment variables
ENV GRADLE_HOME="/opt/gradle/gradle-${GRADLE_VERSION}"
ENV PATH="${GRADLE_HOME}/bin:${PATH}"

# Install Python packages
RUN python3 -m pip install --system --upgrade \
    jinja2 \
    matplotlib \
    numpy \
    pandas \
    posix_ipc \
    scipy \
    seaborn \
    webgme-bindings 

# Download and extract portico
WORKDIR /home
RUN wget -O portico.tar.gz https://master.dl.sourceforge.net/project/portico/Portico/portico-2.1.0/portico-2.1.0-linux64.tar.gz?viasf=1 && \
    tar xf portico.tar.gz && \
    rm portico.tar.gz
ENV RTI_HOME="/home/portico-2.1.0"

# Download and set up Apache Archiva
WORKDIR /opt
RUN wget -O archiva.tar.gz https://archive.apache.org/dist/archiva/2.2.5/binaries/apache-archiva-2.2.5-bin.tar.gz && \
    tar xf archiva.tar.gz && \
    rm archiva.tar.gz

# Expose the Archiva port
EXPOSE 8080/tcp

# Use SIGINT for stopping
STOPSIGNAL SIGINT

# Set up Gradle properties
COPY gradle.properties /root/.gradle/
RUN chmod 600 /root/.gradle/gradle.properties

# Install OMNeT++ version 5.6.2
WORKDIR /home/cpswt
RUN wget https://github.com/omnetpp/omnetpp/releases/download/omnetpp-5.6.2/omnetpp-5.6.2-src-linux.tgz
# Untar the omnetpp-5.6.2-src-linux.tgz tarball into your /opt directory:
RUN tar xf omnetpp-5.6.2-src-linux.tgz -C /opt

# Build OMNeT++ version 5.6.2
ENV PATH="/opt/omnetpp-5.6.2/bin:$PATH"
WORKDIR /opt/omnetpp-5.6.2
# RUN ./configure WITH_TKENV=no WITH_QTENV=no
RUN ./configure
# RUN make -j$(nproc)
RUN make 

# Install the INET framework, version 4.2.5
WORKDIR /home/cpswt
RUN wget https://github.com/inet-framework/inet/releases/download/v4.2.5/inet-4.2.5-src.tgz
# Untar the inet-4.2.5-src.tgz tarball into your /opt directory:
RUN tar xf inet-4.2.5-src.tgz -C /opt

# Build the INET framework, version 4.2.5
ENV INET_HOME="/opt/inet4"
RUN bash -li <<TERMINUS
cd /opt/inet4
. setenv
make makefiles
make
make MODE=debug
TERMINUS

# Clone and build CPSWT packages
WORKDIR /home/cpswt
COPY experiment_wrapper.sh /home/cpswt

# Clone CPSWT-OMNETPP
WORKDIR /home/cpswt
RUN mkdir ~/.ssh
ARG ssh_prv_key
ARG ssh_pub_key
RUN echo "$ssh_prv_key" > /root/.ssh/id_rsa && \
    echo "$ssh_pub_key" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub && \
    ssh-keyscan github.com >> /root/.ssh/known_hosts && \
    git clone git@github.com:SimIntToolkit/cpswt-omnetpp.git && \
    git clone git@github.com:SimIntToolkit/cpswt-cyberlib.git && \
    rm /root/.ssh/id_rsa*

WORKDIR /home/cpswt
# Start Archiva
#CMD ["/usr/bin/bash", "experiment_wrapper.sh"] 
CMD ["/usr/bin/bash"] 
