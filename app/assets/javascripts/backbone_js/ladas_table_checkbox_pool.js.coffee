class CheckboxPool
  @include_value: (form_id, val) ->
    return CheckboxPool.get_pool_by_form_id(form_id).indexOf(val + "") >= 0

  @change: (obj) ->
    if $(obj).attr('checked')#CheckboxPool.include(obj)
      CheckboxPool.add(obj)
    else
      CheckboxPool.remove(obj)


  @update_pool: (obj, pool_string) ->
    form = $(obj).parents("form")
    form_id = form.attr("id")

    $('#' + form_id + '_checkbox_pool').val(pool_string)
    CheckboxPool.update_number_of_checked(form_id)

  @update_pool_by_form_id: (form_id, pool_string) ->
    $('#' + form_id + '_checkbox_pool').val(pool_string)
    CheckboxPool.update_number_of_checked(form_id)

  @clear_by_form_id: (form_id) ->
    CheckboxPool.update_pool_by_form_id(form_id, "")
    $('#' + form_id + " .row_checkboxes").each (index, element) =>
      $(element).attr("checked", false)

  @check_page: (form_id) ->
    $('#' + form_id + " .row_checkboxes").each (index, element) =>
      $(element).attr("checked", true)
      CheckboxPool.change(element)

  @uncheck_page: (form_id) ->
    $('#' + form_id + " .row_checkboxes").each (index, element) =>
      $(element).attr("checked", false)
      CheckboxPool.change(element)

  @check_or_uncheck_page: (obj, form_id) ->
    if $(obj).attr('checked')
      CheckboxPool.check_page(form_id)
    else
      CheckboxPool.uncheck_page(form_id)


  @checkboxes_initialize: ->
      # some beahviour before initialize checkboxes
      # I am tracking if all checkboxes are checked, setting as true, will set as false if some is not set
    CheckboxPool.all_checkboxes_on_page_checked = true

  @checkboxes_not_all_checked: ->
    CheckboxPool.all_checkboxes_on_page_checked = false

  @checkboxes_finalize: ->
    if CheckboxPool.all_checkboxes_on_page_checked
      $('#checkbox_all_checked_unchecked').attr('checked', 'checked')
    else
      $('#checkbox_all_checked_unchecked').removeAttr('checked')


  #######################################################
  #private
  #######################################################

  @add: (obj) ->
    return if CheckboxPool.include(obj)

    val = $(obj).val()
    pool = CheckboxPool.get_pool(obj)
    if pool.length <= 0
      pool = Array(val)
    else
      pool.push(val)

    new_pool_string = pool.join(",")

    CheckboxPool.update_pool(obj, new_pool_string)

  @remove: (obj) ->
    return unless CheckboxPool.include(obj)

    pool = CheckboxPool.get_pool(obj)
    pool.splice(CheckboxPool.position(obj), 1)

    if pool.length <= 0
      new_pool_string = ""
    else
      new_pool_string = pool.join(",")

    CheckboxPool.update_pool(obj, new_pool_string)


  @position: (obj) ->
    checkbox = $(obj)
    return CheckboxPool.get_pool(obj).indexOf(checkbox.val())

  @include: (obj) ->
    checkbox = $(obj)
    return CheckboxPool.get_pool(obj).indexOf(checkbox.val()) >= 0

  @get_pool: (obj) ->
    form = $(obj).parents("form")
    form_id = form.attr("id")

    return CheckboxPool.get_pool_by_form_id(form_id)

  @get_pool_by_form_id: (form_id) ->
    pool_string = $('#' + form_id + '_checkbox_pool').val()
    if pool_string.length <= 0
      pool = Array()
    else
      pool = pool_string.split(",")

    return pool

  @update_number_of_checked: (form_id) ->
    $('#' + form_id + '_active_checkboxes_count').html(CheckboxPool.get_pool_by_form_id(form_id).length)

window.CheckboxPool = CheckboxPool





