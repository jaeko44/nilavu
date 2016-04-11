Nilavu::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true

  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  config.assets.debug = false
  # Log level to debug
  config.log_level = :debug
  # to ignore the javascript files loaded in public assets, this results in running post twice in JQuery
  config.serve_static_files = false

  config.react.variant = :development

  require 'rbtrace'
  
  if emails = GlobalSetting.developer_emails
    config.developer_emails = emails.split(",").map(&:strip)
  end
end
