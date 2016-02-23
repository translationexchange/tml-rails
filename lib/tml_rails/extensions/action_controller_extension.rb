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

module TmlRails
  module ActionControllerExtension

    # add functionality upon inclusion
    def self.included(base)
      base.send(:include, TmlRails::ActionCommonMethods)
      base.send(:include, InstanceMethods)

      base.before_filter :tml_filter_init
      base.after_filter :tml_filter_reset

      if defined? base.rescue_from
        base.rescue_from 'Tml::Exception' do |e|
          Tml.logger.error(e)
          Tml.logger.error(e.backtrace)
          Tml.session.reset
          raise e
        end
      end
    end

    module InstanceMethods

      # Returns all browser accepted locales
      def tml_browser_accepted_locales
        @tml_browser_accepted_locales ||= Tml::Utils.browser_accepted_locales(request.env['HTTP_ACCEPT_LANGUAGE']).join(',')
      end

      # Overwrite this method in a controller to assign a custom source for all views
      def tml_source
        "/#{controller_name}/#{action_name}"
      rescue
        self.class.name
      end

      # Returns data from cookie set by the agent
      def tml_cookie
        @tml_cookie ||= begin
          cookie = cookies[Tml::Utils.cookie_name(Tml.config.application[:key])]
          if cookie.blank?
            {}
          else
            HashWithIndifferentAccess.new(Tml::Utils.decode(cookie, Tml.config.application[:token]))
          end
        end
      rescue Exception => ex
        Tml.logger.error("Failed to parse tml cookie: #{ex.message}")
        {}
      end

      # Locale is retrieved from method => params => cookie => subdomain => browser accepted locales
      # Alternatively, this method can be overwritten
      def tml_locale
        @tml_locale ||= begin
          locale = nil

          unless Tml.config.current_locale_method.blank?
            begin
              locale = self.send(Tml.config.current_locale_method)
            rescue
              locale = nil
            end
          end

          if locale.nil?
            if params[:locale].blank?
              locale = tml_cookie[:locale]
              if locale.nil?
                if Tml.config.locale[:subdomain]
                  locale = request.subdomain
                else
                  locale = tml_browser_accepted_locales
                end
              end
            else
              locale = tml_cookie[:locale] = params[:locale]
              cookies[Tml::Utils.cookie_name(Tml.config.application[:key])] = Tml::Utils.encode(tml_cookie, Tml.config.application[:token])
            end
          end

          locale
        end
      end

      def tml_viewing_user
        @tml_viewing_user ||= begin
          unless Tml.config.current_user_method.blank?
            begin
              self.send(Tml.config.current_user_method)
            rescue
              {}
            end
          end
        end
      end

      def tml_translator
        @tml_translator ||= begin
          if tml_cookie[:translator]
            Tml::Translator.new(tml_cookie[:translator])
          else
            nil
          end
        end
      end

      def tml_access_token
        tml_cookie[:oauth] ? tml_cookie[:oauth][:token] : nil
      end

      def tml_init
        return if Tml.config.disabled?

        # Tml.logger.info(tml_cookie.inspect)

        @tml_started_at = Time.now

        Tml.session.init(
            :source => tml_source,
            :locale => tml_locale,
            :user => tml_viewing_user,
            :translator => tml_translator,
            :access_token => tml_access_token
        )

        if I18n.backend.class.name == 'I18n::Backend::Tml'
          if defined? I18n.enforce_available_locales
            I18n.enforce_available_locales = false
          end
          I18n.locale = Tml.session.current_language.locale
        end
      end

      def tml_filter_init
        tml_init if Tml.config.auto_init
      end

      def tml_reset
        return if Tml.config.disabled?
        @tml_finished_at = Time.now
        Tml.session.application.submit_missing_keys if Tml.session.application
        Tml.session.reset
        Tml.cache.reset_version
        Tml.logger.info("Request took #{@tml_finished_at - @tml_started_at} mls") if @tml_started_at
        Tml.logger.info('-----------------------------------------------------------')
      end

      def tml_filter_reset
        tml_reset if Tml.config.auto_init
      end

    end
  end
end
