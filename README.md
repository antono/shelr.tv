# Shelr.tv - [service for terminal screencasting][TV]

[![Build Status](https://secure.travis-ci.org/antono/shelr.tv.png?branch=master)](http://travis-ci.org/antono/shelr.tv)

[Shelr.tv](http://shelr.tv/) is a service and a
[tool for terminal screencasting](https://github.com/antono/shelr).
Service allow you to share your terminal records like
[this](http://shelr.tv/records/4f427daf96a5690001000003).

# Quickstart for Developers

Ruby 1.9.1+ required.

    sudo apt-get install mongodb-server openjdk-6-jre
    bundle install
    bundle exec rake db:seed
    bundle exec foreman start

# Contributions welcome!

- fork
- add spec
- add feature
- [make sure other test pass](http://shelr.tv/records/4f8333f096608050cd000003)
- create pull request
- enjoy :)


[TV]: http://shelr.tv/
