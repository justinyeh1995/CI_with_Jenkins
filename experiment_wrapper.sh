cd /home/cpswt/webgme-engine

node src/bin/import.js -m mongodb://127.0.0.1:27017/c2webgme -p HelloWorldJava ../cpswt-meta/seeds/_archive/CPSWT_Helloworld_Java_Tutorial

cd /home/cpswt/cpswt-meta

# run npm start in background
npm start &

sleep 10

export PYTHONPATH=$PWD/src/plugins/PyFederatesExporter
python3 $PWD/src/plugins/PyFederatesExporter/PyFederatesExporter/run_debug.py

