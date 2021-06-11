#!/bin/bash

python3 -m venv env
source env/bin/activate
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install nodeenv
nodeenv --python-virtualenv
deactivate
source env/bin/activate
pip install -e .
pip install -e search
pushd search 
npm install
popd
