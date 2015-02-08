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

    def self.included(base)
      base.send(:include, TmlRails::ActionCommonMethods)
      base.send(:include, InstanceMethods) 
      base.before_filter :tml_init_client_sdk
      base.after_filter :tml_reset_client_sdk
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

      def tml_browser_accepted_locales
        @tml_browser_accepted_locales ||= Tml::Utils.browser_accepted_locales(request)
      end

      def tml_user_preferred_locale
        tml_browser_accepted_locales.each do |locale|
          next unless Tml.session.application.locales.include?(locale)
          return locale
        end
        Tml.config.default_locale
      end
      
      # Overwrite this method in a controller to assign a custom source for all views
      def tml_source
        "/#{controller_name}/#{action_name}"
      rescue
        self.class.name
      end

      # Overwrite this method in a controller to assign a custom component for all views
      def tml_component
        nil
      end

      def tml_toggle_tools(flag)
        session[:tml_tools_disabled] = !flag
      end

      def tml_tools_enabled?
        not session[:tml_tools_disabled]
      end

      def tml_init_client_sdk
        return if Tml.config.disabled?

        @tml_started_at = Time.now

        if params[:tml]
          tml_toggle_tools(params[:tml] == 'on')
        end

        tml_session_params = {
          :tools_enabled    => tml_tools_enabled?,
          :source           => tml_source,
          :component        => tml_component
        }

        if Tml.config.current_user_method
          begin
            tml_session_params.merge!(:user => self.send(Tml.config.current_user_method))
          rescue
            # Tml.logger.error('Current user method is specified but not provided')
          end
        end

        if Tml.config.current_locale_method
          begin
            tml_session_params.merge!(:locale => self.send(Tml.config.current_locale_method))
          rescue
            # Tml.logger.error('Current locale method is specified but not provided')
          end
        end

        unless tml_session_params[:locale]
          tml_session_params.merge!(:cookies => cookies)
          tml_session_params.merge!(:change_locale => true) if params[:locale]
          tml_session_params.merge!(:locale => params[:locale] || tml_user_preferred_locale)
        end

        Tml.session.init(tml_session_params)

        # if user sets locale manually, update the cookie for future use
        if tml_session_params[:change_locale]
          cookies[Tml.session.cookie_name] = Tml::Utils.encode(Tml.session.cookie_params)
        end

        if defined? I18n.enforce_available_locales
          I18n.enforce_available_locales = false
        end
        I18n.locale = Tml.session.current_language.locale
      end

      def tml_reset_client_sdk
        return if Tml.config.disabled?
        @tml_finished_at = Time.now
        tml_application.submit_missing_keys
        Tml.session.reset
        Tml.logger.info("Request took #{@tml_finished_at - @tml_started_at} mls") if @tml_started_at
      end

    end
  end
end
