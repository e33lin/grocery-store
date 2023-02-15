#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

source env/bin/activate
which pip
env/bin/pip install -r backend/requirements.txt