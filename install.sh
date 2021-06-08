#!/bin/bash

python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
pip install nodeenv
nodeenv --python-virtualenv
deactivate
source env/bin/activate
pip install -e .
