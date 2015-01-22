I18n.backend = I18n::Backend::Tml.new

Tml.configure do |config|
  #config.application = {
  #  host: 'http://localhost:3000',
  #  token: 'aeb938d5b4fb594eec30949b382b26724a687ea9da9512953e767c9e5385cafd'
  #}

  #config.application = {
  #    :host => "http://localhost:3000",
  #    :key => "cc62cc02bc9f1d63c",
  #    :secret => "8014944c3385a280e"
  #}

  config.application = {
      token: '5f4ec93364b0bd70ecee17d4ea1bfb8d0d4a7764cbf3d77280c69f555f286454'
  }

  config.cache = {
    :enabled    => true,
    :adapter    => 'file',
    :path       => 'config/tml',
    :version    => 'current',
    :segmented  => false
  }

  #config.cache = {
  #  :enabled    => true,
  #  :namespace  => 'e9f98513e9d32e5b8a4dada73f57bba3c6c38e8417b4e83794c32a72cb08cdf8',
  #  :adapter    => 'memcache',
  #  :host       => 'localhost:11211',
  #  :version    => 1,
  #  :timeout    => 3600
  #}

  #config.cache = {
  #  :enabled    => true,
  #  :adapter    => 'rails',
  #  :version    => 1
  #}

  config.logger  = {
    :enabled  => true,
    :path     => "#{Rails.root}/log/tml.log",
    :level    => 'debug'
  }
end