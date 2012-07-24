class TableSettings
  class Action
    attr_accessor :action_hash, :name

    def initialize(table_settings)
      @table_settings = table_settings
      @action_hash = {}

      add_defaults
    end

    def label(label)
      @action_hash[:name] = label
      self
    end

    def add_defaults
      @action_hash[:symlink_remote] = true
      self
    end

    def controller(name)
      @action_hash[:symlink_controller] = name
      self
    end

    def action(name)
      @action_hash[:symlink_action] = name
      self
    end
    def outer_controller(name)
      @action_hash[:symlink_outer_controller] = name
      self
    end
    def outer_id(name)
      @action_hash[:symlink_outer_id] = name
      self
    end

    def remote(bool)
      @action_hash[:symlink_remote] = bool
      self
    end

    def http_method(name)
      @action_hash[:method] = name
      self
    end

    def css_class(name)
      @action_hash[:class] = name
      self
    end



  end
end