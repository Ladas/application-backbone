class Alert
  @clear:(content_id) ->
    if content_id? && content_id.length > 0
      $(content_id + " .alert").hide();
    else
      $(".alert").hide();

  @show:(content_id, status) ->
    if Alert.html().length > 0
      #showing alert
      $(content_id).prepend(Alert.html(status));
      #make alert close button working by Twitter Bootstrap
      $(".alert").alert();

      # it's like flash so I will show it only one time
      Alert.set_message("")
      Alert.set_message_header("")


  @html:(status) ->
    return "" if (!Alert.message_header? || Alert.message_header.length <= 0) && (!Alert.message? || Alert.message.length <= 0)

    Alert.status = "" if !Alert.status?
    switch Alert.status
      when "ok","","success"
        return Alert.success();
      when "info"
        return Alert.info();
      when "error"
        return Alert.error();
      when "warning"
        return Alert.warning();
      else
        return Alert.success();

  @info:() ->
    return '<div class="alert alert-info">' + Alert.message_body();
  @success:() ->
    return '<div class="alert alert-success">' + Alert.message_body();
  @error:() ->
    return '<div class="alert alert-error">' + Alert.message_body();
  @warning:() ->
    return '<div class="alert alert-block">' + Alert.message_body();

  @message_body: () ->
    mes_html = '<a class="close" data-dismiss="alert" href="#">×</a>'
    mes_html += '<h4 class="alert-heading">' + Alert.message_header + '</h4>' if Alert.message_header? && Alert.message_header.length > 0
    mes_html += Alert.message if Alert.message? && Alert.message.length > 0
    mes_html += '</div>'
    return mes_html


  @set_message:(val) ->
    Alert.message = val
  @set_message_header:(val) ->
    Alert.message_header = val
  @set_status:(val) ->
    Alert.status = val




window.Alert = Alert