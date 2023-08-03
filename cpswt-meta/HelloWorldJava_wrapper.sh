# this script is used to build cpswt-core and its dependencies in the docker container 
ORIGINAL_PATH=$PATH
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
/opt/apache-archiva-2.2.5/bin/archiva start

# wait for archiva to start
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
git clone https://github.com/SimIntToolkit/cpswt-core.git
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

# Run the HelloWorldJava example
cd /home/cpswt/HelloWorldJava

# Compare & patch the HelloWorldJava from plugins and example from cpswt-core
diff -aur /home/cpswt/HelloWorldJava/ /home/cpswt/cpswt-core/examples/HelloWorldJava/ > /home/cpswt/HelloWorldJava/diff.patch
patch -p0 -t -d /home/cpswt/HelloWorldJava/ < /home/cpswt/HelloWorldJava/diff.patch

# cat /home/cpswt/cpswt-core/examples/HelloWorldJava/PingCounter/build.gradle.kts > PingCounter/build.gradle.kts
# cat /home/cpswt/cpswt-core/examples/HelloWorldJava/PingCounter/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/pingcounter/PingCounter.java > PingCounter/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/pingcounter/PingCounter.java
# cat /home/cpswt/cpswt-core/examples/HelloWorldJava/Sink/build.gradle.kts > Sink/build.gradle.kts
# cat /home/cpswt/cpswt-core/examples/HelloWorldJava/Sink/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/sink/Sink.java > Sink/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/sink/Sink.java
# cat /home/cpswt/cpswt-core/examples/HelloWorldJava/Source/build.gradle.kts > Source/build.gradle.kts
# cat /home/cpswt/cpswt-core/examples/HelloWorldJava/Source/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/source/Source.java > Source/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/source/Source.java
# cat /home/cpswt/cpswt-core/examples/HelloWorldJava/build.gradle.kts > build.gradle.kts
# cat /home/cpswt/cpswt-core/examples/HelloWorldJava/conf/default_experiment/default_experiment.json > conf/default_experiment/default_experiment.json
# cat /home/cpswt/cpswt-core/examples/HelloWorldJava/settings.gradle.kts > settings.gradle.kts

gradle wrapper --gradle-version=7.5
./gradlew :Source:build
./gradlew :Sink:build
./gradlew :PingCounter:build
./gradlew :runFederationBatch