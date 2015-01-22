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
  module ActionViewExtension
    extend ActiveSupport::Concern

    def trh(tokens = {}, options = {}, &block)
      return '' unless block_given?

      label = capture(&block)

      tokenizer = Tml::Tokenizers::Dom.new(tokens, options)
      tokenizer.translate(label).html_safe
    end

    def tml_options_for_select(options, selected = nil, description = nil, lang = Tml.session.current_language)
      options_for_select(options.tro(description), selected)
    end

    def tml_phrases_link_tag(search = "", phrase_type = :without, phrase_status = :any)
      return unless Tml.config.enabled?
      return if tml_current_language.default?
      return unless tml_current_translator.inline?

      link_to(image_tag(tml_application.url_for("/assets/tml/translate_icn.gif"), :style => "vertical-align:middle; border: 0px;", :title => search),
              tml_application.url_for("/tml/app/phrases/index?search=#{search}")).html_safe
    end

    def tml_language_flag_tag(lang = tml_current_language, opts = {})
      return "" unless tml_application.feature_enabled?(:language_flags)
      html = image_tag(lang.flag_url, :style => "vertical-align:middle;", :title => lang.native_name)
      html << "&nbsp;".html_safe 
      html.html_safe
    end

    def tml_language_name_tag(lang = tml_current_language, opts = {})
      show_flag = opts[:flag].nil? ? true : opts[:flag]
      name_type = opts[:name].nil? ? :full : opts[:name] # :full, :native, :english, :locale
      linked = opts[:linked].nil? ? true : opts[:linked] 

      html = "<span style='white-space: nowrap'>"
      html << tml_language_flag_tag(lang, opts) if show_flag
      html << "<span dir='ltr'>"

      name = case name_type
        when :native  then lang.native_name
        when :english then lang.english_name
        when :locale  then lang.locale
        else lang.full_name
      end

      html << name
      html << "</span></span>"
      html.html_safe
    end

    def tml_language_selector_tag(type = nil, opts = {})
      return unless Tml.config.enabled?
      render(:partial => '/tml_rails/tags/language_selector', :locals => {:type => type, :opts => opts})
    end

    def tml_language_strip_tag(opts = {})
      opts[:flag] = opts[:flag].nil? ? false : opts[:flag]
      opts[:name] = opts[:name].nil? ? :native : opts[:name] 
      opts[:linked] = opts[:linked].nil? ? true : opts[:linked] 
      opts[:javascript] = opts[:javascript].nil? ? false : opts[:javascript] 

      render(:partial => '/tml_rails/tags/language_strip', :locals => {:opts => opts})
    end

    def tml_flashes_tag(opts = {})
      render(:partial => '/tml_rails/tags/flashes', :locals => {:opts => opts})
    end

    def tml_scripts_tag(opts = {})
      render(:partial => '/tml_rails/tags/scripts', :locals => {:opts => opts})
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

    def tml_style_attribute_tag(attr_name = 'float', default = 'right', lang = tml_current_language)
      return "#{attr_name}:#{default}".html_safe if Tml.config.disabled?
      "#{attr_name}:#{lang.align(default)}".html_safe
    end

    def tml_style_directional_attribute_tag(attr_name = 'padding', default = 'right', value = '5px', lang = tml_current_language)
      return "#{attr_name}-#{default}:#{value}".html_safe if Tml.config.disabled?
      "#{attr_name}-#{lang.align(default)}:#{value}".html_safe
    end

    def tml_dir_attribute_tag(lang = tml_current_language)
      return "dir='ltr'" if Tml.config.disabled?
      "dir='#{lang.dir}'".html_safe
    end

    def tml_lang_attribute_tag(lang = tml_current_language)
      return "lang='en-US'" if Tml.config.disabled?
      "lang='#{lang.locale}'".html_safe
    end

  end
end
