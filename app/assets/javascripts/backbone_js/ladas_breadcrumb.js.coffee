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
  @mark_active_menu_items: (title_default, title_prefix, title_suffix) ->
    title_default = Breadcrumbs.load_title_default(title_default)
    title_prefix = Breadcrumbs.load_title_prefix(title_prefix)
    title_suffix = Breadcrumbs.load_title_suffix(title_suffix)


    $('a[data-breadcrumb-id],li[data-breadcrumb-id]').each (index, element) =>
      $(element).removeClass('active')

    $('.main_breadcrumb li').each (index, element) =>
      bc = $(element)
      href = bc.find('a')
      if href.length > 0
        text = href.html()
      else
        text = bc.html()

      text = text.replace(/\n/g, ' ').replace(/\r/g, ' ');


      Breadcrumbs.mark_menu_item(text)
      Breadcrumbs.change_document_title(title_prefix, title_suffix, text) if (index + 1) >= $('.main_breadcrumb li').length

    # default title if there is no breadcrumbs
    Breadcrumbs.change_document_title("","", title_default) if $('.main_breadcrumb li').lenght <= 0


  @mark_menu_item: (val) ->
    finding_string = "li[data-breadcrumb-id='" + val + "']"
    finding_string += ",a[data-breadcrumb-id='" + val + "']"
    #console.log $(finding_string)

    found = $(finding_string)
    found.addClass('active') if found

  @change_document_title: (title_prefix,suffix, val) ->
    $(document).attr('title', title_prefix + val + suffix);

  @load_title_default: (title_default) ->         
    title_default = "" if title_default==undefined
    title_default = $(document).data("title-default") if $(document).data("title-default")!=undefined
    $(document).data("title-default", title_default)
    return title_default
    
  @load_title_suffix : (title_suffix ) ->         
    title_suffix  = "" if title_suffix ==undefined
    title_suffix  = $(document).data("title-suffix ") if $(document).data("title-suffix ")!=undefined
    $(document).data("title-suffix ", title_suffix )
    return title_suffix 
  
  @load_title_prefix: (title_prefix) ->         
    title_prefix = "" if title_prefix==undefined
    title_prefix = $(document).data("title-prefix") if $(document).data("title-prefix")!=undefined
    $(document).data("title-prefix", title_prefix)
    return title_prefix
    
window.Breadcrumbs = Breadcrumbs