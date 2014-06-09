//= require ./backbone_js/jquery.cookie.js
//= require ./backbone_js/jquery.hotkeys.js
//= require ./backbone_js/jquery.jstree.js
//= require ./backbone_js/ladas_jstree.js
//= require ./backbone_js/jquery.history.js
//= require ./backbone_js/ladas_initialize_history.js
//= require ./backbone_js/jquery-ui-timepicker-addon.js


//= require ./backbone_js/jquery.iframe-transport.js
//= require ./backbone_js/jquery.fileupload.js
//= require ./backbone_js/jquery.fileupload-ui.js

//= require ./backbone_js/tinymce/jscripts/tiny_mce/jquery.tinymce.min.js

//= require ./backbone_js/ladas_table_checkbox_pool.js.coffee

//= require ./backbone_js/ladas_translations.js
//= require ./backbone_js/ladas_translations.cs.js
//= require ./backbone_js/ladas_translations.sk.js

//= require_directory ./backbone_js



if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function (searchElement /*, fromIndex */ ) {
        "use strict";
        if (this == null) {
            throw new TypeError();
        }
        var t = Object(this);
        var len = t.length >>> 0;
        if (len === 0) {
            return -1;
        }
        var n = 0;
        if (arguments.length > 0) {
            n = Number(arguments[1]);
            if (n != n) { // shortcut for verifying if it's NaN
                n = 0;
            } else if (n != 0 && n != Infinity && n != -Infinity) {
                n = (n > 0 || -1) * Math.floor(Math.abs(n));
            }
        }
        if (n >= len) {
            return -1;
        }
        var k = n >= 0 ? n : Math.max(len - Math.abs(n), 0);
        for (; k < len; k++) {
            if (k in t && t[k] === searchElement) {
                return k;
            }
        }
        return -1;
    }
}
