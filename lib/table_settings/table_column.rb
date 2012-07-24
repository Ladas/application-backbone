
class TableSettings
  attr_accessor :table_settings

  class Column
    attr_accessor :column_hash, :index

    def initialize(table_settings, index)
      @table_settings = table_settings
      @column_hash = {}
      @index = index
    end


    def css_class(class_name)
      @column_hash[:class_name] = class_name

      self
    end

    def filter_type(filter_type)
      if filter_type == :none
        @column_hash.delete(:filter)
      else
        @column_hash[:filter] = filter_type
      end

      self
    end

    def filter_data(array)
      @column_hash[:filter_data] = array

      self
    end

    def max_text_length(length)
      @column_hash[:max_text_length] = length

      self
    end

    def format_method(method_name)
      @column_hash[:format_method] = method_name

      self
    end

    def global_format_method(method_name)
      @column_hash[:global_format_method] = method_name

      self
    end


  end

  class CustomColumn < Column


    def params( name, label, column_method, column_class   = nil, column_params  = nil)

      @column_hash = {
          :name           => name,
          :label          => label,
          :column_method  => column_method,
          :filter         => :find
      }
      @column_hash[:column_class]         = column_class         unless column_class.nil?
      @column_hash[:column_params]        = column_params        unless column_params.nil?

      self
    end
  end

  class StandardColumn < Column

    def params(name, label, table)

      @column_hash = {
          :name   => name,
          :label  => label,
          :table  => table,
          :filter => :find
      }

      self
    end
  end

end