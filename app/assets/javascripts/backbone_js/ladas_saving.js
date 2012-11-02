function connect_callback_to_form(caller_id) {
    $(document).ready(function () {
        var form = $("#" + caller_id);
        var old_xhr = null
        form
            .bind("ajax:beforeSend", function (evt, xhr, settings) {


            if (old_xhr) {
                old_xhr.abort();
            }
            old_xhr = xhr;
            ladas_loading_show();
        })
            .bind("ajax:success", function (evt, data, status, xhr) {
                ladas_loading_hide();

                old_xhr = null;
                clear_error_data(form);
                Alert.clear("#" + caller_id);

                data['message'] ? Alert.set_message(data['message']) : Alert.set_message("");
                data['message_header'] ? Alert.set_message_header(data['message_header']) : Alert.set_message_header("");
                data['status'] ? Alert.set_status(data['status']) : Alert.set_status("");

                if (data['status'] == "error") {
                    //alert(data['message'])
                    process_error_data(form, data);
                    Alert.show("#" + caller_id);
                }
                else if (data['status'] == "modal-ok") {
                    Alert.show("#" + caller_id);
                    // todo bud sem dat zpoydeni nebo tu message yobrayit jinak, takhle se hned schova dialog a s nim i message 
                    EditableTableModalDialog.hide();
                    EditableTableBuilder.update_rows(data['updated_settings'])
                }
                else {
                    if (data['settings']) {
                        load_page(data['settings']);
                    }
                }

            })
            .bind('ajax:error', function (evt, xhr, status, error) {
                ladas_loading_hide();

                if (xhr.status == 301 || xhr.status == 303) {
                    var data = jQuery.parseJSON(xhr.responseText);

                    data['message'] ? Alert.set_message(data['message']) : Alert.set_message("");
                    data['message_header'] ? Alert.set_message_header(data['message_header']) : Alert.set_message_header("");
                    data['status'] ? Alert.set_status(data['status']) : Alert.set_status("");

                    if (data['settings']) {
                        load_page(data['settings']);
                    }
                }
                else if (xhr.status == 401) {
                    //alert("Nemáte oprávnění na tuto akci!");
                    Alert.clear("#" + caller_id);
                    Alert.set_message_header("Přístup nepovolen.");
                    Alert.set_message("Nemáte dostatečná oprávnění na tuto akci!");
                    Alert.set_status("error");
                    Alert.show("#" + caller_id);
                }
                else {
                    Alert.clear("#" + caller_id);
                    Alert.set_message_header("Server error.");
                    Alert.set_message("There has been server error, please wait for fix of the problem.");
                    Alert.set_status("error");
                    Alert.show("#" + caller_id);
                }

                //console.log(xhr);
                //console.log("Request failed: " + error);
                //console.log("Request failed: " + status);


            })
            .bind('ajax:complete', function () {
                // alert("complete!");
            });
    });
}

function process_error_data(form, data) {    
    var table_name = "";
    if (typeof data['table_name'] !== 'undefined') {
      table_name = data['table_name'];
    }

    jQuery.each(data['errors'], function (i, val) {
        if (table_name.length > 0) {
            var id = table_name + "_" + i;
        } else {
            var id = i;
        }


        var input = form.find("input#" + id + "," + "textarea#" + id);
        //console.log(input)
        var err_text = "";
        jQuery.each(val, function (error_i, error_val) {
            if (err_text != "") {
                err_text += ", ";
            }
            err_text += error_val;
        });

        var err_span = '<span class="help-inline">' + err_text + '</span>';
        input.after(err_span);
        input.parents(".control-group").addClass("error");

        if (i == "base") {
            alert(err_text);
        }
    });
}

function clear_error_data(form) {
    form.find(".control-group").removeClass("error");
    form.find("span.help-inline").remove();
}

