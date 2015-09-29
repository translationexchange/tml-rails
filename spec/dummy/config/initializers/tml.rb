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

  if Rails.env.development?
    config.application = {
        key:    '1671c1f1b90d1dad894e43b4edd0ed20eca453dfb77c889d098db3e140de018e',
        token:  '23dc0805cf21d7c3342115455ab7355706c14922e207c5b38b641b16e7d38dc3',
        host:   'http://localhost:3000'
    }

    # config.cache = {
    #     :enabled    => true,
    #     :adapter    => 'file',
    #     :version    => 'current'
    # }

    # If you are using Rails.cache, use the following settings:

    # config.cache = {
    #  enabled: true,
    #  adapter: :rails
    # }

    # If you are using Redis, use the following settings:

    config.cache = {
      :enabled   => true,
      :adapter   => 'redis',
      :host      => 'localhost',
      :port      => 6379,
      :db        => 0,
      :namespace => '2dsfsd312312',
    }

    # If you are using Memcache, use the following settings:

    # config.cache = {
    #  :enabled    => true,
    #  :adapter    => 'memcache',
    #  :host       => 'localhost:11211',
    #  :namespace  => '2dsfsd312312',
    # }

    # For debugging, uncomment the following lines:

    config.logger  = {
      enabled: true,
      path:   "#{Rails.root}/log/tml.log",
      level:  'debug'
    }

    # To use Rails logger instead, use:

    #config.logger  = {
    #    :enabled  => true,
    #    :type     => :rails
    #}

    config.agent = {
      enabled:  true,
      type:     'agent',
      version:  'stable',
      domains:  {
        api:        'http://localhost:3000',
        tools:      'http://localhost:3002',
        analytics:  'https://analyst.translationexchange.com'
      }
    }
  else

    # For now, let's test real API from staging

    config.application = {
        host:   'https://api.translationexchange.com',
        key:    '4581b9ba74f26387ec3f74d269e6a6424bac68978e608c18b4d47e39f84875be',
        token:  'd6105e2f05548756b116d7eb8e07642422bc8510b580a4c1685037dfd8ca39b3'
    }

    config.agent = {
        enabled:  true,
        type:     'agent',
        version:  'stable',
        domains:  {
          api:        'https://api.translationexchange.com',
          tools:      'https://translation-center.translationexchange.com',
          analytics:  'https://analyst.translationexchange.com'
        }
    }

  end

end