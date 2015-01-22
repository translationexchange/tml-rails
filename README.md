<p align="center">
  <img src="https://raw.github.com/tml/tml/master/doc/screenshots/tmllogo.png">
</p>

Tml for Ruby on Rails
===================================
[![Build Status](https://travis-ci.org/translationexchange/tml-rails.png?branch=master)](https://travis-ci.org/translationexchange/tml-rails)
[![Coverage Status](https://coveralls.io/repos/translationexchange/tml-rails/badge.png)](https://coveralls.io/r/translationexchange/tml-rails)
[![Gem Version](https://badge.fury.io/rb/tml-rails.png)](http://badge.fury.io/rb/tml-rails)
[![Dependency Status](https://www.versioneye.com/user/projects/53cda6a5225426f1e8000165/badge.svg?style=flat)](https://www.versioneye.com/user/projects/53cda6a5225426f1e8000165)

This Client SDK provides tools for translating Rails applications into any language using the TranslationExchange.com service.


Installation
===================================

To integrate Tml SDK into your own application, add the gem to your app:

Add the following gem to your Gemfile:

```ruby
gem 'tml-rails'
```

Install the gems:

```sh
$ bundle install
```


Configuration
===================================

Create a tml initializer file with the following configuration:

config/initializers/tml.rb

```ruby
Tml.configure do |config|
  config.application = {
    :token => YOUR_APPLICATION_TOKEN,
  }
  config.cache = {
    :adapter    => 'rails',
    :version    => 1
  }
end
```

Tml must be used with caching enabled.

If you are already using Rails caching, you probably already specify it in your production file, like the following:

config/environments/production.rb

```ruby
config.cache_store = :mem_cache_store, Dalli::Client.new('localhost:11211', {:namespace => 'myapplication'})
config.identity_cache_store = :mem_cache_store, Dalli::Client.new('localhost:11211', {:namespace => 'myapplication'})
```

Then all you need to do is specify that you want to use the Rails cache adapter:

config/initializers/tml.rb

```ruby
config.cache = {
  :enabled    => true,
  :adapter    => 'rails',
  :version    => 1
}
```

Alternatively, you can provide a separate memcache server to store your translations:

```ruby
config.cache = {
    :enabled  => true,
    :adapter  => 'memcache',
    :host     => 'localhost:11211',
    :version  => 1,
    :timeout  => 3600
}
```

You can also use Redis to persist your translations cache:

```ruby
config.cache = {
    :enabled  => true,
    :adapter  => 'redis',
    :host     => 'localhost:6379',
    :version  => 1,
    :timeout  => 3600
}
```

The above examples use shared caching model - all your Rails processes on all your servers share the same translation cache. This approach
will save you memory space, as well as allow you to invalidate/redeploy your translations cache without having to redeploy your application.

To update the cache, execute the following line of code:

```ruby
Tml.cache.upgrade_version
```

Or you can run the rake command from any of your app instances:

```sh
$ bundle exec rake tml:cache:upgrade
```

This will effectively invalidate your current cache and rebuilt it with the latest translations from Translation Exchange CDN.

An alternative approach is to pre-generate all your cache files when you deploy your application. The translation cache will be loaded and stored in every process on every server,
but it will be faster at serving translations and this approach does not require cache warmup.

To specify in-memory, file-based cache, provide the following configuration:

```ruby
config.cache = {
  :enabled    => true,
  :adapter    => 'file',
  :path       => 'config/tml',
  :version    => 'current',
  :segmented  => false
}
```

If you set ':segmented' to 'true', the cache will be generated for each source in your application. Otherwise, a single cache file will be generated per language for the entire application.

The file based cache must be generated before you deploy your application using the following command:

```sh
$ bundle exec rake tml:cache:generate
```

You can also rollback to the previous file cache using:

```sh
$ bundle exec rake tml:cache:rollback
```


Integration
===================================

In the HEAD section of your layout, add:

```ruby
<%= tml_scripts_tag %>
```

Now you can simply add the default language selector anywhere on your page using:

```ruby
<%= tml_language_selector_tag %>
```

The default language selector is used to enable/disable translation modes. It may be useful on staging or translation
server, but it may not be ideal on production. There are a number of alternative language selectors you can use, including your own.

To use a dropdown language selector that uses locale in the url parameter, use:

```ruby
<%= tml_language_selector_tag(:dropdown, {
    :style => "margin-top:15px",
    :language => :english
}) %>
```

To use a list language selector that uses locale in the url parameter, use:

```ruby
<%= tml_language_selector_tag(:list, {
    :style => "margin-top:15px",
    :language => :english
}) %>
```

If you want to see just a list of flags, use:

```ruby
<%= tml_language_selector_tag(:list, {
    :flags_only => true
}) %>
```

Now you can use Tml's helper methods and TML (Translation Markup Language) to translate your strings:

```ruby
<%= tr("Hello World") %>
<%= tr("You have {count || message}", count: 5) %>
<%= tr("{actor} sent {target} [bold: {count || gift}]", actor: actor_user, target: target_user, count: 5) %>
<%= tr("{actor} uploaded [bold: {count || photo}] to {actor | his, her} photo album.", actor: current_user, count: 5) %>
  ...
```

There are some additional methods that can be very useful. For instance, if you want to translate something inside a model,
you can simply use:

```ruby
"Hello World".translate
```

Learn more about TML at: http://TranslationExchange.com/docs


I18n fallback
===================================

If your application is already using the standard i18n framework, you can mix in the Tml framework on top of it. To do so,
you need to set the i18n backend to Tml. Add the following line to your tml initializer:

config/initializers/tml.rb

```ruby
I18n.backend = I18n::Backend::Tml.new
```

Now the "t" function will automatically fallback onto "tr" function. If you have the following in your base language file:

config/locales/en.yml

```ruby
en:
  hello: "Hello world"
  my:
    nested:
      key: "This is a nested key"
```

Then you can call:

```ruby
<%= t(:hello) %>
<%= t("my.nested.key") %>
```

And the i18n will use Translation Exchange as the backend for your translations. On top of it, you can continue using Tml's extensions:

```ruby
<%= tr("Hello World") %>
<%= tr("This is a nested key") %>
```

The above calls are equivalent. 


Logging
===================================

Tml comes with its own logger. If you would like to see what the SDK is doing behind the scene, enable the logger and provide the file path for the log file:

```ruby
Tml.configure do |config|

  config.logger  = {
      :enabled  => true,
      :path     => "#{Rails.root}/log/tml.log",
      :level    => 'debug'
  }

end
```

Customization
===================================

Tml comes with default settings for the rules engine. For example, it assumes that you have the following methods in your ApplicationController:

```ruby
def current_user
end

def current_locale
end
```

Tml only needs the current_user method if your site needs to use gender based rules for the viewing user.

Similarly, if you prefer to use your own mechanism for storing and retrieving user's preferred and selected locales, you can provide the current_locale method.

If you need to adjust those method names, you can set them in the config:

```ruby
Tml.configure do |config|

  config.current_user_method = :my_user

  config.current_locale_method = :my_locale

end
```


Tml Client SDK Sample
===================================

The best way to start using the SDK is to run a sample application that comes bundled with this SDK.

```sh
$ git clone https://github.com/tml/tml_rails_clientsdk.git
$ cd tml_rails_clientsdk/spec/dummy
$ bundle
```

Before you running the application, visit TranslationExchange.com, register as a new user and create a new application.

Update your key and secret in the following file:  config/initializers/tml.rb

```ruby
config.application = {
    :key => YOUR_KEY,
    :secret => YOUR_SECRET
}
```

Now you can start the application by running:

```sh
$ bundle exec rails s
```


This will start the dummy application on port 3000. Open your browser and point to:

http://localhost:3000


Links
==================

* Register on TranslationExchange.com: http://translationexchange.com

* Read Translation Exchange documentation: http://translationexchange.com/docs

* Follow TranslationExchange on Twitter: https://twitter.com/translationx

* Connect with TranslationExchange on Facebook: https://www.facebook.com/translationexchange

* If you have any questions or suggestions, contact us: feedback@translationexchange.com


Copyright and license
==================

Copyright (c) 2015 Translation Exchange Inc

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.