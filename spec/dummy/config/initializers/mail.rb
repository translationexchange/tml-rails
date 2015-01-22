ActionMailer::Base.default_url_options = { host: "http://geni.berkovich.net", only_path: false}
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.asset_host = 'http://geni.berkovich.net'
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address: "smtp.gmail.com",
  port: 587,
  domain: "tmlhub.com",
  authentication: "plain",
  enable_starttls_auto: true,
  user_name: "noreply@tmlhub.com",
  password: "perestroika"
}

