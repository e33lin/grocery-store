#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rake assets:precompile
bundle exec rake assets:clean
bundle exec rake db:migrate

export PATH=/opt/render/project/src/smart-cart/


source venv/bin/activate
# alias python3='/opt/render/project/src/smart-cart/venv/bin/python3'
echo $PATH
# which python3 
# python3 --version
venv/bin/pip3 install -r backend/requirements.txt 
venv/bin/pip3 freeze
