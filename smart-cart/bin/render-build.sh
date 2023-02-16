#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

export PATH="/opt/render/.local/bin"

# export PYTHONPATH=$PYTHONPATH:/venv/lib/python3.8/site-packages

source venv/bin/activate
venv/bin/pip3 install -r backend/requirements.txt 


# source env/bin/activate
# env/bin/pip3 install -r backend/requirements.txt
#source .env/bin/activate && pip install -r backend/requirements.txt