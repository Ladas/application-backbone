class JstreeMethods
  @check_tree: (selector) ->
    $(selector + " li").each (index, element) =>
      if ($(element).hasClass("active"))
        $(element).children("ul").each (index, element) =>
          JstreeMethods.show($(element))
      else
        $(element).children("ul").each (index, element) =>
          JstreeMethods.hide($(element))
  @toggle_level: (element) ->
    if $(element).parent("li").hasClass("jstree-open")
      JstreeMethods.hide($(element).next("ul"))
    else
      JstreeMethods.show($(element).next("ul"))

  ############### private ##########3

  @show: (element) ->
    element.show("fast")
    element.parent("li").removeClass("jstree-closed")
    element.parent("li").addClass("jstree-open")
    element.parent("li").children("button").html('<i class="icon-minus-sign"></i>')

  @hide: (element) ->
    element.hide("fast")
    element.parent("li").removeClass("jstree-open")
    element.parent("li").addClass("jstree-closed")
    element.parent("li").children("button").html('<i class="icon-plus-sign"></i>')


window.JstreeMethods = JstreeMethods