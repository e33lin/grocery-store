#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

export PATH="/opt/render/project/src/smart-cart/"

source venv/bin/activate
pip3 install -r backend/requirements.txt 
