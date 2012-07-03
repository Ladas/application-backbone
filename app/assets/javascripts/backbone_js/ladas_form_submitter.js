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
        clearTimeout(submit_timestamp[watched_form_id]);
        submit_timestamp[watched_form_id] = setTimeout(function() { form_submit(watched_form_id) }, 1000);

    }
    function form_submit(watched_form_id) {
//        console.log("submiting")
//        console.log(watched_form_id);
        $("#"+watched_form_id).submit();
    }
//
//})(jQuery);