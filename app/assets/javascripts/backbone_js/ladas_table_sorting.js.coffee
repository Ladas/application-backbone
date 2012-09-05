class TableSorting
  @change_sorting: (form_id, order_by_value, dir, obj) ->
    order_by_value = order_by_value.toLowerCase()
    dir = dir.toLowerCase()

    order_by_id = '#' + form_id + '_order_by'
    default_order_by_val = $('#' + form_id + '_default_order_by').val().toLowerCase()

    order_by_array = $(order_by_id).val().toLowerCase().split(",")
    #console.log(order_by_value)
    #console.log(dir)
    #console.log(order_by_array)

    if (order_by_array.indexOf(order_by_value + " " + dir) >= 0)
      # the value is already there, if I click on it again I want to cancel the sorting by element value
      #console.log("mazu")
      index = order_by_array.indexOf(order_by_value + " " + dir)
      order_by_array.splice(index, 1)
      if (order_by_array.length <= 0)
        # the ordering is empty I will fill it with default
        order_by_array.push(default_order_by_val)

      #console.log(order_by_array)

    else if ((dir == "desc" && order_by_array.indexOf(order_by_value + " asc") >= 0) || (dir == "asc" && order_by_array.indexOf(order_by_value + " desc") >= 0))
      # there is other variant of the column desc or asc, I will swith it to the other variant
      #console.log("menim dir")
      if (dir == "desc")
        index = order_by_array.indexOf(order_by_value + " asc")
        order_by_array[index] = order_by_value + " desc"

      else
        index = order_by_array.indexOf(order_by_value + " desc")
        order_by_array[index] = order_by_value + " asc"

      #console.log(order_by_array)

    else  # i am not ordering by element value, I will append it to end
      #console.log("pridavam")
      order_by_array.push(order_by_value + " " + dir)


    $("#" + form_id + " .sort_button").each (index, element) =>
      $(element).removeClass("btn-success")
      #$(element).addClass("inactive")  # give all disabled class
    

    new_order_by_val = ""
    for index,element of order_by_array
      if (new_order_by_val != "")
        new_order_by_val += ","
  
      #console.log(element)
      new_order_by_val += element
  
      order_by_button_id = "#" + element.replace(" ", "___").replace(".", "___")
      #console.log(order_by_button_id)
      #$(order_by_button_id).removeClass("inactive")
      $(order_by_button_id).addClass("btn-success")
      
    #console.log(new_order_by_val)

    $(order_by_id).val(new_order_by_val)


    #$('#' + form_id).submit()

    form_submit_watcher(form_id)


  @force_change_sorting: (form_id, order_by_value, dir, obj) ->
    order_by_value = order_by_value.toLowerCase()
    dir = dir.toLowerCase()
    order_by_id = '#' + form_id + '_order_by'

    $("#" + form_id + " .sort_button").each (index, element) =>
      $(element).removeClass("btn-success")
      #$(element).addClass("inactive")  # give all disabled class

    element = order_by_value + " " + dir
    order_by_button_id = "#" + element.replace(" ", "___").replace(".", "___")
    #$(order_by_button_id).removeClass("inactive")
    $(order_by_button_id).addClass("btn-success")

    $(order_by_id).val(element)

    #$('#' + form_id).submit()
    form_submit_watcher(form_id)



window.TableSorting = TableSorting





