Rails.application.routes.draw do

  mount TmlRails::Engine => '/tml_rails'

  root :to => 'home#index'

  get '/upgrade' => 'home#upgrade_cache'

  get 'home' => 'home#index'
  get 'home/index' => 'home#index'

  get 'docs/index' => 'docs#index'
  get 'docs/installation' => 'docs#installation'
  get 'docs/tml' => 'docs#tml'
  get 'docs/tml_content' => 'docs#tml_content'

  get 'docs/editor' => 'docs#editor'

  get 'emails' => 'emails#index'
  post 'emails' => 'emails#index'

  get 'samples/language_cases' => 'samples#language_cases'
  get 'samples/i18n' => 'samples#i18n'
  get 'samples/dates' => 'samples#dates'
  get 'samples/ignored' => 'samples#ignored'

end