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
  get 'emails/deliver' => 'emails#deliver'

  get 'emails/postoffice' => 'emails#postoffice'
  post 'emails/postoffice' => 'emails#postoffice'

  get 'samples/language_cases' => 'samples#language_cases'
  get 'samples/dates' => 'samples#dates'
  get 'samples/ignored' => 'samples#ignored'

  get 'samples/locales' => 'samples#locales'

  get 'i18n' => 'i18n#index'
end