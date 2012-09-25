
class TableSettings
  attr_accessor :table_settings

  class Column
    attr_accessor :index

    def initialize(table_settings, index)
      @table_settings = table_settings
      @column_hash = {}
      @index = index
    end

    def column_hash
      @column_hash
    end

    def css_class(class_name)
      @column_hash[:class] = class_name

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

    ##
    # Defines select expression for column (ie. select count(id) as counter)
    #
    def sql_expression(expression)
      @column_hash[:sql_expression] = expression
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

    # Sets global format method used for values
    def global_format_method(method_name)
      @column_hash[:global_format_method] = method_name

      self
    end

    # Sets if column has summarization cell per page
    # Standard column will be computed
    # Custom column have to set TableSettings::Buttons.summarize_page_value in callback method
    #
    # @param [Boolean] enabled - has/has not this cell
    # @param [String|nil] label in this cell (for example "Summary")
    #
    def summarize_page(enabled = true, label = nil)
      @column_hash[:summarize_page] = true
      @column_hash[:summarize_page_label] = label unless label.nil?
      self
    end

    # Sets if column has summarization cell per table
    # Standard column will be computed
    # Custom column have to set TableSettings::Buttons.summarize_all_value in callback method
    #
    # @param [Boolean] enabled - has/has not this cell
    # @param [String|nil] label in this cell (for example "Summary")
    #
    def summarize_all(enabled = true, label = nil)
      @column_hash[:summarize_all] = true
      @column_hash[:summarize_all_label] = label unless label.nil?
      self
    end

    # Defines column with non-breakable content (for example column with more buttons)
    #
    # @param [Boolean] bool
    #
    def non_breakable(bool = true)
      @column_hash[:non_breakable] = bool
      self
    end

  end

  class CustomColumn < Column


    def params( name, label, column_method, column_class   = nil, column_params  = nil)

      @column_hash = {
          :name           => name,
          :label          => label,
          :column_method  => column_method,
          :filter         => :none
      }
      @column_hash[:column_class]         = column_class         unless column_class.nil?
      @column_hash[:column_params]        = column_params        unless column_params.nil?

      self
    end
    def callback_params(params)
      @column_hash[:column_params] = params
      self
    end

    def callback_method(name)
      @column_hash[:column_method] = name
      self
    end
    def callback_class(name)
      @column_hash[:column_class] = name
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

    # Table for column
    def table(name)
      @column_hash[:table] = name
      self
    end


    def set_css_class_from_type(model)
      column_params = model.columns_hash[@column_hash[:name]]
      case column_params.type
        when :boolean then css_class("boolean")
        when :datetime then css_class("datetime")
        when :string then css_class("string")
        when :decimal then css_class("decimal")
        else nil
      end
    end

    #def column_hash
    #
    #  unless @column_hash.include?(:class)
    #    model = @column_hash[:table].classify.constantize
    #    set_css_class_from_type(model) unless model.nil?
    #  end
    #
    #  @column_hash
    #end

  end

end