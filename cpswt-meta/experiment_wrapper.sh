systemctl start mongod

sleep 5

cd /home/cpswt/webgme-engine

node src/bin/import.js -m mongodb://127.0.0.1:27017/c2webgme -p HelloWorldJava ../cpswt-meta/seeds/_archive/CPSWT_Helloworld_Java_Tutorial

cd /home/cpswt/cpswt-meta

# generate .zip file
nvm use 8.10.0
export PYTHONPATH=$PWD/src/plugins/PyFederatesExporter/PyFederatesExporter
sed -i 's/HelloWorldOmnetpp/HelloWorldJava/g' $PWD/src/plugins/PyFederatesExporter/run_debug.py
python3 $PWD/src/plugins/PyFederatesExporter/run_debug.py

#unzip .zip
cd /tmp


