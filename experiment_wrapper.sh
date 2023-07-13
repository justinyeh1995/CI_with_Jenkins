systemctl start mongod

cd /home/cpswt/webgme-engine

node src/bin/import.js -m mongodb://127.0.0.1:27017/c2webgme -p HelloWorldOmnetpp ../cpswt-meta/seeds/_archive/CPSWT_Helloworld_Java_Tutorial

cd /home/cpswt/cpswt-meta

# run npm start in background
npm start &

sleep 10

# generate .zip file
nvm use 8.10.0
export PYTHONPATH=$PWD/src/plugins/PyFederatesExporter/PyFederatesExporter
python3 $PWD/src/plugins/PyFederatesExporter/run_debug.py

#unzip .zip
cd /tmp


