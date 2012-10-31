class EditableTableAligner
  @align_table: (obj, xhr) ->
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


  #########################
  ### private methods #########
  ##############################

  @align_widths: (obj) ->
    # going trough headers th
    $("#" + obj.form_id).find('th[data-width-align-id]').each (index, element) =>

      # loading paired td and th
      th = $(element)
      # have to delete it from header as it is not send by ajax, otherwise the width would increase
      th.css({
      'min-width': "",
      'max-width': ""
      })


      # id of paired th and td elements
      width_align_id = th.data("width-align-id")

      td = $("#" + obj.form_id).find('td[data-width-align-id="' + width_align_id + '"]').first()


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
    head.html("") if !xhr?
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
    $("#" + obj.form_id).find('.fixedLeftColumn tr').each (index, element) =>

      # loading paired tr of left column and right
      tr_left = $(element)

      # id of paired th and td elements
      height_align_id = tr_left.data("row-count-number")

      tr_center = $("#" + obj.form_id).find('.centerContainer tr[data-row-count-number="' + height_align_id + '"]').first()

      # have to delete it from headers first, as it is not sent by ajax, othewwise it will increase with each ajax reload
      tr_left.find('th').css({
      'height': "",
      })
      tr_center.find('th').css({
      'height': "",
      })

      # determining max width
      td_left_height = tr_left.find('td, th').first().outerHeight()
      td_center_height = tr_center.find('td, th').first().outerHeight()

      if td_left_height > td_center_height
        max_height = td_left_height
      else
        max_height = td_center_height

      # setting max width
      tr_left.find('td, th').css({
      'height': max_height,
      })

      tr_center.find('td, th').css({
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


window.EditableTableAligner = EditableTableAligner





