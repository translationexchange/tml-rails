#--
# Copyright (c) 2015 Translation Exchange Inc.
#
# http://translationexchange.com
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

I18n.backend = I18n::Backend::Tml.new

Tml.configure do |config|
  config.application = {
      token: '5f4ec93364b0bd70ecee17d4ea1bfb8d0d4a7764cbf3d77280c69f555f286454'
      # token: '4b673d6ba5f4f9109668653962f4f2b34ad6e77d1a3de21ffbf7bf51b874993d',
      # host: 'http://localhost:3000'
  }

  # config.cache = {
  #     :enabled    => true,
  #     :adapter    => 'file',
  #     :version    => 'current'
  # }

  # If you are using Rails.cache, use the following settings:

  config.cache = {
   :enabled    => true,
   :adapter    => :rails,
   :version    => 1
  }

  # If you are using Redis, use the following settings:

  #config.cache = {
  #    :enabled   => true,
  #    :adapter   => 'redis',
  #    :host      => 'localhost',
  #    :port      => 6379,
  #    :db        => 0,
  #    :namespace => 'translations',
  #}

  # If you are using Memcache, use the following settings:

  # config.cache = {
  #  :enabled    => true,
  #  :adapter    => 'memcache',
  #  :host       => 'localhost:11211',
  #  :namespace  => '4b673',
  # }

  # For debugging, uncomment the following lines:

  config.logger  = {
    :enabled  => false,
    :path     => "#{Rails.root}/log/tml.log",
    :level    => 'debug'
  }

  # To use Rails logger instead, use:

  #config.logger  = {
  #    :enabled  => true,
  #    :type     => :rails
  #}

end