module ModelMixins
  module TableSettingsInterface
    def table_settings
      settings = TableSettings.new(self)
      yield(settings) if block_given?
      settings
    end
  end
end
