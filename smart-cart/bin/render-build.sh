#!/bin/bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

export PATH="/opt/render/.local/bin"

# export PYTHONPATH=$PYTHONPATH:/venv/lib/python3.8/site-packages

source venv/bin/activate
pip3 install -r backend/requirements.txt 

# pip3 freeze


# source env/bin/activate
# env/bin/pip3 install -r backend/requirements.txt
#source .env/bin/activate && pip install -r backend/requirements.txt