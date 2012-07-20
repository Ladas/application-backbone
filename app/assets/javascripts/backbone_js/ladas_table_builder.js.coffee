class TableBuilder
  @render_tbody:(obj) ->
    TableBuilder.obj = obj

    TableBuilder.html = ""

    TableBuilder.make_table()

    return TableBuilder.html

  @make_table: ->
    for row in TableBuilder.obj.data
      do (row) ->
        TableBuilder.html += '<tr>'

        TableBuilder.add_row_functions()
        TableBuilder.add_row_columns(row)

        TableBuilder.html += '</tr>'
  @make_row: ->


  @add_row_functions: ->
    if (TableBuilder.obj.row.functions)
      TableBuilder.html += '<td>'

      for function_name in TableBuilder.obj.row.functions.data
        do (function_name) ->
          settings = o.row.functions[function_name]
          TableBuilder.make_href_button(settings,undefined, row)

      TableBuilder.html += '</td>'

  @add_row_columns:(row) ->
    for col in TableBuilder.obj.columns
      do (col) ->
        TableBuilder.html += '<td class="' + col.class + '">'

        if (is_hash(row[col.table + '_' + col.name]))
          # hash span or href (styled as button)
          button_settings = row[col.table + '_' + col.name]
          TableBuilder.make_column_from_hash(button_settings, row, col)

        else if (is_array(row[col.table + '_' + col.name]))
          # array of hashes (probably buttons)
          one_cell_buttons = row[col.table + '_' + col.name]
          for one_cell_button in one_cell_buttons
            do (one_cell_button) ->
              TableBuilder.make_column_from_hash(one_cell_button, row, col)

        else if (is_string(row[col.table + '_' + col.name]))
          # its just string
          text = ""
          text = row[col.table + '_' + col.name] if row[col.table + '_' + col.name]?
          sliced_text = text
          if (col.max_text_length)
            max = col.max_text_length - 3
            sliced_text = sliced_text.slice(0, col.max_text_length) + "..." if ( max > 0 && sliced_text.length > max)

          TableBuilder.html += '<span title="' + text + '">' + sliced_text + '</span>'

        else
          # its something else eg. number cant be sliced, or its probably aliens Kveigars
          text = ""
          text = row[col.table + '_' + col.name] if row[col.table + '_' + col.name]?

          TableBuilder.html += '<span title="' + text + '">' + text + '</span>'

        TableBuilder.html += '</td>'


  @make_href_button:(settings, col, row) ->
    settings.symlink_id = row.row_id if row?  # only for generic row functions, they are defined without the id


    sliced_text = settings['name']
    if col?
      if (col.max_text_length)
        max = col.max_text_length - 3
        sliced_text = sliced_text.slice(0, col.max_text_length) + "..." if ( max > 0 && sliced_text.length > max)

    it_is_link = false
    it_is_link = true if (settings.url || settings.symlink_controller || settings.symlink_action || settings.symlink_id || settings.symlink_outer_controller || settings.symlink_outer_id)


    if it_is_link
      stringified_settings = JSON.stringify(settings)

      stringified_settings = stringified_settings.replace(/"/g,'&quot;') # this is crutial unless the double quotes will fuck up html
      non_ajax_url = build_get_url(settings)
      TableBuilder.html += '<a href="' + non_ajax_url + '"'
    else
      TableBuilder.html += '<span'

    TableBuilder.html += ' class="' + settings.class + '"' if settings.class?
    TableBuilder.html += ' title="' + settings.name + '"'
    TableBuilder.html += ' data-tr_class="' + settings.tr_class + '"' if  settings.tr_class?
    TableBuilder.html += ' data-td_class="' + settings.td_class + '"' if  settings.td_class? && settings.td_class.length > 0

    if it_is_link
      if (settings.confirm)
        TableBuilder.html += ' onclick="if (confirm(\'' + settings.confirm + '\')){ load_page(' + stringified_settings + ',this); }; return false;"'
      else
        TableBuilder.html +=  ' onclick="load_page(' + stringified_settings + ',this); return false;"'

    TableBuilder.html += '>' + sliced_text

    if it_is_link
      TableBuilder.html +='</a>'
    else
      TableBuilder.html += '</span>'




  @make_column_from_hash:(button_settings, row, col) ->
    button_settings['origin'] = 'table'
    TableBuilder.make_href_button(button_settings, col, row)


window.TableBuilder = TableBuilder





