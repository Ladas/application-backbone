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
    console.log(pool_string)
    console.log($('#' + form_id + '_checkbox_pool'))
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
      console.log(element)
      $(element).attr("checked", true)
      CheckboxPool.change(element)

  @uncheck_page: (form_id) ->
    $('#' + form_id + " .row_checkboxes").each (index, element) =>
      $(element).attr("checked", false)
      CheckboxPool.change(element)

  #######################################################
  #private
  #######################################################

  @add: (obj) ->
    return if CheckboxPool.include(obj)

    val = $(obj).val()
    pool = CheckboxPool.get_pool(obj)
    pool.push(val)

    new_pool_string = pool.join(",")
    console.log(new_pool_string)
    CheckboxPool.update_pool(obj, new_pool_string)

  @remove: (obj) ->
    return unless CheckboxPool.include(obj)

    pool = CheckboxPool.get_pool(obj)
    pool.splice(CheckboxPool.position(obj), 1)

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
    pool_string = $('#' + form_id + '_checkbox_pool').val()

    pool = pool_string.split(",")
    return pool

  @get_pool_by_form_id: (form_id) ->
    pool_string = $('#' + form_id + '_checkbox_pool').val()

    pool = pool_string.split(",")
  @update_number_of_checked: (form_id) ->
    $('#' + form_id + '_active_checkboxes_count').html(CheckboxPool.get_pool_by_form_id(form_id).length - 1)

window.CheckboxPool = CheckboxPool





