class ActiveAdmin::Railtie < ::Rails::Railtie
  # Add load paths straight to I18n, so engines and application can overwrite it.
  require 'active_support/i18n'
  I18n.load_path += Dir[File.expand_path('../../../../../config/locales/*.yml', __FILE__)]
end
