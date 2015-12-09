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

require 'rspec'

require 'simplecov'
require 'coveralls'
require 'json'

SimpleCov.start

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)
require 'rspec/rails'

require 'tml-rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

def fixtures_root
  File.join(File.dirname(__FILE__), 'fixtures')
end

def load_json(file_path)
  JSON.parse(File.read("#{fixtures_root}/#{file_path}"))
end

def load_translation_keys_from_file(app, path)
  load_json(path).each do |jkey|
    load_translation_key_from_hash(app, jkey)
  end
end

def load_translation_key_from_hash(app, hash)
  app.cache_translation_key(Tml::TranslationKey.new(hash.merge(:application => app)))
end

def stub_object(attrs)
  user = double()
  attrs.each do |key, value|
    user.stub(key) { value }
  end
  user
end

def init_application(locales = [], path = 'application.json')
  locales = ['en-US', 'ru'] if locales.size == 0
  app = Tml::Application.new(load_json(path))
  locales.each do |locale|
    app.add_language(Tml::Language.new(load_json("languages/#{locale}.json")))
  end
  Tml.session.application = app
  Tml.session.current_language = app.language('en-US')
  app
end

RSpec.configure do |config|
  config.before do
    ARGV.replace []
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  def capture(stream)
    begin
      stream = stream.to_s
      eval "$#{stream} = StringIO.new"
      yield
      result = eval("$#{stream}").string
    ensure
      eval("$#{stream} = #{stream.upcase}")
    end

    result
  end

  def source_root
    fixtures_root
  end

  def destination_root
    File.join(File.dirname(__FILE__), 'sandbox')
  end

  alias :silence :capture
end

