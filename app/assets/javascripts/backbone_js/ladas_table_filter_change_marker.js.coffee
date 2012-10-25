class FilterChangeMarker
  @mark_active_filters: (form_id) ->
    #console.log(form_id)
    $('#' + form_id + " .filtering_th input").each (index, element) =>
      # input boxes marking of active filter
      el = $(element)
      val = el.val()

      el.removeClass("table_filter_active")
      el.parents("th.filtering_th").removeClass("table_filter_active")
      if val? && val.length > 0
        #console.log(element)
        el.addClass("table_filter_active")
        el.parents("th.filtering_th").addClass("table_filter_active")


    $('#' + form_id + " .filtering_th select").each (index, element) =>
      # selectboxes marking active filter
      el = $(element)
      found = false
      el.find("option:selected").each (index, element) =>
        #console.log(element)
        found = true

      el.parents("th.filtering_th").removeClass("table_filter_active")
      if found
        el.parents("th.filtering_th").addClass("table_filter_active")



window.FilterChangeMarker = FilterChangeMarker





