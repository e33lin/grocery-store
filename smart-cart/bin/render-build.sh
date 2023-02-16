#!/usr/bin/env bash
# exit on error
set -o errexit

# bundle install
# bundle exec rake assets:precompile
# bundle exec rake assets:clean
# bundle exec rake db:migrate

export PATH="/opt/render/.local/bin:$PATH"

source venv/bin/activate
pip3 install -r backend/requirements.txt 

python3 backend/search_v3.py "['apples']" 1

echo "/opt/render/.local/bin:$PATH"


# source env/bin/activate
# env/bin/pip3 install -r backend/requirements.txt
#source .env/bin/activate && pip install -r backend/requirements.txt