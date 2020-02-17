#!/usr/bin/env bash


if [ ! -d ubsub-env ]; then 
    python3 -m venv ubsub-env; 
fi

source ubsub-env/bin/activate
pip3 install --upgrade pip

if [ -f requirements.txt ]; then 
    pip3 install -r requirements.txt; 
fi
