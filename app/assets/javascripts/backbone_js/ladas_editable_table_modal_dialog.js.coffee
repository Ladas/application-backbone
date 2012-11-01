class EditableTableModalDialog
  @init: (modal_id) ->
    # init will be called only once

    EditableTableModalDialog.modal_id = modal_id
    modal_id_jquery = '#' + modal_id

    # I want to focus the input in the modal, but I can do this onlz after it's shown
    $(modal_id_jquery).on('shown', ->
      EditableTableModalDialog.focus()
    )

    # on enter I want to submit form inside
    $(modal_id_jquery).on('keyup', (e) ->
      # We don't want this to act as a link so cancel the link action
      e.preventDefault()
      console.log(e.keyCode)

      # if enter pressed
      if e.keyCode == 13
        #Find form and submit it
        $(modal_id_jquery).find('form').submit();
    )


  @show: (cell_element, edit_cell_path) ->
    cell_id = $(cell_element).data("cell-identifier")

    url = "fill_the_url_in_controller"
    url = edit_cell_path if edit_cell_path?
    url += "?cell_id=" + cell_id

    # load the content of modal
    load_page({
    "content_id": "modal_cell_editing",
    'symlink_remote': true,
    'url': url,
    "no_tracking": true

    })

    #show the modal and then it will be loaded with data
    #$('#modal_cell_editing').modal('show')


    # asynchronosly put content of modal when it is prepared and show it
    $(document).bind('page_loader.loaded', EditableTableModalDialog.display)



  @hide: ->
    $('#modal_cell_editing').modal('hide')

  #############################################3
  ############## private #####################


  @display: ->
    $('#modal_cell_editing').modal('show')

    # unbing the event and the handler, it should remove only this one binded handler
    # todo check if this wont remove other binded handlers !!!!!!!!!!!!
    $(document).unbind('page_loader.loaded', EditableTableModalDialog.display)


  @focus: ->
    if ($('#modal_cell_editing').find("#this_will_be_focused_input_id").length > 0)
      $('#modal_cell_editing').find("#this_will_be_focused_input_id").focus()
      $('#modal_cell_editing').find("#this_will_be_focused_input_id").focus()

window.EditableTableModalDialog = EditableTableModalDialog





