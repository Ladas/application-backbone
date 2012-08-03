function load_page(settings, caller_object) {
    var url = "", content_id;
    url = build_url(settings);

    if (settings['content_id']) {
        content_id = "#" + settings['content_id'];
    }
    else {
        content_id = "#main-content";
    }
    var data = {};
    if (settings['data']) {
        data = settings['data'];
    }
    if (settings['method']) {
        data["_method"] = settings['method'];
    }

    if (build_type(settings) == "GET") {
        var e = window.event;
        if (e) {
            if (e.button == 1) {
                //middle button clicked, opening in new page if it is get url, otherwise do nothing
                if (build_type(settings) == "GET") {
                    window.open(url);
                    return false;
                }
                else {
                    return false
                }
            }
        }
    }


    if (settings['symlink_remote']) {

        //historyBool is global var that is set in ladas_initialize_history.js
        if (historyBool) {
            if ((build_type(settings) == "GET") && !settings["no_tracking"]) { // saving only GET requests to history of browsing
                var history_data = {state:window.location.pathname, rand:Math.random()};
                //            window.history.pushState(data, "window.location.pathname", url);
                //            //            window.history.replaceState(data, url, url);
                historyBool = false;
                // zajimave, tohle z prikladu kde tam perou primo loading funkci ToDo popremyslim o tom
                //var historySer = { ajaxRunFunction: historyFunName + "(" + historyFunParams + ")"};

                History.pushState(history_data, "", url);
            }
        }

        ladas_loading_show();
        $.ajax({
            url:url,
            type:build_type(settings),
            dataType:"html",
            data:data,
            success:function (data, textStatus, jqXHR) {
                if (jqXHR.status == 202) {
                    //alert(jqXHR.status);
                    var data = jQuery.parseJSON(jqXHR.responseText);

                    data['message'] ? Alert.set_message(data['message']) : Alert.set_message("");
                    data['message_header'] ? Alert.set_message_header(data['message_header']) : Alert.set_message_header("");
                    data['status'] ? Alert.set_status(data['status']) : Alert.set_status("");
                    //alert(data['message']);


                    if (data['settings']) {
                        load_page(data['settings']);
                    }
                    else if (settings['origin'] == "table" && build_type(settings) == "POST") {
                        // if origin of request is table, and it was not get, I will submit the parent form, so table can reload
                        $(caller_object).parents("form").submit();
                    }
                }
                else {
                    $(content_id).html(data);
                    $(content_id).find("textarea.tinymce").LadasTinyMce();
                    //console.log($(content_id).find("textarea.datafile_tinymce"));
                    // Todo nefunguje korektne kdyz nactu tinymce datafali i v sablone i tady, tedy zatim muzuz zobrazovat pouze spolu
                    //$(content_id).find("textarea.datafile_tinymce").LadasTinyMce(settings);
                    //console.log(data)
                    Breadcrumbs.mark_active_menu_items();
                    Alert.show(content_id);
                }

                ladas_loading_hide();
            },
            error:function (jqXHR, textStatus, errorThrown) {
                ladas_loading_hide();

                if (jqXHR.status == 301 || jqXHR.status == 303) {
                    // v ie nefunguje, pouzivam misto toho status 202
                    var data = jQuery.parseJSON(jqXHR.responseText);
                    if (data['message']) {
                        alert(data['message']);
                    }
                    if (data['settings']) {
                        load_page(data['settings']);
                    }
                    else if (settings['origin'] == "table" && build_type(settings) == "POST") {
                        // if origin of request is table, and it was not get, I will submit the parent form, so table can reload
                        $(caller_object).parents("form").submit();
                    }
                }
                else if (jqXHR.status == 401) {
                    Alert.clear(content_id);
                    Alert.set_message_header("Přístup nepovolen.");
                    Alert.set_message("Nemáte dostatečná oprávnění na tuto akci!");
                    Alert.set_status("error");
                    Alert.show(content_id);
                }
                else {
                    //alert("Request failed: " + textStatus + " status: " + jqXHR.status + " response" + jqXHR);
                    Alert.clear(content_id);
                    Alert.set_message_header("Server error.");
                    Alert.set_message("There has been server error, please wait for the fix of the problem.");
                    Alert.set_status("error");
                    Alert.show(content_id);
                }
            }
        });


        /*
         var request = $.ajax({
         url:url,
         type:build_type(settings),
         dataType:"html",
         data:data
         });

         request.done(function (msg) {
         $(content_id).html(msg);
         $(content_id).find("textarea.tinymce").LadasTinyMce();
         //console.log($(content_id).find("textarea.datafile_tinymce"));
         // Todo nefunguje korektne kdyz nactu tinymce datafali i v sablone i tady, tedy zatim muzuz zobrazovat pouze spolu
         //$(content_id).find("textarea.datafile_tinymce").LadasTinyMce(settings);
         ladas_loading_hide();
         });

         request.fail(function (jqXHR, textStatus) {
         ladas_loading_hide();

         if (jqXHR.status == 301 || jqXHR.status == 303) {
         var data = jQuery.parseJSON(jqXHR.responseText);
         if (data['message']) {
         alert(data['message']);
         }
         if (data['settings']) {
         load_page(data['settings']);
         }
         // if origin of request is table, and it was not get, I will submit the parent form, so table can reload
         if (settings['origin'] == "table" && build_type(settings) == "POST") {



         $(caller_object).parents("form").submit();
         }
         }
         else if (jqXHR.status == 401) {
         alert("Nemáte oprávnění na tuto akci!");
         }
         else {
         alert("Request failed: " + textStatus + " status: " + jqXHR.status + " response" + jqXHR);

         }

         //console.log(jqXHR);
         //console.log("Request failed: " + textStatus);
         });    */
    }
    else {
        window.location = url;
    }
}


