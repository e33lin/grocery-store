#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

export PATH="/opt/render/.local/bin:$PATH"

# export PYTHONPATH=$PYTHONPATH:/venv/lib/python3.8/site-packages


# python3 -m venv venv

source venv/bin/activate

# python -m pip install --upgrade pip

pip3 install -r backend/requirements.txt 

python -m pip install pandas

# pip freeze

# source env/bin/activate
# env/bin/pip3 install -r backend/requirements.txt
#source .env/bin/activate && pip install -r backend/requirements.txt