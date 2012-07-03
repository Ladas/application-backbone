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
                if (data['status'] == "error") {
                    //alert(data['message'])
                    process_error_data(form, data);
                }
                else {
                    if (data['message']) {
                        alert(data['message']);
                    }
                    if (data['settings']) {
                        load_page(data['settings']);
                    }
                }

            })
            .bind('ajax:error', function (evt, xhr, status, error) {
                ladas_loading_hide();

                if (xhr.status == 301 || xhr.status == 303) {
                    var data = jQuery.parseJSON(xhr.responseText);
                    if (data['message']) {
                        alert(data['message']);
                    }
                    if (data['settings']) {
                        load_page(data['settings']);
                    }
                }
                else if (xhr.status == 401) {
                    alert("Nemáte oprávnění na tuto akci!");
                }
                else {
                    alert("Request failed: " + error);
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
    var table_name = data['table_name'];
    jQuery.each(data['errors'], function (i, val) {
        var id = table_name + "_" + i;
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

