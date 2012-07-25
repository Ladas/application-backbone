module ControllerMixins
  module TableSettingsInterface
    delegate :url_helpers, to: 'Rails.application.routes'

    require "table_settings.rb"

  end
end