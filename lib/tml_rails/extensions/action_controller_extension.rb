#--
# Copyright (c) 2017 Translation Exchange Inc. http://translationexchange.com
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

      base.before_action :tml_filter_init
      base.after_action :tml_filter_reset

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

      # Overwrite this method in a controller to assign a custom source for all views
      def tml_source
        "/#{controller_name}/#{action_name}"
      rescue
        "/classes/#{self.class.name}"
      end

      # Locale is retrieved from method => params => cookie => subdomain => browser accepted locales
      # Alternatively, this method can be overwritten
      def tml_locale
        # if locale has been passed by a param, it will be in the params hash
        if Tml.config.locale_strategy == 'param'
          return params[Tml.config.locale_param]  # will be nil without ?locale=:locale
        end

        if Tml.config.locale_strategy == 'pre-path'
          return params[Tml.config.locale_param]  # will be nil without /:locale
        end

        if Tml.config.locale_strategy == 'pre-domain'
          locale = request.subdomains.first
          if locale.nil? or not locale.match(Tml.config.locale_expression)
            locale = Tml.config.locale[:default]
          end
          return locale
        end

        if Tml.config.locale_strategy == 'custom-domain'
          host = "#{request.host}#{[80, 443].include?(request.port) ? '' : ":#{request.port}"}"
          locale = Tml.config.locale[:mapping].invert[host]  # will be nil if host is wrong
          return locale
        end

        nil
      end

      def tml_viewing_user
        unless Tml.config.current_user_method.blank?
          begin
            self.send(Tml.config.current_user_method)
          rescue
            {}
          end
        end
      end

      def tml_translator
        if tml_cookie[:translator]
          Tml::Translator.new(tml_cookie[:translator])
        else
          nil
        end
      end

      def tml_access_token
        tml_cookie[:oauth] ? tml_cookie[:oauth][:token] : nil
      end

      def tml_init
        return if Tml.config.disabled?

        # Tml.logger.info(tml_cookie.inspect)

        @tml_started_at = Time.now

        requested_locale = desired_locale = tml_locale

        # if user has a custom method for providing the locale, use it
        if Tml.config.current_locale_method
          begin
            desired_locale = self.send(Tml.config.current_locale_method)
          rescue
            desired_locale = requested_locale
          end
        end
        # check if locale was previously stored in a cookie
        desired_locale ||= Tml.config.locale_cookie_enabled? ? tml_cookie[:locale] : nil
        # fallback onto the browser locale
        desired_locale ||= Tml.config.locale_browser_enabled? ? Tml::Utils.browser_accepted_locales(
            request.env['HTTP_ACCEPT_LANGUAGE']
        ).join(',') : nil

        # pp requested_locale: requested_locale, desired_locale: desired_locale
        # pp cookie: tml_cookie

        # init SDK with desired locale and get the actual locale supported in the app
        Tml.session.init(
            :source => tml_source,
            :locale => desired_locale,
            :user => tml_viewing_user,
            :translator => tml_translator,
            :access_token => tml_access_token
        )

        if defined? I18n.enforce_available_locales
          I18n.enforce_available_locales = false
        end
        I18n.locale = tml_current_locale

        # pp current_locale: tml_current_locale

        # check if we want to store the last selected locale in the cookie
        if requested_locale == tml_current_locale and Tml.config.locale_cookie_enabled?
          tml_cookie[:locale] = tml_current_locale
          cookies[Tml::Utils.cookie_name(Tml.config.application[:key])] = {
              :value => Tml::Utils.encode(tml_cookie),
              :expires => 1.year.from_now,
              :domain => Tml.config.locale[:domain]
          }
        end

        # pp cookie: tml_cookie
        # pp redirect: Tml.config.locale_redirect_enabled?

        if Tml.config.locale_redirect_enabled?
          if Tml.config.locale[:skip_default] and tml_current_locale == tml_default_locale
            # first lets see if we are in default locale and user doesn't want to show locale in url
            if Tml.config.locale_strategy == 'pre-path' and not requested_locale.nil?
              return redirect_to(Tml.config.locale_param => nil)
            end

            if Tml.config.locale_strategy == 'pre-domain' and request.subdomains.any?
              fragments = request.host.split('.')
              if fragments.first.match(Tml.config.locale_expression)
                if Tml.config.locale[:default_subdomain]
                  fragments[0] = Tml.config.locale[:default_subdomain]
                else
                  fragments.shift
                end
              end
              return redirect_to(host: fragments.join('.'))
            end

            if Tml.config.locale_strategy == 'custom-domain'
              host = Tml.config.locale[:mapping][tml_default_locale]
              return redirect_to(host: host)
            end
          elsif requested_locale != tml_current_locale
            # otherwise, the locale is not the same as what was requested, deal with it
            if Tml.config.locale_strategy == 'pre-path'
              return redirect_to(Tml.config.locale_param => tml_current_locale)
            end

            if Tml.config.locale_strategy == 'pre-domain'
              fragments = request.host.split('.')
              if request.subdomains.any?
                fragments[0] = tml_current_locale
              else
                fragments.unshift(tml_current_locale)
              end
              return redirect_to(host: fragments.join('.'))
            end

            if Tml.config.locale_strategy == 'custom-domain'
              host = Tml.config.locale[:mapping][tml_current_locale]
              host ||= Tml.config.locale[:mapping][tml_default_locale]
              return redirect_to(host: host)
            end
          end
        end

        if tml_current_translator and tml_current_translator.inline?
          I18n.reload!
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
