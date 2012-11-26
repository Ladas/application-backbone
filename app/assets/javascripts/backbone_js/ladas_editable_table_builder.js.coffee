class EditableTableBuilder
  @render_tbody: (obj) ->
    EditableTableBuilder.obj = obj

    EditableTableBuilder.html = ""

    EditableTableBuilder.make_table()


    return EditableTableBuilder.html


  @update_rows: (obj) ->
    EditableTableBuilder.obj = obj
    EditableTableBuilder.invalidate_sumarizatios(obj)

    row_count = 0
    for row in EditableTableBuilder.obj.data
      do (row) ->
        EditableTableBuilder.html = ""
        row_count += 1

        # load and render new row
        EditableTableBuilder.add_row_checkboxes(row, row_count)
        EditableTableBuilder.add_row_functions(row, row_count)
        EditableTableBuilder.add_row_columns(row, row_count)



        row_color = ""
        if EditableTableBuilder.obj.row_colors?
          if EditableTableBuilder.obj.row_colors[row.row_id]?
            row_color = EditableTableBuilder.obj.row_colors[row.row_id]["color"]
            row_background_color  = EditableTableBuilder.obj.row_colors[row.row_id]["background_color"]

        # update row
        $('.centerContainer tr[data-row-id="' + row.row_id + '"]').html(EditableTableBuilder.html).css({"background-color" : row_background_color, "color" : row_color })

    EditableTableAligner.align_after_rows_update(obj)

  #############################################################################33
  ##############################private #######################################333
  ##############################################################################33


  @make_table: ->
    CheckboxPool.checkboxes_initialize()
    row_count = 0
    for row in EditableTableBuilder.obj.data
      do (row) ->
        row_count += 1
        EditableTableBuilder.html += '<tr data-row-count-number="' + row_count + '"'

        if EditableTableBuilder.obj.row_colors?
          if EditableTableBuilder.obj.row_colors[row.row_id]?
            style = 'color:' + EditableTableBuilder.obj.row_colors[row.row_id]["color"]
            style += '; background-color:' + EditableTableBuilder.obj.row_colors[row.row_id]["background_color"]
            EditableTableBuilder.html += ' style="' + style+ '"'

        EditableTableBuilder.html += ' data-row-id="' + row.row_id + '">'

        # todo make possible to insertt function on the first or last column
        EditableTableBuilder.add_row_checkboxes(row, row_count)
        EditableTableBuilder.add_row_functions(row, row_count)
        EditableTableBuilder.add_row_columns(row, row_count)

        EditableTableBuilder.html += '</tr>'

    CheckboxPool.checkboxes_finalize()
    EditableTableBuilder.add_summary_row()

  @add_summary_row: ->
    functions_present = EditableTableBuilder.obj.row? && EditableTableBuilder.obj.row.functions?

    # code for sumarizes of the page (paginated)
    summarize_page_present = false
    summarize_page = ""
    summarize_page += '<tr class="summarize_page" data-row-count-number="summarize_page">'
    # todo make sure functions collumn got skipped when placement is different, eg. on the end

    if EditableTableBuilder.obj.static_columns_left_side?
      summarize_page += '<td class="summarize headcol" colspan="2"><span class="label">Celkem na stránce: </span></td>' if EditableTableBuilder.obj.checkboxes?
      summarize_page += '<td class="summarize headcol">Celkem na stránce: </td>' if functions_present && !EditableTableBuilder.obj.checkboxes?
    else
      summarize_page += '<td class="summarize headcol" colspan="2"><span class="label">Celkem na stránce: </span></td>' if EditableTableBuilder.obj.checkboxes?
      summarize_page += '<td class="summarize headcol">Celkem na stránce: </td>' if functions_present && !EditableTableBuilder.obj.checkboxes?

    #headcol" if ((EditableTableBuilder.obj.static_columns_left_side).indexOf(col.name) != -1)

    col_count = 0
    for col in EditableTableBuilder.obj.columns
      do (col) ->
        col_count += 1
        # the sumarize label has 2 colspan, so it has to be without 1 first column if there is no function column
        unless col_count == 1 && !functions_present
          summarize_page += '<td class="summarize ' + col.class
          summarize_page += " headcol" if ((EditableTableBuilder.obj.static_columns_left_side).indexOf(col.name) != -1)
          summarize_page += '">'

          if col.summarize_page? || col.summarize_page_value?
            summarize_page_present = true
            summarize_page += '<div class="summarize_page non-breakable-collumn">'
            summarize_page += if col.summarize_page_label? then col.summarize_page_label else ''
            summarize_page += '<span class="value">'
            # todo ladas toto je treba uzavrit do formatovani jedne bunky
            if col.summarize_page_value?
              if (is_hash(col.summarize_page_value ))
                if col.summarize_page_value.name?
                  summarize_page += col.summarize_page_value.name
                else
                  summarize_page += 0
              else
                summarize_page += col.summarize_page_value
            else
              summarize_page += 0

            summarize_page += '</span>'
            summarize_page += '</div>'

          summarize_page += '</td>'
    summarize_page += '</tr>'


    EditableTableBuilder.html += summarize_page if summarize_page_present

    # code for sumarizes of the all filtered data (paginated is not used)
    summarize_all_present = false
    summarize_all = ""
    summarize_all += '<tr class="summarize_all" data-row-count-number="summarize_all">'

    if EditableTableBuilder.obj.static_columns_left_side?
      summarize_all += '<td class="summarize headcol" colspan="2"><span class="label">Celkem: </span></td>' if EditableTableBuilder.obj.checkboxes?
        #it has colspan 2 so there is no function column
      summarize_all += '<td class="summarize headcol">Celkem: </td>' if functions_present && !EditableTableBuilder.obj.checkboxes?
    else
      summarize_all += '<td class="summarize headcol" colspan="2"><span class="label">Celkem: </span></td>' if EditableTableBuilder.obj.checkboxes?
      #it has colspan 2 so there is no function column
      summarize_all += '<td class="summarize headcol">Celkem: </td>' if functions_present && !EditableTableBuilder.obj.checkboxes?

    col_count = 0
    for col in EditableTableBuilder.obj.columns
      do (col) ->
        col_count += 1
        # the sumarize label has 2 colspan, so it has to without 1 first column if there is no function column
        unless col_count == 1 && !functions_present
          summarize_all += '<td class="summarize ' + col.class
          summarize_all += " headcol" if ((EditableTableBuilder.obj.static_columns_left_side).indexOf(col.name) != -1)
          summarize_all += '">'

          if col.summarize_all? || col.summarize_all_value?
            summarize_all_present = true
            summarize_all += '<div class="summarize_all non-breakable-collumn">'
            summarize_all += if col.summarize_all_label? then col.summarize_all_label else ''
            summarize_all += '<span class="value">'
            # todo ladas toto je treba uzavrit do formatovani jedne bunky
            if col.summarize_all_value?
              if (is_hash(col.summarize_all_value ))
                if col.summarize_all_value.name?
                  summarize_all += col.summarize_all_value.name
                else
                  summarize_all += 0
              else
                summarize_all += col.summarize_all_value
            else
              summarize_all += 0
            summarize_all += '</span>'
            summarize_all += '</div>'
          summarize_all += '</td>'
    summarize_all += '</tr>'

    EditableTableBuilder.html += summarize_all if summarize_all_present

  @add_row_checkboxes: (row, row_count) ->
    if EditableTableBuilder.obj.checkboxes?

      el_class = "chbox"
      el_class += static_left_column_class = " headcol" if EditableTableBuilder.obj.static_columns_left_side?

      if row_count == 1
        EditableTableBuilder.html += '<td class="' + el_class + '" '
        EditableTableBuilder.html += 'data-width-align-id="special_checbox_filtering"'
      else
        EditableTableBuilder.html += '<td class="' + el_class + '" '
      EditableTableBuilder.html += '">'

      EditableTableBuilder.html += '<input type="checkbox" class="row_checkboxes" name="checkboxes[' + row.row_id + ']"'
      EditableTableBuilder.html += ' onclick="CheckboxPool.change($(this))"'
      #console.log CheckboxPool.get_pool_by_form_id(TableBuilder.obj.form_id, row.row_id)
      #console.log CheckboxPool.include_value(TableBuilder.obj.form_id, row.row_id)
      if CheckboxPool.include_value(EditableTableBuilder.obj.form_id, row.row_id)
        EditableTableBuilder.html += ' checked="checked"'
      else
        # if not all checkboxes are checkde, the main checkboxes will not be checked
        CheckboxPool.checkboxes_not_all_checked()
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

      # todo editacni tabulka si bude mit fixni vysku radku
      EditableTableBuilder.html += '<div class="non-breakable-collumn">' if true
      #col.non_breakable? && col.non_breakable

      for function_name, settings of EditableTableBuilder.obj.row.functions
        EditableTableBuilder.make_row_function_button(settings, row)

      EditableTableBuilder.html += '</div>'
      EditableTableBuilder.html += '</td>'

  @add_row_columns: (row, row_count) ->
    for col in EditableTableBuilder.obj.columns
      do (col) ->
        cell_name = ""
        cell_name += col.table if col.table?
        cell_name += '___' + col.name if col.name?


        EditableTableBuilder.html += '<td '

        if EditableTableBuilder.obj.cell_colors?
          if EditableTableBuilder.obj.cell_colors[row.row_id]?
            if EditableTableBuilder.obj.cell_colors[row.row_id][col.name]?
              style  = 'background-color:' + EditableTableBuilder.obj.cell_colors[row.row_id][col.name]["background_color"] + ' !important'
              style += '; color:' + EditableTableBuilder.obj.cell_colors[row.row_id][col.name]["color"] + ' !important'
              EditableTableBuilder.html += ' style="' + style + '"'

        if col.editable?
          EditableTableBuilder.html += ' data-cell-identifier="' + cell_name + "___" + row.row_id + '"'
          EditableTableBuilder.html += ' onclick="EditableTableModalDialog.show(this, \'' + EditableTableBuilder.obj.editable_table_edit_cell_path + '\')"'

        # row number 1 of body is for width synchronizin with header (if I edit first row, it will affect all others)
        if row_count == 1
          EditableTableBuilder.html += ' data-width-align-id="'
          EditableTableBuilder.html += cell_name
          EditableTableBuilder.html += '"'

        EditableTableBuilder.html += ' class="' + col.class
        # adding colhead class, determines if it will be moved to static left column
        EditableTableBuilder.html += " headcol" if ((EditableTableBuilder.obj.static_columns_left_side).indexOf(col.name) != -1)
        EditableTableBuilder.html += " editable_cell" if col.editable?
        EditableTableBuilder.html += '"'

        EditableTableBuilder.html += '">'

        # todo editacni tabulka si bude mit fixni vysku radku
        EditableTableBuilder.html += '<div class="non-breakable-collumn">' if true
        #col.non_breakable? && col.non_breakable

        active_cell
        if EditableTableBuilder.valid_table(col.table)
          active_cell = row[col.table + '_' + col.name]
        else
          active_cell = row[col.name]



        if (is_hash(active_cell))
          # hash span or href (styled as button)
          button_settings = active_cell
          button_settings = {} if !button_settings?
          EditableTableBuilder.make_column_from_hash(button_settings, row, col)

        else if (is_array(active_cell))
          # array of hashes (probably buttons)
          one_cell_buttons = active_cell
          for one_cell_button in one_cell_buttons
            do (one_cell_button) ->
              one_cell_button = {} if !one_cell_buttons?
              EditableTableBuilder.make_column_from_hash(one_cell_button, row, col)

        else if (is_string(active_cell))
          # its just string
          text = ""
          text = row[col.table + '_' + col.name] if row[col.table + '_' + col.name]?
          text = row[col.name] if row[col.name]? && text? && text.length <= 0

          sliced_text = text
          if (col.max_text_length)
            max = col.max_text_length - 3
            sliced_text = sliced_text.slice(0, col.max_text_length) + "..." if ( max > 0 && sliced_text.length > max)
          else
            # i will be always slicing
            max = 30
            sliced_text = sliced_text.slice(0, max + 3) + "..." if ( max > 0 && sliced_text.length > max)

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

    # todo ladas asi prohodit i v table builder, pokud se zada js_code onclick, mel bz mit prioritu
    if settings.js_code?
      # a javascrip code can be passed, it will be put as onclick javascript of the button
      EditableTableBuilder.html += ' onclick="' + settings.js_code
      EditableTableBuilder.html += '"'

    else if it_is_link
      if (settings.confirm)
        EditableTableBuilder.html += ' onclick="if (confirm(\'' + settings.confirm + '\')){ load_page(' + stringified_settings + ',this); }; return false;"'
      else
        EditableTableBuilder.html += ' onclick="load_page(' + stringified_settings + ',this); return false;"'



    EditableTableBuilder.html += '>' + sliced_text

    if it_is_link
      EditableTableBuilder.html += '</a>'
    else
      EditableTableBuilder.html += '</span>'

  @valid_table: (table_name) ->
    if (table_name == "___sql_expression___")
      false
    else
      true


  @make_row_function_button: (button_settings, row, col) ->
    button_settings.symlink_id = row.row_id if row?
    # only for generic row functions, they are defined without the id
    EditableTableBuilder.make_href_button(button_settings, row, col)

  @make_column_from_hash: (button_settings, row, col) ->
    button_settings['origin'] = 'table'
    EditableTableBuilder.make_href_button(button_settings, row, col)

  @invalidate_sumarizatios: (obj) ->
    # if row gets updated, summarizations must be invalidated
    $("#" + obj.form_id).find('td.summarize span').each (index, element) =>
      $(element).html('<a href="#" class="btn btn-success" onclick="$(this).parents(\'form\').submit();return false;" title="Data byla změněna, prosím klikněte zde pro obnovení.">Obnovit</a>')


window.EditableTableBuilder = EditableTableBuilder





