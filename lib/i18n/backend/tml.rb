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

require 'i18n/backend/base'
require 'tml'
require 'pp'

module I18n
  module Backend
    class Tml < I18n::Backend::Simple

      module Implementation
        include Base, Flatten

        # Returns current application
        def application
          ::Tml.session.application
        end

        # List of all application available locales
        def available_locales
          application.locales
        end

        # we will capture interpolation here - so we can process it ourselves using TML
        def interpolate(locale, string, values = {})
          string
        end

        # TODO: this should be configurable. Our SDK supports both notations.
        def convert_to_tml(str)
          str.gsub('%{', '{')
        end

        # Translates a hash of values
        def translate_hash(target_language, hash, options)
          hash.each do |key, value|
            if value.is_a?(String)
              hash[key] = target_language.translate(convert_to_tml(value), options, options)
            elsif value.is_a?(Hash)
              translate_hash(target_language, value, options)
            end
          end

          hash
        end

        # Translates a string
        def translate(locale, key, options = {})
          # TODO: we don't support this yet - but we should
          return super if I18n.locale != locale

          # look up the translation in default locale
          translation = super(application.default_locale, key, options)

          # pp [locale, key, options, translation]

          # if no translation is available, ignore it
          return translation if translation.nil? or translation == ''

          # if language is not available, return default value
          target_language = application.language(locale.to_s)

          # if target language not set, return default locale
          return translation unless target_language

          if translation.is_a?(String)
            translation = target_language.translate(convert_to_tml(translation), options, options)
          elsif translation.is_a?(Hash)
            translation = translate_hash(target_language, translation, options)
          end

          translation
        end

      end

      include Implementation
    end
  end
end

