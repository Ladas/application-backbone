class EditableTableBuilder
  @render_tbody: (obj) ->
    EditableTableBuilder.obj = obj

    EditableTableBuilder.html = ""

    EditableTableBuilder.make_table()

    return EditableTableBuilder.html

  @make_table: ->
    row_count = 0
    for row in EditableTableBuilder.obj.data
      do (row) ->
        row_count += 1
        EditableTableBuilder.html += '<tr data-row-count-number="' + row_count  + '"'
        EditableTableBuilder.html += ' data-row-id="' + row.row_id  + '">'

        # todo make possible to insertt function on the first or last column
        EditableTableBuilder.add_row_checkboxes(row, row_count)
        EditableTableBuilder.add_row_functions(row, row_count)
        EditableTableBuilder.add_row_columns(row, row_count)

        EditableTableBuilder.html += '</tr>'

    EditableTableBuilder.add_summary_row()

  @add_summary_row: ->
    functions_present = EditableTableBuilder.obj.row? && EditableTableBuilder.obj.row.functions?

    # code for sumarizes of the page (paginated)
    summarize_page_present = false
    summarize_page = ""
    summarize_page += '<tr class="summarize_page">'
    # todo make sure functions collumn got skipped when placement is different, eg. on the end
    summarize_page += '<td class="summarize" colspan="2"><span class="label">Celkem na stránce: </span></td>' if EditableTableBuilder.obj.checkboxes?
    summarize_page += '<td class="summarize"></td>' if functions_present
    col_count = 0
    for col in EditableTableBuilder.obj.columns
      do (col) ->
        col_count += 1
        # the sumarize label has 2 colspan, so it has to be without 1 first column if there is no function column
        unless col_count == 1 && !functions_present
          summarize_page += '<td class="summarize ' + col.class + '">'
          if col.summarize_page? || col.summarize_page_value?
            summarize_page_present = true
            summarize_page += '<div class="summarize_page">'
            summarize_page += if col.summarize_page_label? then col.summarize_page_label else ''
            summarize_page += '<span class="value">'
            summarize_page += if col.summarize_page_value? then col.summarize_page_value else 0
            summarize_pagel += '</span>'
            summarize_page += '</div>'

          summarize_page += '</td>'
    summarize_page += '</tr>'


    EditableTableBuilder.html += summarize_page if summarize_page_present

    # code for sumarizes of the all filtered data (paginated is not used)
    summarize_all_present = false
    summarize_all = ""
    summarize_all += '<tr class="summarize_all">'

    summarize_all += '<td class="summarize" colspan="2"><span class="label">Celkem: </span></td>' if EditableTableBuilder.obj.checkboxes?
    #it has colspan 2 so there is no function column
    #summarize_all += '<td class="summarize"></td>' if functions_present

    col_count = 0
    for col in EditableTableBuilder.obj.columns
      do (col) ->
        col_count += 1
        # the sumarize label has 2 colspan, so it has to without 1 first column if there is no function column
        unless col_count == 1 && !functions_present
          summarize_all += '<td class="summarize ' + col.class + '">'
          if col.summarize_all? || col.summarize_all_value?
            summarize_all_present = true
            summarize_all += '<div class="summarize_all">'
            summarize_all += if col.summarize_all_label? then col.summarize_all_label else ''
            summarize_all += '<span class="value">'
            summarize_all += if col.summarize_all_value? then col.summarize_all_value else 0
            summarize_all += '</span>'
            summarize_all += '</div>'
          summarize_all += '</td>'
    summarize_all += '</tr>'

    EditableTableBuilder.html += summarize_all if summarize_all_present

  @add_row_checkboxes: (row, row_count) ->
    if EditableTableBuilder.obj.checkboxes?
      if row_count == 1
        EditableTableBuilder.html += '<td class="chbox" '
        EditableTableBuilder.html += 'data-width-align-id="special_checbox_filtering">'
      else
        EditableTableBuilder.html += '<td class="chbox">'

      EditableTableBuilder.html += '<input type="checkbox" class="row_checkboxes" name="checkboxes[' + row.row_id + ']"'
      EditableTableBuilder.html += ' onclick="CheckboxPool.change($(this))"'
      #console.log CheckboxPool.get_pool_by_form_id(TableBuilder.obj.form_id, row.row_id)
      #console.log CheckboxPool.include_value(TableBuilder.obj.form_id, row.row_id)
      EditableTableBuilder.html += ' checked="checked"' if CheckboxPool.include_value(TableBuilder.obj.form_id, row.row_id)
      EditableTableBuilder.html += ' value="' + row.row_id + '">'


      EditableTableBuilder.html += '</td>'


  @add_row_functions: (row, row_count) ->
    if EditableTableBuilder.obj.row? && EditableTableBuilder.obj.row.functions?
      static_left_column_class = ""
      static_left_column_class = "headcol" if EditableTableBuilder.obj.static_columns_left_side?

      if row_count == 1
        EditableTableBuilder.html += '<td class="' + static_left_column_class + '"'
        EditableTableBuilder.html += 'data-width-align-id="special_functions">'
      else
        EditableTableBuilder.html += '<td class="' + static_left_column_class + '">'


      for function_name, settings of EditableTableBuilder.obj.row.functions
        EditableTableBuilder.make_row_function_button(settings, row)

      EditableTableBuilder.html += '</td>'

  @add_row_columns: (row, row_count) ->
    for col in EditableTableBuilder.obj.columns
      do (col) ->
        if row_count == 1
          EditableTableBuilder.html += '<td class="' + col.class + '"'
          EditableTableBuilder.html += 'data-width-align-id="'
          EditableTableBuilder.html += col.table if col.table?
          EditableTableBuilder.html += '___' + col.name if col.name?
          EditableTableBuilder.html += '">'
        else
          EditableTableBuilder.html += '<td class="' + col.class + '">'

        EditableTableBuilder.html += '<div class="non-breakable-collumn">' if col.non_breakable? && col.non_breakable
        if (is_hash(row[col.table + '_' + col.name]))
          # hash span or href (styled as button)
          button_settings = row[col.table + '_' + col.name]
          button_settings = {} if !button_settings?
          EditableTableBuilder.make_column_from_hash(button_settings, row, col)

        else if (is_array(row[col.table + '_' + col.name]))
          # array of hashes (probably buttons)
          one_cell_buttons = row[col.table + '_' + col.name]
          for one_cell_button in one_cell_buttons
            do (one_cell_button) ->
              one_cell_button = {} if !one_cell_buttons?
              EditableTableBuilder.make_column_from_hash(one_cell_button, row, col)

        else if (is_string(row[col.table + '_' + col.name]))
          # its just string
          text = ""
          text = row[col.table + '_' + col.name] if row[col.table + '_' + col.name]?
          text = row[col.name] if row[col.name]? && text? && text.length <= 0

          sliced_text = text
          if (col.max_text_length)
            max = col.max_text_length - 3
            sliced_text = sliced_text.slice(0, col.max_text_length) + "..." if ( max > 0 && sliced_text.length > max)

          EditableTableBuilder.html += '<span title="' + text + '">' + sliced_text + '</span>'

        else
          # its something else eg. number cant be sliced, or its probably aliens Kveigars
          text = ""
          text = row[col.table + '_' + col.name] if row[col.table + '_' + col.name]?
          text = row[col.name] if row[col.name]? && text? && text.length <= 0
          # console.log[text]

          EditableTableBuilder.html += '<span title="' + text + '">' + text + '</span>'
        EditableTableBuilder.html += '</div>' if col.non_breakable? && col.non_breakable
        EditableTableBuilder.html += '</td>'


  @make_href_button: (settings, row, col) ->
    sliced_text = settings['name']
    if col?
      if (col.max_text_length)
        max = col.max_text_length - 3
        sliced_text = sliced_text.slice(0, col.max_text_length) + "..." if ( max > 0 && sliced_text.length > max)

    it_is_link = false
    it_is_link = true if (settings.url || settings.symlink_controller || settings.symlink_action || settings.symlink_id || settings.symlink_outer_controller || settings.symlink_outer_id)


    if it_is_link
      stringified_settings = JSON.stringify(settings)

      stringified_settings = stringified_settings.replace(/"/g, '&quot;')
      # this is crutial unless the double quotes will fuck up html
      non_ajax_url = build_get_url(settings)
      EditableTableBuilder.html += '<a href="' + non_ajax_url + '"'
    else
      EditableTableBuilder.html += '<span'

    EditableTableBuilder.html += ' class="' + settings.class + '"' if settings.class?
    if settings.title?
      EditableTableBuilder.html += ' title="' + settings.title + '"'
    else
      EditableTableBuilder.html += ' title="' + settings.name + '"'

    EditableTableBuilder.html += ' data-tr_class="' + settings.tr_class + '"' if  settings.tr_class?
    EditableTableBuilder.html += ' data-td_class="' + settings.td_class + '"' if  settings.td_class? && settings.td_class.length > 0

    if it_is_link
      if (settings.confirm)
        EditableTableBuilder.html += ' onclick="if (confirm(\'' + settings.confirm + '\')){ load_page(' + stringified_settings + ',this); }; return false;"'
      else
        EditableTableBuilder.html += ' onclick="load_page(' + stringified_settings + ',this); return false;"'

    else if settings.js_code?
      # a javascrip code can be passed, it will be put as onclick javascript of the button
      EditableTableBuilder.html += ' onclick="' + settings.js_code
      EditableTableBuilder.html += '"'

    EditableTableBuilder.html += '>' + sliced_text

    if it_is_link
      EditableTableBuilder.html += '</a>'
    else
      EditableTableBuilder.html += '</span>'




  @make_row_function_button: (button_settings, row, col) ->
    button_settings.symlink_id = row.row_id if row?
    # only for generic row functions, they are defined without the id
    EditableTableBuilder.make_href_button(button_settings, row, col)

  @make_column_from_hash: (button_settings, row, col) ->
    button_settings['origin'] = 'table'
    EditableTableBuilder.make_href_button(button_settings, row, col)


window.EditableTableBuilder = EditableTableBuilder





