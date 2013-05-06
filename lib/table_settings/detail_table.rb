class TableSettings
  class DetailTable
    attr_reader :hash

    def initialize
      @hash = {
          :only => [],
          :except => [],
          :global_format_method => {},
          :show_timestamps => false,
          :show_id => false
              }
    end

    # @return [Hash]
    def hash
      @hash.delete(:only) if @hash[:only].empty?
      @hash.delete(:except) if @hash[:except].empty?

      @hash
    end

    def add(column)
      @hash[:only] << column
      self
    end

    def exclude(column)
      @hash[:except] << column
      self
    end

    def show_timestamps(boolean)
      @hash[:show_timestamps] = boolean
      self
    end

    def show_id(boolean)
      @hash[:show_id] = boolean
      self
    end

    def class_name(name)
      @hash[:class_name] = name
      self
    end

    def caption(name)
      @hash[:caption] = caption
      self
    end

    def global_format_method(col_name, fnc_name)
      @hash[:global_format_method][col_name] = fnc_name
      self
    end

    def css_id(id)
      @hash[:id] = id
      self
    end
    def css_class(name)
      @hash[:class] = name
      self
    end

  end
end