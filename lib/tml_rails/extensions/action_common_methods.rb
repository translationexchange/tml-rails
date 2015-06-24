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
  module ActionCommonMethods
    ############################################################
    # There are three ways to call the tr method
    #
    # tr(label, desc = '', tokens = {}, options = {})
    # or
    # tr(label, tokens = {}, options = {})
    # or
    # tr(:label => label, :description => '', :tokens => {}, :options => {})
    ############################################################
    def tr(label, description = '', tokens = {}, options = {})
      params = Tml::Utils.normalize_tr_params(label, description, tokens, options)
      return params[:label].html_safe if params[:label].tml_translated?

      params[:options][:caller] = caller

      if request
        params[:options][:url]  = request.url
        params[:options][:host] = request.env['HTTP_HOST']
      end

      if Tml.config.disabled?
        return Tml.config.default_language.translate(params[:label], params[:tokens], params[:options]).tml_translated.html_safe
      end

      # Translate individual sentences
      if params[:options][:split]
        text = params[:label]
        sentences = Tml::Utils.split_by_sentence(text)
        sentences.each do |sentence|
          text = text.gsub(sentence, tml_current_language.translate(sentence, params[:description], params[:tokens], params[:options]))
        end
        return text.tml_translated.html_safe
      end

      Tml.session.target_language.translate(params).tml_translated.html_safe
    rescue Tml::Exception => ex
      #pp ex, ex.backtrace
      Tml.logger.error(ex.message)
      #Tml.logger.error(ex.message + "\n=> " + ex.backtrace.join("\n=> "))
      label
    end

    # for translating labels
    def trl(label, description = '', tokens = {}, options = {})
      params = Tml::Utils.normalize_tr_params(label, description, tokens, options)
      params[:options][:skip_decorations] = true
      tr(params)
    end

    # flash notice
    def trfn(label, desc = '', tokens = {}, options = {})
      flash[:trfn] = tr(Tml::Utils.normalize_tr_params(label, desc, tokens, options))
    end

    # flash error
    def trfe(label, desc = '', tokens = {}, options = {})
      flash[:trfe] = tr(Tml::Utils.normalize_tr_params(label, desc, tokens, options))
    end

    # flash warning
    def trfw(label, desc = '', tokens = {}, options = {})
      flash[:trfw] = tr(Tml::Utils.normalize_tr_params(label, desc, tokens, options))
    end

    ######################################################################
    ## Common methods - wrappers
    ######################################################################

    def tml_session
      Tml.session
    end

    def tml_application
      tml_session.application
    end

    def tml_current_user
      tml_session.current_user
    end

    def tml_current_translator
      tml_session.current_translator
    end

    def tml_current_locale
      tml_session.current_language.locale
    end

    def tml_current_language
      tml_session.current_language
    end

    def tml_language_dir
      tml_current_language.dir
    end

    def tml_subdomain_locale_url(locale = tml_current_locale)
      uri = URI::parse(request.url)
      host = uri.host.split('.')
      if host.count == 2
        host.unshift(locale)
      else
        host[0] = locale
      end
      uri.host = host.join('.')
      uri.to_s
    end

  end
end
