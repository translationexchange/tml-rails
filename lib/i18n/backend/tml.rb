#--
# Copyright (c) 2015 Translation Exchange Inc. http://translationexchange.com
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

require 'i18n/backend/base'
require 'tml'
require 'pp'

module I18n
  module Backend
    class Tml < I18n::Backend::Simple

      module Implementation
        include Base, Flatten

        def application
          ::Tml.session.application
        end

        def available_locales
          application.locales
        end

        def translate(locale, key, options = {})
          super(locale, key, options).html_safe
        end

        def lookup(locale, key, scope = [], options = {})
          #pp ''
          #pp [locale, key, scope, options]

          default_key = super(application.default_locale, key, scope, options)

          #pp default_key

          default_key ||= key
          if default_key.is_a?(String)
            translated_key = default_key.gsub('%{', '{')
            translated_key = application.language(locale.to_s).translate(translated_key, options, options)
          elsif default_key.is_a?(Hash)
            translated_key = {}
            default_key.each do |key, value|
              value = value.gsub('%{', '{')
              translated_key[key] =  application.language(locale.to_s).translate(value, options, options)
            end
          end

          #pp translated_key
          translated_key
        end

      end

      include Implementation
    end
  end
end

