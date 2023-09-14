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
git clone https://github.com/SimIntToolkit/cpswt-core.git
cd cpswt-core/cpswt-core

gradle wrapper --gradle-version=7.5

# sh ./cpswt-redeploy.sh
./gradlew :utils:build --rerun-tasks --refresh-dependencies
./gradlew :utils:publish 
echo "utils published"

./gradlew :root:build --rerun-tasks --refresh-dependencies
./gradlew :utils:publish
echo "root published"

./gradlew :base-events:build --rerun-tasks --refresh-dependencies
./gradlew :base-events:publish
echo "base-events published"

./gradlew :config:build --rerun-tasks --refresh-dependencies
./gradlew :config:publish
echo "config published"

./gradlew :federate-base:build --rerun-tasks --refresh-dependencies
/gradlew :federate-base:publish
echo "federate-base published"

./gradlew :coa:build --rerun-tasks --refresh-dependencies
./gradlew :coa:publish
echo "coa published"

./gradlew :federation-manager:build --rerun-tasks --refresh-dependencies
./gradlew :federation-manager:publish
echo "federation-manager published"

./gradlew :fedmanager-host:build --rerun-tasks --refresh-dependencies
./gradlew :fedmanager-host:publish
echo "fedmanager-host published"

# Compare & patch the HelloWorldJava from plugins and example from cpswt-core
cd /home/cpswt
# these six files should be purly overwritten only
cat /home/cpswt/cpswt-core/examples/HelloWorldJava/PingCounter/build.gradle.kts > PingCounter/build.gradle.kts
cat /home/cpswt/cpswt-core/examples/HelloWorldJava/Sink/build.gradle.kts > Sink/build.gradle.kts
cat /home/cpswt/cpswt-core/examples/HelloWorldJava/Source/build.gradle.kts > Source/build.gradle.kts
cat /home/cpswt/cpswt-core/examples/HelloWorldJava/build.gradle.kts > build.gradle.kts
cat /home/cpswt/cpswt-core/examples/HelloWorldJava/conf/default_experiment/default_experiment.json > conf/default_experiment/default_experiment.json
cat /home/cpswt/cpswt-core/examples/HelloWorldJava/settings.gradle.kts > settings.gradle.kts
# diff -aur HelloWorldJava/ cpswt-core/examples/HelloWorldJava/ > diff.patch
# patch -p1 -t -d HelloWorldJava/ < diff.patch

# Intent for adding new features to //TODO: 
# the script should be finding TODOs in the HelloWorldJava and insert behaviours accordingly

# Insert behavior for the TODO part in PingCounter.java
sed -i -e "s/pingCounter1/pingCounter0/g" -e "/\/\/\/ TODO implement how to handle reception of the object \/\/\//a\
        if (++counter >= 5) {\
            exitCondition = true;\
        }\
\
        System.out.println("PingCounter:  ping count is now " + pingCounter0.get_pingCount());\
" /home/cpswt/cpswt-core/examples/HelloWorldJava/PingCounter/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/pingcounter/PingCounter.java

# Insert behavior for the TODO part in Sink.java
 sed -i '/new edu.vanderbilt.vuisis.cpswt.hla.ObjectRoot_p.PingCounter();/a \
    edu.vanderbilt.vuisis.cpswt.hla.ObjectRoot_p.PingCounter PingCounter_0 = \
    new edu.vanderbilt.vuisis.cpswt.hla.ObjectRoot_p.PingCounter();' HelloWorldJava/Sink/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/sink/Sink.java

sed -i -e '/\/\/ registerObject(PingCounter_0);/a \
        registerObject(PingCounter_0);' -i -e "s/pingCounter1/pingCounter0/g" HelloWorldJava/Sink/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/sink/Sink.java
        
sed -i "" HelloWorldJava/Sink/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/sink/Sink.java 

# Insert behavior for the TODO part in Source.java
sed -i "/\/\/ Set the interaction's parameters./a\
        \
        System.out.println(\"Source:  sending ping\");\
        edu.vanderbilt.vuisis.cpswt.hla.InteractionRoot_p.C2WInteractionRoot_p.Ping Ping0 = create_InteractionRoot_C2WInteractionRoot_Ping();\
        Ping0.set_actualLogicalGenerationTime( currentTime );\
        Ping0.set_federateFilter( \"\" );\
        sendInteraction(Ping0, currentTime + getLookahead());" HelloWorldJava/Source/src/main/java/edu/vanderbilt/vuisis/cpswt/hla/helloworldjava/source/Source.java

# Run the HelloWorldJava example
cd /home/cpswt/HelloWorldJava

gradle wrapper --gradle-version=7.5
./gradlew :Source:build
./gradlew :Sink:build
./gradlew :PingCounter:build
./gradlew :runFederationBatch