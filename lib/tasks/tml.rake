#--
# Copyright (c) 2016 Translation Exchange Inc. http://translationexchange.com
#
#  _______                  _       _   _             ______          _
# |__   __|                | |     | | (_)           |  ____|        | |
#    | |_ __ __ _ _ __  ___| | __ _| |_ _  ___  _ __ | |__  __  _____| |__   __ _ _ __   __ _  ___
#    | | '__/ _` | '_ \/ __| |/ _` | __| |/ _ \| '_ \|  __| \ \/ / __| '_ \ / _` | '_ \ / _` |/ _ \
#    | | | | (_| | | | \__ \ | (_| | |_| | (_) | | | | |____ >  < (__| | | | (_| | | | | (_| |  __/
#    |_|_|  \__,_|_| |_|___/_|\__,_|\__|_|\___/|_| |_|______/_/\_\___|_| |_|\__,_|_| |_|\__, |\___|
#                                                                                        __/ |
#                                                                                       |___/
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require 'tml'

namespace :tml do

  desc 'initializes tml'
  task :init => :environment do
    unless File.exists?("#{Rails.root}/config/initializers/tml.rb")
      root = File.expand_path('../templates', __FILE__)
      system "cp #{root}/tml.rb #{Rails.root}/config/initializers"
      puts 'Please update config/initializers/tml.rb with your application token'
    else
      puts 'Tml initializer file already exists'
    end
  end

  namespace :cache do

    namespace :shared do
      ##########################################
      ## Shared Cache Management
      ##########################################

      desc 'upgrades shared translation cache'
      task :upgrade => :environment do
        Tml.cache.upgrade_version
      end

      desc 'warms up dynamic cache'
      task :warmup => :environment do
        Tml.cache.warmup
      end
    end

    namespace :local do
      ##########################################
      ## Local Cache Management
      ##########################################

      desc 'downloads local file cache'
      task :download => :environment do
        Tml.cache.download
      end

      desc 'rolls back to the previous version'
      task :rollback => :environment do
        raise "Not yet supported"
        # Tml.cache.rollback
      end

      desc 'rolls up to the next version'
      task :rollup => :environment do
        raise "Not yet supported"
        # Tml.cache.rollup
      end
    end

  end

end