function build_url(settings) {
    // make sure this is the same as convert_settings_to_url in ViewMixins::Link

    var url = "";
    if (settings['url']) {
        url += settings['url'];
    }
    else {
        if (settings['symlink_outer_controller']) {
            url += "/" + settings['symlink_outer_controller'];
        }
        if (settings['symlink_outer_id']) {
            url += "/" + settings['symlink_outer_id'];
        }
        if (settings['symlink_controller']) {
            url += "/" + settings['symlink_controller'];
        }
        if (settings['symlink_id']) {
            url += "/" + settings['symlink_id'];
        }
        if (settings['symlink_action']) {
            url += "/" + settings['symlink_action'];
        }

        if (settings['symlink_params']) {
            url += settings['params'];
        }
    }

    return url;
}

/**
 * TAtot medota vraci URL pro GEt # pro POST ze settings
 * @param settings - bere se string z settings['method']
 * @return {String}
 */
function build_get_url(settings) {
    return (build_type(settings) == "GET") ? build_url(settings) : "#";
}

/**
 * Redukuje metody get/post/put/delete na get/post
 *
 * @param settings - bere se string z settings['method']
 * @return {String}
 */
function build_type(settings) {
    if (settings['method'] == "put" || settings['method'] == "delete" || settings['method'] == "post") {
        return "POST";
    }
    else {
        return "GET";
    }
}


function parse_link_and_load_page(element) {
    var settings = {};
    settings['url'] = element.attr("href");
    settings['symlink_remote'] = true;
    if (typeof(element.data("content_id")) != 'undefined') {
        settings['content_id'] = element.data("content_id");
    }
    load_page(settings);
}

function parse_link_and_post(element) {
    var settings = {};
    settings['url'] = element.attr("href");
    settings['symlink_remote'] = true;
    settings['data'] = element.data("post");
    settings['method'] = "post";
    if (typeof(element.data("content_id")) != 'undefined') {
        settings['content_id'] = element.data("content_id");
    }

    load_page(settings);
}


function edit_tree_node(settings) {
    //console.log(settings);
    var edit_settings = {symlink_controller:"tree", symlink_action:"edit", symlink_id:settings['id'], symlink_remote:true};
    //console.log(edit_settings);
    load_page(edit_settings);
}


function ladas_loading_show() {
    $("#spinner").center().show();
}
function ladas_loading_hide() {
    $("#spinner").hide();
}

(function ($) {
    $.fn.center = function () {
        this.css("position", "absolute");
        this.css("top", ($(window).height() - this.height()) / 2 + $(window).scrollTop() + "px");
        this.css("left", ($(window).width() - this.width()) / 2 + $(window).scrollLeft() + "px");
        return this;
    }
})(jQuery);