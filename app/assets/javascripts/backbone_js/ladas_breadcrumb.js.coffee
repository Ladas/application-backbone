#hashCode = (val) ->
#  hash = 0
#  return hash if (val.length == 0)
#
#  for i in [0..val.length]
#    do (i) ->
#      char = this.charCodeAt(i)
#      hash = ((hash<<5)-hash) + char
#      hash = hash & hash # Convert to 32bit integer
#
#  return hash;
#
#
#
#breadcrumb_id = (val) ->
#  hasCode(val)

class Breadcrumbs
  @mark_active_menu_items: ->
    $('a[data-breadcrumb-id]').each (index, element) =>
      $(element).parent('li').removeClass('active')

    $('.breadcrumb li').each (index, element) =>
      bc = $(element)
      href = bc.find('a')
      if href.length > 0
        Breadcrumbs.mark_menu_item(href.html())
      else
        Breadcrumbs.mark_menu_item(bc.html())

  @mark_menu_item: (val) ->
    finding_string = "li[data-breadcrumb-id='" + val + "']"
    finding_string += ",a[data-breadcrumb-id='" + val + "']"
    #console.log $(finding_string)
    found = $(finding_string)
    found.addClass('active') if found

window.Breadcrumbs = Breadcrumbs