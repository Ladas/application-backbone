function formatLinkForPaginationURL(form_id) {
    var matchedString;
    var page_number;
    //$("#" + paginate_wrapper).find("a").each(function() {
    $("."+ form_id +"_pager").find("a").each(function() {
        var linkElement = $(this);
        var paginationURL = linkElement.attr("href");
        var matchedString = paginationURL.match(/(\?|\&)page=(\d+)/);
        var page_number = 0;
        if (matchedString) {
            page_number = matchedString[2];
        }

        linkElement.attr({
            "url": paginationURL,
            "href": "#"
        });

        linkElement.click(function() {
            $("#" + form_id + "_page").val(page_number);
            $("#" + form_id).submit();
            return false;
        });
    });
}

//function filter_sort(form_id, order_by_value) {
//    var default_direction = 'DESC';
//    var order_by_id = '#' + form_id + '_order_by';
//    var order_by_direction_id = '#' + form_id + '_order_by_direction';
//    var old_order_by_value = $(order_by_id).val();
//    var old_order_by_direction_value = $(order_by_direction_id).val();
//
//    $(order_by_id).val(order_by_value);
//    if ($(order_by_direction_id).val() == '') {
//        $(order_by_direction_id).val(default_direction);
//    }
//    else {
//        if (order_by_value != old_order_by_value) {// pokud radim podle neceho noveho vzdy dam default DESC direction
//            $(order_by_direction_id).val(default_direction);
//        }
//        else {// jinak radim podle stejneho a budu stridat pri kazdem kliku ASC a DESC
//            if ($(order_by_direction_id).val() == 'ASC') {
//                $(order_by_direction_id).val('DESC');
//            }
//            else if ($(order_by_direction_id).val() == 'DESC') {
//                $(order_by_direction_id).val('ASC');
//            }
//        }
//    }
//
//    $('#' + form_id).submit();
//    return false;
//
//}

function filter_sort(form_id, order_by_value, dir, obj) {
    var order_by_id = '#' + form_id + '_order_by';
    var order_by_direction_id = '#' + form_id + '_order_by_direction';

    $(order_by_id).val(order_by_value);
    $(order_by_direction_id).val(dir);

    $("#" + form_id + " .sort_button").each(function() {
        $(this).removeClass("active");
        $(this).addClass("inactive");  // give all disabled class
    });
    $(obj).removeClass("inactive");  // remove disabled from this one
    $(obj).addClass("active");

    $('#' + form_id).submit();
    return false;

}


