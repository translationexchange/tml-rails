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

module TmlRails
  module ActionViewExtension
    extend ActiveSupport::Concern

    # Translates HTML block
    # noinspection RubyArgCount
    def trh(tokens = {}, options = {}, &block)
      return '' unless block_given?

      label = capture(&block)

      tokenizer = Tml::Tokenizers::Dom.new(tokens, options)
      tokenizer.translate(label).html_safe
    end

    # Translates <select><option></option></select>
    def tml_options_for_select(options, selected = nil, description = nil, lang = Tml.session.current_language)
      options_for_select(options.tro(description), selected)
    end

    # Returns language flag
    def tml_language_flag_tag(lang = tml_current_language, opts = {})
      return '' unless tml_application.feature_enabled?(:language_flags)
      html = image_tag(lang.flag_url, :style => (opts[:style] || 'vertical-align:middle;'), :title => lang.native_name)
      html << '&nbsp;&nbsp;'.html_safe
      html.html_safe
    end

    # Returns language name
    def tml_language_name_tag(lang = tml_current_language, opts = {})
      show_flag = opts[:flag].nil? ? true : opts[:flag]
      name_type = opts[:language].nil? ? :english : opts[:language].to_sym # :full, :native, :english, :locale, :both

      html = []
      html << "<span style='white-space: nowrap'>"
      html << tml_language_flag_tag(lang, opts) if show_flag
      html << "<span dir='ltr'>"

      if name_type == :both
        html << lang.english_name.to_s
        html << '<span class="trex-native-name">'
        html << lang.native_name
        html << '</span>'
      else
        name = case name_type
          when :native  then lang.native_name
          when :full then lang.full_name
          when :locale  then lang.locale
          else lang.english_name
        end
        html << name.to_s
      end

      html << '</span></span>'
      html.join.html_safe
    end

    # Returns language selector UI
    def tml_language_selector_tag(type = nil, opts = {})
      return unless Tml.config.enabled?

      type ||= :default
      type = :dropdown if type == :select

      opts = opts.collect{|key, value| "data-tml-#{key}='#{value}'"}.join(' ')
      "<div data-tml-language-selector='#{type}' #{opts}></div>".html_safe
    end

    def tml_scripts_tag(opts = {})
      return '' unless Tml.config.enabled?

      if opts[:js]
        js_opts = opts[:js].is_a?(Hash) ? opts[:js] : {}
        js_host = js_opts[:host] || 'https://tools.translationexchange.com/tml/stable/tml.min.js'
        html = []
        html << "<script src='#{js_host}'></script>"
        html << '<script>'
        html << 'tml.init({'
        html << "    key:    '#{tml_application.key}', "
        html << "    token:  '#{tml_application.token}', "
        html << "    debug: #{js_opts[:debug] || false},"
        if js_opts[:onload]
          html << '    onLoad: function() {'
          html << "       #{js_opts[:onload]}"
          html << '    }'
        end
        html << '});'
        html << '</script>'
        return html.join.html_safe
      end

      agent_config = Tml.config.respond_to?(:agent) ? Tml.config.agent : {}
      agent_host = agent_config[:host] || 'https://tools.translationexchange.com/agent/stable/agent.min.js'
      if agent_config[:cache]
        t = Time.now
        t = t - (t.to_i % agent_config[:cache].to_i).seconds
        agent_host += "?ts=#{t.to_i}"
      end

      agent_config[:locale] = tml_current_locale
      agent_config[:source] = tml_current_source
      agent_config[:css] = tml_application.css
      agent_config[:sdk] = Tml.respond_to?(:full_version) ? Tml.full_version : Tml::VERSION
      agent_config[:languages] = []

      tml_application.languages.each do |lang|
        agent_config[:languages] << {
            locale: lang.locale,
            english_name: lang.english_name,
            native_name: lang.native_name,
            flag_url: lang.flag_url
        }
      end

      html = []
      html << '<script>'
      html << '(function() {'
      html << "var script = window.document.createElement('script');"
      html << "script.setAttribute('id', 'tml-agent');"
      html << "script.setAttribute('type', 'application/javascript');"
      html << "script.setAttribute('src', '#{agent_host}');"
      html << "script.setAttribute('charset', 'UTF-8');"
      html << 'script.onload = function() {'
      html << "   Trex.init('#{tml_application.key}', #{agent_config.to_json.html_safe});"
      html << '};'
      html << "window.document.getElementsByTagName('head')[0].appendChild(script);"
      html << '})();'
      html << '</script>'
      html.join.html_safe
    end

    def tml_select_month(date, options = {}, html_options = {})
      month_names = options[:use_short_month] ? Tml.config.default_abbr_month_names : Tml.config.default_month_names
      select_month(date, options.merge(
        :use_month_names => month_names.collect{|month_name| tml_current_language.translate(month_name, options[:description] || "Month name")}
      ), html_options)
    end

    def tml_with_options_tag(opts, &block)
      if Tml.config.disabled?
        return capture(&block) if block_given?
        return ""
      end

      Tml.session.push_block_options(opts)

      if block_given?
        ret = capture(&block)
      end

      Tml.session.pop_block_options
      ret
    end
    alias_method :tml_block, :tml_with_options_tag

    def tml_source(source, &block)
      tml_with_options_tag({source: source}, &block)
    end

    def tml_when_string_tag(time, opts = {})
      elapsed_seconds = Time.now - time
      if elapsed_seconds < 0
        tr('In the future, Marty!', 'Time reference')
      elsif elapsed_seconds < 2.minutes
        tr('a moment ago', 'Time reference')
      elsif elapsed_seconds < 55.minutes
        elapsed_minutes = (elapsed_seconds / 1.minute).to_i
        tr('{minutes || minute} ago', 'Time reference', :minutes => elapsed_minutes)
      elsif elapsed_seconds < 1.75.hours
        tr('about an hour ago', 'Time reference')
      elsif elapsed_seconds < 12.hours
        elapsed_hours = (elapsed_seconds / 1.hour).to_i
        tr('{hours || hour} ago', 'Time reference', :hours => elapsed_hours)
      elsif time.today_in_time_zone?
        display_time(time, :time_am_pm)
      elsif time.yesterday_in_time_zone?
        tr("Yesterday at {time}", 'Time reference', :time => time.tr(:time_am_pm).gsub('/ ', '/').sub(/^[0:]*/,""))
      elsif elapsed_seconds < 5.days
        time.tr(:day_time).gsub('/ ', '/').sub(/^[0:]*/,"")
      elsif time.same_year_in_time_zone?
        time.tr(:monthname_abbr_time).gsub('/ ', '/').sub(/^[0:]*/, '')
      else
        time.tr(:monthname_abbr_year_time).gsub('/ ', '/').sub(/^[0:]*/, '')
      end
    end

    def tml_url_tag(path)
      tml_application.url_for(path)
    end

    ######################################################################
    ## Language Direction Support
    ######################################################################

    # switches CSS positions based on the language direction
    # <%= tml_style_attribute_tag('float', 'right') %> => "float: right" : "float: left"
    # <%= tml_style_attribute_tag('align', 'right') %> => "align: right" : "align: left"
    def tml_style_attribute_tag(attr_name = 'float', default = 'right', lang = tml_current_language)
      return "#{attr_name}:#{default}".html_safe if Tml.config.disabled?
      "#{attr_name}:#{lang.align(default)}".html_safe
    end

    # supports directional CSS attributes
    # <%= tml_style_directional_attribute_tag('padding', 'right', '5px') %> => "padding-right: 5px" : "padding-left: 5px"
    def tml_style_directional_attribute_tag(attr_name = 'padding', default = 'right', value = '5px', lang = tml_current_language)
      return "#{attr_name}-#{default}:#{value}".html_safe if Tml.config.disabled?
      "#{attr_name}-#{lang.align(default)}:#{value}".html_safe
    end

    # provides the locale and direction of the language
    def tml_html_attributes_tag(lang = tml_current_language)
      "xml:lang='#{lang.locale}' #{tml_lang_attribute_tag(lang)} #{tml_dir_attribute_tag(lang)}".html_safe
    end
    alias_method :tml_lang_attributes_tag, :tml_html_attributes_tag

    # providers the direction of the language
    def tml_dir_attribute_tag(lang = tml_current_language)
      return "dir='ltr'" if Tml.config.disabled?
      "dir='#{lang.dir}'".html_safe
    end

    # provides the locale of the language
    def tml_lang_attribute_tag(lang = tml_current_language)
      return "lang='en-US'" if Tml.config.disabled?
      "lang='#{lang.locale}'".html_safe
    end

    def tml_stylesheet_link_tag(ltr, rtl, attrs = {})
      if tml_current_language.right_to_left?
        stylesheet_link_tag(rtl, attrs)
      else
        stylesheet_link_tag(ltr, attrs)
      end
    end

  end
end
