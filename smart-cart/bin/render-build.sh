#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

python3 -m pip install --upgrade pip
pip install virtualenv
virtualenv venv
source venv/bin/activate