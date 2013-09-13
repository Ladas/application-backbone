(function ($) {
    $.fn.LadasTinyMce = function (settings) {
        if (typeof(tinymce) != "undefined") {
            if (tinymce.activeEditor == null || tinymce.activeEditor.isHidden() != false) {
                tinymce.editors = []; // remove any existing references
            }
        }
        $(this).tinymce({

            // localization
            language: window.itl_gem_active_language, // change language here en,cs,sk

            // Location of TinyMCE script
            script_url: '/assets/backbone_js/tinymce/jscripts/tiny_mce/tinymce.min.js',

            width: "100%",

            // General options

            theme: "modern",
            //plugins:"pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,inlinepopups,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",
            plugins: "pagebreak,layer,table,save,hr,image,link,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking, code",


            // Example content CSS (should be your site CSS)
//                content_css:"css/content.css",

            // Drop lists for link/image/media/template dialogs
            //template_external_list_url: tinymce_datafile_url(settings, "Template"),
            link_list: tinymce_datafile_url(settings, "Link"),
            image_list: tinymce_datafile_url(settings, "Image"),
            media_external_list_url: tinymce_datafile_url(settings, "Media"),

            media_types: "flash=swf;shockwave=dcr;qt=mov,qt,mpg,mp3,mp4,mpeg;wmp=avi,wmv,wm,asf,asx,wmx,wvx;rmp=rm",

            // Replace values for the template plugin
            template_replace_values: {
                username: "Some User",
                staffid: "991234"
            }
        });


    }
})(jQuery);

function tinymce_datafile_url(settings, type) {
    if (typeof(settings) != "undefined") {
        if (settings['resource_type'] && settings['resource_id']) {
            var datafile_url = "/datafiles?datafile[owner_type]=" + settings['resource_type'] + "&datafile[owner_id]=" + settings['resource_id'] + "&type=" + type;
            if (typeof(settings['sub_type']) != "undefined") {
                datafile_url = datafile_url + "&datafile[sub_type]=" + settings['sub_type']
            }
        }
        else {
            var datafile_url = "";
        }
    }
    else {
        var datafile_url = "";
    }
    //        console.log("ua");
    //        console.log(datafile_url);
    return datafile_url;
}

