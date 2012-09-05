function formatLinkForPaginationURL(form_id) {
    var matchedString;
    var page_number;
    //$("#" + paginate_wrapper).find("a").each(function() {
    $("." + form_id + "_pager").find("a").each(function () {
        var linkElement = $(this);
        var paginationURL = linkElement.attr("href");
        var matchedString = paginationURL.match(/(\?|\&)page=(\d+)/);
        var page_number = 0;
        if (matchedString) {
            page_number = matchedString[2];
        }

        linkElement.attr({
            "url":paginationURL,
            "href":"#",
            "class":"btn"
        });

        linkElement.click(function () {
            $("#" + form_id + "_page").val(page_number);
            $("#" + form_id).submit();
            return false;
        });
    });
}


function formatLinkForPagination(container_class) {
    var matchedString;
    var page_number;
    //$("#" + paginate_wrapper).find("a").each(function() {
    $("." + container_class).find("a").each(function () {
        var linkElement = $(this);
        var paginationURL = linkElement.attr("href");
        var matchedString = paginationURL.match(/(\?|\&)page=(\d+)/);
        var page_number = 0;
        if (matchedString) {
            page_number = matchedString[2];
        }

        linkElement.attr({
//            "url": paginationURL,
//            "href": "#"
            "data-remote":true
        });

        linkElement.bind('ajax:beforeSend', function (evt, xhr, settings) {
            ajax_beforeSend_std(evt, xhr, settings)
        });
        linkElement.bind('ajax:success', function (evt, data, status, xhr) {
                ajax_success_std(evt, data, status, xhr, ["list"]);
                set_anchors_to_alu_items();
                $('#spinner').hide();

            }
        );
        linkElement.bind('ajax:error', function (evt, xhr, status, error) {
            ajax_error_std(evt, xhr, status, error);
            $('#spinner').hide();
        });
//        linkElement.bind('ajax:complete', function() {  });
        //linkElement.bind('ajax:complete', function(){ alert("zblk"); ajax_complete_set_anchors_to_alu_items(); });
    })
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
    order_by_value = order_by_value.toLowerCase();
    dir = dir.toLowerCase();

    var order_by_id = '#' + form_id + '_order_by';
    var default_order_by_val = $('#' + form_id + '_default_order_by').val().toLowerCase();

    var order_by_array = $(order_by_id).val().toLowerCase().split(",");
    //console.log(order_by_value)
    //console.log(dir)
    //console.log(order_by_array);

    if (order_by_array.indexOf(order_by_value + " " + dir) >= 0) { // the value is already there, if I click on it again I want to cancel the sorting by this value
        //console.log("mazu");
        var index = order_by_array.indexOf(order_by_value + " " + dir);
        order_by_array.splice(index, 1);
        if (order_by_array.length <= 0) {
            // the ordering is empty I will fill it with default
            order_by_array.push(default_order_by_val);
        }
        //console.log(order_by_array);
    }
    else if ((dir == "desc" && order_by_array.indexOf(order_by_value + " asc") >= 0) || (dir == "asc" && order_by_array.indexOf(order_by_value + " desc") >= 0)) {
        // there is other variant of the column desc or asc, I will swith it to the other variant
        //console.log("menim dir");
        if (dir == "desc") {
            var index = order_by_array.indexOf(order_by_value + " asc");
            order_by_array[index] = order_by_value + " desc";
        }
        else {
            var index = order_by_array.indexOf(order_by_value + " desc");
            order_by_array[index] = order_by_value + " asc";
        }
        //console.log(order_by_array);
    }
    else { // i am not ordering by this value, I will append it to end
        //console.log("pridavam");
        order_by_array.push(order_by_value + " " + dir);
        //console.log(order_by_array);
    }

    $("#" + form_id + " .sort_button").each(function () {
        $(this).removeClass("active");
        $(this).addClass("inactive");  // give all disabled class
    });

    var new_order_by_val = "";
    $.each(order_by_array, function (i, item) {
        if (new_order_by_val != "") {
            new_order_by_val += ",";
        }
        //console.log(item);
        new_order_by_val += item;

        var order_by_button_id = "#" + item.replace(" ", "___").replace(".", "___");
        //console.log(order_by_button_id)
        $(order_by_button_id).removeClass("inactive");
        $(order_by_button_id).addClass("active");
    });
    //console.log(new_order_by_val);

    $(order_by_id).val(new_order_by_val);


    $('#' + form_id).submit();
    return false;

}


