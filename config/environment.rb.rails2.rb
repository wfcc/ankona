EMAIL_FROM = 'dia-x automated message <bot@dia-x.info>'

# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
  config.active_record.timestamped_migrations = false

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  config.gem 'authlogic'
  config.gem 'mislav-will_paginate',
   :version => '~> 2.3.8',
   :lib => 'will_paginate',
   :source => 'http://gems.github.com'
  config.gem "searchlogic"
  config.gem "RedCloth", :lib => 'redcloth'
  config.gem 'random_data'
  config.gem 'gd2'
  config.gem 'validatable'  
  config.gem 'formtastic'
  
                 
end
                
#Haml::Template.options[:escape_html] = true
