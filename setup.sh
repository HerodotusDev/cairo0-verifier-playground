#!/bin/bash

python3.9 -m venv venv
echo 'export PYTHONPATH="$PWD:$PYTHONPATH"' >> venv/bin/activate
source venv/bin/activate