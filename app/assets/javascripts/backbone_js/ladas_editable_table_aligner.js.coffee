class EditableTableAligner
  @align_table: (obj, xhr) ->
    # adds on first row to body, so there will always be one
    EditableTableAligner.make_leading_body_row(obj)

    # move colhead class to left column
    EditableTableAligner.align_static_left_columns(obj, xhr)

    # allowing of paired scrolling
    EditableTableAligner.paired_left_right_scrolling(obj)
    EditableTableAligner.paired_up_down_scrolling(obj)

    # align widths and heights at last after moving all columns
    # align withs of header and body of table
    EditableTableAligner.align_widths(obj)

    # aligning heights of static left or right columns and center content of table
    EditableTableAligner.align_heights(obj)


    if (obj.editable_table_automatic_size? && obj.editable_table_automatic_size)
      if !xhr
        EditableTableAligner.register_align_table_size()

  @align_after_rows_update: (obj) ->
    # adds on first row to body, so there will always be one
    EditableTableAligner.make_leading_body_row(obj)

    # tr_class td_class, etc
    apply_modifiers_of_the_table($("#" + obj.form_id));

    # move colhead class to left column
    EditableTableAligner.align_static_left_columns_after_row_update(obj)

    # align widths and heights at last after moving all columns
    # align withs of header and body of table
    EditableTableAligner.align_widths(obj)

    # aligning heights of static left or right columns and center content of table
    EditableTableAligner.align_heights(obj)


  #########################
  ### private methods #########
  ##############################
  @make_leading_body_row: (obj) ->
    unless $("#" + obj.form_id + "_ajax_content").find("tr.leading_tbody_row").length > 0
      #$("#" + obj.form_id + "_ajax_content").find("tr.leading_tbody_row").remove()

      orig  = $("#" + obj.form_id).find('tr.filtering_tr')
      new_tr = $('<tr></tr>').addClass("leading_tbody_row").css("height", "1px").css("border-width", "0").css("border", "0").attr("data-row-count-number", "leading_tbody_row")

      orig.each (index, element) =>
        $(element).find("th").each (td_index, td_element) =>
          el = $("<td></td>")
          if $(td_element).hasClass("headcol")
            el.addClass("headcol")

          el.attr("data-width-align-id", $(td_element).data("width-align-id"))


          new_tr.append(el)

      $("#" + obj.form_id + "_ajax_content").prepend(new_tr)


  @align_widths: (obj) ->
    # HAVE TO UNSET TABLE WIDTH IF AUTOSET
    #todo it then moves with the table when cell editing, i will only make it bigger
    #EditableTableAligner.unset_table_size()

    # going trough headers th
    #    console.log($("#" + obj.form_id).find('td[data-width-align-id]'))
    # todo ladas !!!!!!!1 kdyz upravuju prvni radek tak se tabulka hybe, jako prvni radek bych mozna mel dat prazdny radek s vyskou 0
    $("#" + obj.form_id).find('th[data-width-align-id]').each (index, element) =>

      # loading paired td and th
      th = $(element)

      # id of paired th and td elements
      width_align_id = th.data("width-align-id")

      td = $("#" + obj.form_id).find('td[data-width-align-id="' + width_align_id + '"]').first()
      #console.log(td)
      #careful delete one by one, or scrolling will be lost
      # have to delete it from elements, otherwise the width would increase (alwazs adding padding nad vbroder to outerWidth)
      th.css({
      'min-width': "",
      'max-width': ""
      })

      td.css({
      'min-width': "",
      'max-width': ""
      })


      # determining max width
      th_width = th.outerWidth()
      td_width = td.outerWidth()


      if th_width > td_width
        max_width = th_width
      else
        max_width = td_width


      # setting max width
      th.css({
      'min-width': max_width,
      'max-width': max_width
      })

      td.css({
      'min-width': max_width,
      'max-width': max_width
      })
    # automatic width of the table, if required
    if (obj.editable_table_automatic_size? && obj.editable_table_automatic_size)
      EditableTableAligner.align_table_size()

    return

  @paired_left_right_scrolling: (obj) ->
    #scrolling of head must affect body and vice versa
    head = $("#" + obj.form_id).find(".centerContainer .scrollTargetContainter").first()
    body = $("#" + obj.form_id).find(".centerContainer .detachedTableContainer").first()

    EditableTableAligner.side_scroll(head, body)
    EditableTableAligner.side_scroll(body, head)


  @side_scroll: (source, target) ->
    $(source).scroll ->
      target.scrollLeft(parseInt(source.scrollLeft()))



  @paired_up_down_scrolling: (obj) ->
    #scrolling of head must affect body and vice versa
    center_body = $("#" + obj.form_id).find(".centerContainer .detachedTableContainer").first()
    fixed_left_column_body = $("#" + obj.form_id).find(".fixedLeftColumn .detachedTableContainer").first()


    EditableTableAligner.scroll(center_body, fixed_left_column_body)
    EditableTableAligner.scroll(fixed_left_column_body, center_body)

  @scroll: (source, target) ->
    $(source).scroll ->
      target.scrollTop(parseInt(source.scrollTop()))


  @align_static_left_columns: (obj, xhr) ->
    orig_head = $("#" + obj.form_id).find('.centerContainer .scrollTargetContainter')
    head  = $("#" + obj.form_id).find(".fixedLeftColumn .table_head thead")
    # first clear the head, but only if not by XHR, head is not sent by ajax

    
    if xhr? && !xhr
      head.html("")
      # then fill it with actual data
      orig_head.find("thead tr").each (index, element) =>
        EditableTableAligner.move_cell_to_static_column(element, head)

    # can delete orid headcols when I duplicated them, otherwise the height info is wrong
    #$(orig_head).find(".headcol").remove()


    orig_body =  $("#" + obj.form_id).find('.centerContainer .detachedTableContainer')
    body  = $("#" + obj.form_id).find(".fixedLeftColumn .table_body tbody")
    # first clear the body
    body.html("")
    # then fill it with actual data
    orig_body.find("tr").each (index, element) =>
      EditableTableAligner.move_cell_to_static_column(element, body)

  # can delete orid headcols when I duplicated them, otherwise the height info is wrong
  #$(orig_body).find(".headcol").remove()

  @align_heights: (obj) ->
    ##################### !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11
    ###################### omezim je na thead, tbody bude mit fixni vysku sloupcu, prepocinani s 500 radky, trva strasne dlouho
    #$("#" + obj.form_id).find('.fixedLeftColumn tr').each (index, element) =>
    $("#" + obj.form_id).find('.fixedLeftColumn thead tr').each (index, element) =>

      # loading paired tr of left column and right
      tr_left = $(element)

      # id of paired th and td elements
      height_align_id = tr_left.data("row-count-number")

      tr_center = $("#" + obj.form_id).find('.centerContainer tr[data-row-count-number="' + height_align_id + '"]').first()

      # carefull delete of height line by line, or scrolling will be lost
      # have to delete it from headers first, as it is not sent by ajax, othewwise it will increase with each ajax reload
      tr_left.css({
      'height': "",
      })
      tr_center.css({
      'height': "",
      })

      # determining max width
      td_left_height = tr_left.outerHeight()
      td_center_height = tr_center.outerHeight()

      if td_left_height > td_center_height
        max_height = td_left_height
      else
        max_height = td_center_height


      # setting max width
      tr_left.css({
      'height': max_height,
      })

      tr_center.css({
      'height': max_height,
      })

  @move_cell_to_static_column: (element, body) ->
    tr_element = $(element).clone()
    tr_element.html("")


    $(element).find('.headcol').each (i, e) =>
      orig_element = $(e)

      tr_element.append(orig_element)

    # remove it from old table
    #$(orig_element).remove()

    body.append(tr_element)


  @align_static_left_columns_after_row_update: (obj) ->
    orig_body =  $("#" + obj.form_id).find('.centerContainer .detachedTableContainer')

    # going trough all tr, and then filtering nlz by those who has head col, that means they were updated
    #orig_body.find("tr").each (index, element) =>
    # noooo going through only updated tr
    for row in EditableTableBuilder.obj.data
      do (row) ->
        element = $("#" + obj.form_id).find('.centerContainer tr[data-row-id="' + row.row_id + '"]')
        # finding destination row from orig row
        destination_row_id  = $(element).data("row-count-number")
        destination_row  = $("#" + obj.form_id).find('.fixedLeftColumn tr[data-row-count-number="' + destination_row_id + '"]')


        EditableTableAligner.move_cells_to_static_rows(element, destination_row)

  @move_cells_to_static_rows: (element, destination_row) ->
    if $(element).find('.headcol').length > 0
      # first clear the row before updating row
      destination_row.html("")

      $(element).find('.headcol').each (i, e) =>
        orig_element = $(e)

        destination_row.append(orig_element)

      # have copy colors of the center table to left column
      $(destination_row).attr("style", $(element).attr("style"))

  @register_align_table_size: ->
    $(window).resize ->
      EditableTableAligner.unset_table_size()
      EditableTableAligner.align_table_size()

  @unset_table_size: ->
    $(".tableContainer, .centerContainer .detachedTableContainer, .centerContainer .scrollTargetContainter, .fixedLeftColumn .detachedTableContainer,.fixedLeftColumn table").css({'width': "", 'height': ""})

  @align_table_size: ->

    #console.log $(window).width()
    #console.log $(window).height()
    #    console.log $(document).width()
    #    console.log $(document).height()
    scroller_size = 16
    upper_panel_size = 300
    width_border = 80


    left_column_width = $(".fixedLeftColumn table").width()
    center_width = $(window).width() - left_column_width - scroller_size - width_border
    table_height  = $(window).height() - upper_panel_size

    #console.log left_column_width
    #    console.log center_width


    $(".tableContainer").css({'width': (left_column_width + center_width + scroller_size + width_border/2)})

    $(".centerContainer .detachedTableContainer").css({'width': (center_width + scroller_size + width_border/4), 'height': (table_height + scroller_size)})
    $(".centerContainer .scrollTargetContainter").css({'width': (center_width + width_border/4) })

    $(".fixedLeftColumn .detachedTableContainer").css({'height': table_height})
    $(".fixedLeftColumn table").css({'width': left_column_width})


window.EditableTableAligner = EditableTableAligner





