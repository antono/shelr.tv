#!/bin/sh
set -x
cp ./config/config.yml.travis ./config/config.yml
bundle exec rake spec
