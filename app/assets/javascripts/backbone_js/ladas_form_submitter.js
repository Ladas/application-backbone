//(function($) {
//    $.fn.AddOnChange = function(settings) {
//    function add_onchange(all_obj) {
//        $(all_obj).each(function () {
//            $(this).change(function () {
//                form_submit_watcher();
//            });
//        });
//    }
//
//
var submit_timestamp = {};
function form_submit_watcher(watched_form_id) {
//        console.log(watched_form_id);
//        console.log(submit_timestamp)
    //ladas_loading_show();
    //console.log("uaaa")
    FilterChangeMarker.mark_active_filters(watched_form_id);

    clearTimeout(submit_timestamp[watched_form_id]);
    submit_timestamp[watched_form_id] = setTimeout(function () {
        form_submit(watched_form_id)
    }, 1000);

}
function form_submit(watched_form_id) {
//        console.log("submiting")
//        console.log(watched_form_id);
    $("#" + watched_form_id).submit();
}
//
//})(jQuery);


function submit_spec(form_id, spec_attr_name, spec_attr_value, options) {
    // todo make all options by parameter
    var form = $("#" + form_id);
//    var form_original = $("#" + form_id);

    // create new form by cloning without events
//    var form = form_original.clone(false)
//
//    // disabling ajax
//    form.removeAttr("data-remote");
//
//    form.attr("target", "_blank");
//    form.attr("action", form_original.attr("action"));
//    form.attr("style", "display: none;");
//    form.attr("id", "");
//
//    // need to append it to browser html, otherwise it wont send in many browsers (with clone it works only with chrome)
//    form_original.after(form);

    //Create an input type dynamically.
    var element = document.createElement("input");

    //Assign different attributes to the element.
    element.setAttribute("type", "hidden");
    element.setAttribute("value", spec_attr_value);
    element.setAttribute("name", spec_attr_name);

    //Append the element in form
    form.append(element);

    form.submit();
//    form.remove();
}

function on_clear_table_fill_attrs(link, form_id) {

    var checkbox_pool = $("#" + form_id + "_checkbox_pool").val();    

    // attrs I want to send when clearing form
    var data = link.data("post");   

    data["clear"] = true;
    data["checkbox_pool"] = checkbox_pool;

    link.data("post", data);
}


