# this script is used to build cpswt-core and its dependencies in the docker container 
ORIGINAL_PATH=$PATH
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
/opt/apache-archiva-2.2.5/bin/archiva start

# wait for archiva to start
echo "Waiting archiva to launch on 8080..."

while ! nc -z localhost 8080; do   
  sleep 0.1 # wait for 1/10 of the second before check again
done

echo "archiva launched"

# create admin user
curl --no-progress-meter -X POST -H "Content-Type: application/json" -H "Origin: http://localhost:8080" -d @- \
 http://localhost:8080/restServices/redbackServices/userService/createAdminUser <<'TERMINUS'
{
    "username": "admin",
    "password": "adminpass123",
    "email": "admin@archiva-test.org",
    "fullName": "Admin",
    "locked": false,
    "passwordChangeRequired": false,
    "permanent": false,
    "readOnly": false,
    "validated": true,
    "confirmPassword": "adminpass123"
}
TERMINUS

# switch to java 17
unset JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64
export PATH=$JAVA_HOME/bin:$ORIGINAL_PATH

# clone cpswt-core and build it
cd /home/cpswt
git clone https://github.com/justinyeh1995/cpswt-core.git
cd cpswt-core/cpswt-core

gradle wrapper --gradle-version=7.5

./gradlew :utils:publish 
./gradlew :root:publish
./gradlew :base-events:publish 
./gradlew :config:publish
./gradlew :federate-base:publish 
./gradlew :coa:publish 
./gradlew :federation-manager:publish 
./gradlew :fedmanager-host:publish 

# build cpswt-cpp
cd /home/cpswt
git clone https://github.com/SimIntToolkit/cpswt-cpp.git
cd cpswt-cpp

gradle wrapper --gradle-version=8.0

./gradlew :foundation:CppTestHarness:publish
./gradlew :foundation:core-cpp:publish
./gradlew :foundation:C2WConsoleLogger:publish
./gradlew :foundation:rti-base-cpp:publish
./gradlew :foundation:CPSWTConfig:publish
./gradlew :foundation:SynchronizedFederate:publish

# # Install OMNeT++ version 5.6.2
# cd /home/cpswt
# wget https://github.com/omnetpp/omnetpp/releases/download/omnetpp-5.6.2/omnetpp-5.6.2-src-linux.tgz
# # Untar the omnetpp-5.6.2-src-linux.tgz tarball into your /opt directory:
# tar -xzf omnetpp-5.6.2-src-linux.tgz -C /opt

# # Build OMNeT++ version 5.6.2
# export PATH="/opt/omnetpp-5.6.2/bin:$PATH"
# cd /opt/omnetpp-5.6.2
# ./configure WITH_TKENV=no WITH_QTENV=no
# make -j$(nproc)

# # Install the INET framework, version 4.2.5
# cd /home/cpswt
# wget https://github.com/inet-framework/inet/releases/download/v4.2.5/inet-4.2.5-src.tgz
# # Untar the inet-4.2.5-src.tgz tarball into your /opt directory:
# tar -xzf inet-4.2.5-src.tgz -C /opt

# # Build the INET framework, version 4.2.5
# export INET_HOME="/opt/inet4"
# bash -li <<TERMINUS
# cd /opt/inet4
# . setenv
# make makefiles
# make
# make MODE=debug
# TERMINUS

cd /home/cpswt/cpswt-omnetpp

# Build the OmnetFederate:
./gradlew :foundation:OmnetFederate:build
export OMNETPP_CPSWT_HOME=/home/cpswt/cpswt-omnetpp/foundation/OmnetFederate
cd /home/cpswt/cpswt-omnetpp/examples/HelloWorldOmnetpp
touch build.dummy.kts
gradle -b build.dummy.kts wrapper --gradle-version=8.0
./gradlew :Source:build
./gradlew :Sink:build
./gradlew :PingCounter:build
./gradlew :runFederationBatch
