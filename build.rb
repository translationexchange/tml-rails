#!/usr/bin/env ruby
require './lib/tml_rails/version'

def run(cmd)
  print '$ ' + cmd + "\n"
  system(cmd)
end

run('rspec')
run('gem build tml-rails.gemspec')
run("gem install tml-rails-#{TmlRails::VERSION}.gem --no-ri --no-rdoc")

if ARGV.include?('release')
  run("gem push tml-rails-#{TmlRails::VERSION}.gem")
end
