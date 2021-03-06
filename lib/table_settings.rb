require 'table_settings/table_column.rb'
require 'table_settings/table_action.rb'
require 'table_settings/detail_table.rb'
require 'table_settings/table_button.rb'


class TableSettings

  attr_reader :errors

  ##
  # Inicializace
  #
  # @param [Symbol] model
  #
  def initialize(model)
    @settings = {:columns => [], :row => {}, :default => {}, :csv => {}}
    @model = model
    @default_table = table_name_from_model(model)

    @column_index = 0
    @columns = []
    @actions = []
    @errors = {}

    add_defaults
  end

  ##
  # Vysledny hash pro renderovani tabulky
  #
  # @return [Hash]
  def hash
    construct_columns if @settings[:columns].empty?
    construct_actions if @settings[:row][:functions].blank?

    @settings[:row].delete(:functions) if @settings[:row][:functions].empty?

    @settings
  end

  def refresh_settings
    @settings[:columns] = []
    construct_settings
  end

  ##
  # Prida standardni sloupec do tabulky
  #
  # @params [String] name  - nazev sloupce v db
  # @params [String] label - nazev sloupce pro zobrazeni
  # @params [String] table - nazev db tabulky (nepovinne, default z konstruktoru)
  #
  # @return [TableSettings::Column]
  #
  def add_column(name,
      label = nil,
      table = @default_table)

    column = ::TableSettings::StandardColumn.new(self, @column_index)

    label = default_label(name) if label.nil?
    column.params(name, label, table)

    yield(column) if block_given?

    @columns << column
    @column_index += 1

    column
  end

  ##
  # Prida custom sloupec do tabulky
  #
  # @params [String] name - nazev sloupce v db
  # @params [String] label - nazev sloupce pro view
  # @params [String] column_method - metoda pro definováni sloupce
  # @params [String] column_class - třída, ve které se volá column_method (nepovinne, defaultne vychozi model)
  # @params [String] column_params - vlastni parametry pro column_method
  #
  # @return [TableSettings::Column]
  #
  def add_custom_column(name,
      label,
      column_method,
      column_class = nil,
      column_params = nil

  )
    column = ::TableSettings::CustomColumn.new(self, @column_index)


    label = default_label(name) if label.nil?
    column.params(name,
                  label,
                  column_method,
                  column_class,
                  column_params
    )
    yield(column) if block_given?

    @columns << column
    @column_index += 1

    column
  end

  ##
  # Prida akci/tlacitko/link do tabulky
  #
  # @params [Symbol] name - nazev akce (libovolny, mel by odpovidat akci)
  # @params [String] label - nazev akce pro view
  #
  # @return [TableSettings::Action]
  def add_action(name, label)
    action = ::TableSettings::Action.new(self)

    action.name = name
    action.label(label)

    yield(action) if block_given?

    @actions << action

    action
  end


  def form_id(id = "unique_form_id")
    @settings[:form_id] = id

    self
  end

  def row_id(row_name = "id", table_name = @default_table)
    @settings[:row][:id] = table_name.to_s+"."+row_name.to_s

    self
  end

  def order_by(row_name = "id", table_name = @default_table, use_table_name = true)
    if use_table_name && !table_name.nil?
      @settings[:default][:order_by] = table_name.to_s+"."+row_name.to_s
    else
      @settings[:default][:order_by] = row_name.to_s
      order_by_direction("")
    end
    self
  end

  # Adds or removes checkboxes from table
  def checkboxes(enabled = true)
    @settings[:checkboxes] = enabled
    self
  end

  def order_by_direction(direction = "asc")
    @settings[:default][:order_by_direction] = direction

    self
  end

  def page(number = 1)
    @settings[:default][:page] = number

    self
  end

  def per_page(number = 10)
    @settings[:default][:per_page] = number
  end

  # CSV export - filename
  def csv_name(name = 'export.csv')
    @settings[:csv][:name] = name

    self
  end

  # CSV export - exclude header row with column names
  def csv_exclude_names(exclude = true)
    @settings[:csv][:exclude_names] = exclude
    self
  end

  # CSV export - exclude header row with column labels
  def csv_exclude_labels(exclude = true)
    @settings[:csv][:exclude_labels] = exclude
    self
  end

  # CSV export - exclude row_id column
  def csv_exclude_row_id(exclude = true)
    @settings[:csv][:exclude_row_id] = exclude
    self
  end

  def filter_path(path)
    @settings[:filter_path] = path

    self
  end

  #  Metoda, ze ktere se filtruje tabulka
  def filter_method(name)
    @settings[:filter_method] = name
    self
  end

  #   Metoda, ze ktere se vykresluje tabulka (default: index)
  def on_method(name)
    @settings[:show_table_method] = name
    self
  end

  ##
  # ID tagu (napr. <div>), do ktereho se ma prekreslit cela tabulka
  # (napr. pro tlacitko "Smazat filtr")
  #
  def content_id(string)
    @settings[:content_id] = string
    self
  end

  ##
  #   Rendering template je udelano s RIGHT OUTER JOIN (nevim proc)
  #   Pokud to chci v renderovani template jako normalne (kdyz zadnou nezadam), musim nastavit toto
  def standard_query_processing(aBool = true)
    @settings[:standard_query_processing] = aBool
  end

  def includes(options)
    @settings[:includes] = options

    self
  end

  def construct_columns
    @columns.each do |column|
      @settings[:columns] << column.column_hash
    end
  end

  def construct_actions
    actions = {}
    @actions.each do |action|
      actions[action.name] = action.action_hash
    end
    @settings[:row][:functions] = actions
  end


  def table_name_from_model(model)
    if model.kind_of?(ActiveRecord::Relation)
      model.klass.table_name
    else
      model.table_name
    end
  end

  def add_defaults
    form_id(@default_table+"_form_id")
    row_id()
    order_by()
    order_by_direction()
    page()

  end

  def default_label(name)
    @model.human_attribute_name(name)
  end


  def has_includes?
    @settings.has_key? :includes
  end

  def has_filter_path?
    @settings.has_key? :filter_path
  end


  def has_form_id?
    @settings.has_key? :form_id
  end


  def has_row_id?
    @settings[:row].has_key? :id
  end

  def has_defaults?
    default = @settings[:default]
    default.has_key? :order_by
    default.has_key? :order_by_direction
    default.has_key? :page
  end

  def has_order_by?
    @settings[:default].has_key? :order_by
  end


  def has_order_by_direction?
    @settings[:default].has_key? :order_by_direction
  end

  def has_page?
    @settings[:default].has_key? :page
  end


  def has_columns?
    !@columns.empty?
  end

  def settings_ok?
    has_filter_path? && has_form_id? && has_row_id? && has_defaults? && has_columns?
  end

  def set_error(type)
    @errors[type.to_sym] = [type.to_s + " " + I18n.t("errors.messages.blank")]
  end

  def valid?
    filled = nil
    filled = set_error(:filter_path) unless has_filter_path?
    filled = set_error(:form_id) unless has_form_id?
    filled = set_error(:row_id) unless has_row_id?
    filled = set_error(:order_by) unless has_order_by?
    filled = set_error(:order_by_direction) unless has_order_by_direction?
    filled = set_error(:page) unless has_page?
    filled = set_error(:columns) unless has_columns?

    filled.nil?
  end


end