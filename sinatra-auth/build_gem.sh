#!/bin/bash
gem uninstall sinatra-authentication
gem build sinatra-authentication.gemspec 
gem install sinatra-authentication
