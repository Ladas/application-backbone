class TableSettings
  class Buttons
    def initialize()
      @buttons_hash = {}
      @rows = {}
    end

    def hash
      @rows.each_value do |row|
        @buttons_hash[row.id] = row.data
      end

      @buttons_hash
    end

    def add_row(row_id)
      row = TableSettings::Row.new(row_id)

      yield(row) if block_given?

      @rows[row_id] = row

      row
    end

    def add_button(row_id, label, url_path = nil)
      row = add_row(row_id) if @rows[row_id].nil?

      button = row.add_button(label, url_path)

      yield(button) if block_given?

      button
    end

  end

  class Row
    attr_reader :id

    def initialize(row_id)
      @id = row_id
      @buttons = []
    end

    def add_button(label, url_path = nil)
      button = TableSettings::Button.new(@id, label, url_path)
      yield(button) if block_given?
      @buttons << button
      button
    end

    def data
      if @buttons.empty?
        {}
      elsif @buttons.size == 1
        @buttons[0].hash
      else  @buttons.size > 1
        @buttons.collect { |button| button.hash }
      end

    end

  end


  class Button

    attr_reader :hash

    def initialize(id, label, url_path)
      @id = id
      @hash = {:name => label}
      remote(true)
      url(url_path)
    end

    def url(path)
      @hash[:url] = path
      self
    end

    def remote(boolean)
      @hash[:symlink_remote] = boolean
      self
    end

    def outer_controller(name)
      @hash[:symlink_outer_controller] = name
      self
    end

    def outer_id(id)
      @hash[:symlink_outer_id] = id
      self
    end

    def controller(name)
      @hash[:symlink_controller] = name
      self
    end

    def action(name)
      @hash[:symlink_action] = name
      self
    end

    def method(symbol)
      @hash[:method] = symbol
    end

    def css_class(name)
      @hash[:class] = name
      self
    end

    def css_class_type(type)
      css=case type
            when :show then "btn btn-success"
            when :edit then "btn btn-warning"
            when :destroy then "btn btn-danger"
            else "btn"
          end
      @hash[:class] = css
      self
    end

    def css_td_class(name)
      @hash[:td_class] = name
      self
    end
    def css_tr_class(name)
      @hash[:tr_class] = name
    end

  end
end