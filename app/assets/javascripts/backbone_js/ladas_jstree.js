(function($) {
    $.fn.LadasTree = function(settings) {
        function LadasJsTree(object, settings) {
           var self = this;
           self.settings = settings;


           function contextmenu_create( obj, type, ee)
           {
               type = typeof type !== 'undefined' ? type : "default";

//               console.log(ee);
//               console.log(obj);
//               console.log($("#demo"));
//               console.log(object);
               object.jstree("create", null, "last", { "attr":{ "rel": type } });
           }

           $(function () {
               object
                       .bind("before.jstree", function (e, data) {
                           $("#alog").append(data.func + "<br />");
                       })
                       .jstree({
                            "themes" : {
                       			"theme" : "default",
                                "url" : "/assets/backbone_css/themes/default/style.css",
                       			"dots" : true,
                       			"icons" : true
                       		},
                           // List of active plugins
                           "plugins":[
                               "themes", "json_data", "ui", "crrm", "cookies", "dnd", "search", "types", "hotkeys", "contextmenu"
                               //"themes", "json_data", "ui", "crrm", "dnd", "search", "types", "hotkeys", "contextmenu"
                           ],
                           contextmenu: {
                             select_node: true,
                             show_at_node: false,
                             items: {
                               "create" : {
                                   label : self.settings['lang']['add_sub_page'] ,
                                   action : function (obj) {
                                      this.create(obj, "last", {data: {title : self.settings['lang']['new_sub_page']}, "attr" : {"rel" : "default"}});
                                   }
                               },
                                rename: {label: self.settings['lang']['rename']},
                                remove: { label: self.settings['lang']["remove"]},
                                ccp :
                                {
                                     label: self.settings['lang']['edit'],
                                     submenu : {
                                         cut : {label : self.settings['lang']['cut']},
                                         copy : false,//{label : self.settings['lang']['copy']},
                                         paste : {label : self.settings['lang']['paste']}
                                     }
                                }
                             }
                           },

                           // I usually configure the plugin that handles the data first
                           // This example uses JSON as it is most common
                           "json_data":{
                               // This tree is ajax enabled - as this is most common, and maybe a bit more complex
                               // All the options are almost the same as jQuery's AJAX (read the docs)
                               "ajax":{
                                   // the URL to fetch the data
                                   "url":self.settings['get_children_url'],
                                   // the `data` function is executed in the instance's scope
                                   // the parameter is the node being loaded
                                   // (may be -1, 0, or undefined when loading the root nodes)
                                   "data":function (n) {
                                       var root_id = typeof(self.settings['root_id']) == 'undefined' ? 0 : self.settings['root_id'];
                                       // the result is fed to the AJAX request `data` option
                                        return {
                                           "operation":"get_children",
                                           "id":n.attr ? n.attr("id").replace("node_", "") : root_id
                                        };
                                   },
//                                   "success" : function (data) {
//                                       console.log(object);
//                                       console.log(object.find("li a"));
//                                       object.find("a").dblclick(function (){
//                                           var selected_node = $(this).parent('li');
//                                           console.log(selected_node);
//                                           load_page(selected_node.data('settings'))
//                                       });
                                   "complete" : function (data) {
//                                       console.log(object);
//                                       console.log(object.find("li a"));
//
                                       object.find("li a").each(function () {


                                           $(this).attr("href", build_get_url($(this).parent().data('settings')));
                                       })
                                   }
                               }
                           },
                           // Configuring the search plugin
                           "search":{
                               // As this has been a common question - async search
                               // Same as above - the `ajax` config option is actually jQuery's AJAX object
                               "ajax":{
                                   "url":self.settings['search_node_url'],
                                   // You get the search string as a parameter
                                   "data":function (str) {
                                       return {
                                           "operation":"search",
                                           "search_str":str
                                       };
                                   }
                               }
                           },
                           // Using types - most of the time this is an overkill
                           // read the docs carefully to decide whether you need types
                           "types":{
                               // I set both options to -2, as I do not need depth and children count checking
                               // Those two checks may slow jstree a lot, so use only when needed
                               "max_depth":-2,
                               "max_children":-2,
                               // I want only `drive` nodes to be root nodes
                               // This will prevent moving or creating any other type as a root node
                               "valid_children":[ "default" ],
                               "types":{
                                   // The default type
                                   "default":{
                                       // I want this type to have no children (so only leaf nodes)
                                       // In my case - those are files
                                       "valid_children":["default"],
                                       // If we specify an icon for the default type it WILL OVERRIDE the theme icons
                                       "icon":{
                                           "image":"/assets/backbone_images/icons/file.png"
                                       }
                                   },
                                   // The `folder` type
                                   "folder":{
                                       // can have files and other folders inside of it, but NOT `drive` nodes
                                       "valid_children":[ "default", "folder" ],
                                       "icon":{
                                           "image":"/assets/backbone_images/icons/folder.png"
                                       }
                                   },
                                   // The `drive` nodes
                                   "drive":{
                                       // can have files and folders inside, but NOT other `drive` nodes
                                       "valid_children":[ "default", "folder" ],
                                       "icon":{
                                           "image":"/assets/backbone_images/icons/root.png"
                                       },
                                       // those prevent the functions with the same name to be used on `drive` nodes
                                       // internally the `before` event is used
                                       "start_drag":false,
                                       "move_node":false,
                                       "delete_node":false,
                                       "remove":false
                                   }
                               }
                           },
                           // UI & core - the nodes to initially select and open will be overwritten by the cookie plugin
                           "ui":{
                              // this makes the node with ID node_4 selected onload
                               "select_limit": 1
                           }
                           // the UI plugin - it handles selecting/deselecting/hovering nodes
//                           "ui":{
//                               // this makes the node with ID node_4 selected onload
//                               "initially_select":[ "node_4" ]
//                           },
//                           // the core plugin - not many options here
//                           "core":{
//                               // just open those two nodes up
//                               // as this is an AJAX enabled tree, both will be downloaded from the server
//                               "initially_open":[ "node_2" , "node_3" ]
//                           }
                       })
                       .bind("create.jstree", function (e, data) {
                           $.post(
                                   self.settings['create_node_url'],
                                   {
                                       "operation":"create_node",
                                       "id": (data.rslt.parent == -1) ? 0 : data.rslt.parent.attr("id").replace("node_", ""),
                                       "position":data.rslt.position,
                                       "title":data.rslt.name,
                                       "type":data.rslt.obj.attr("rel")
                                   },
                                   function (r) {
                                       if (r.status) {
                                           var node = data.rslt.obj;
                                           node.attr("id", "node_" + r.id);
                                           node.attr("data-settings", r['data-settings']);
                                       }
                                       else {
                                           $.jstree.rollback(data.rlbk);
                                       }
                                   }
                           );
                       })
                       .bind("remove.jstree", function (e, data) {
                           data.rslt.obj.each(function () {
                               if (confirm(self.settings['lang']['do_you_want_to_delete_this_page']))
                               {
                                   $.ajax({
                                       async:false,
                                       type:'POST',
                                       url: self.settings['remove_node_url'],
                                       data:{
                                           "operation":"remove_node",
                                           "id":this.id.replace("node_", "")
                                       },
                                       success:function (r) {
                                           if (!r.status) {
                                               data.inst.refresh();
                                           }
                                       }
                                   });
                               }
                               else
                               {
                                   $.jstree.rollback(data.rlbk);
                                   //data.inst.refresh();
                               }
                           });
                       })
                       .bind("rename.jstree", function (e, data) {
                           $.post(
                                   self.settings['rename_node_url'],
                                   {
                                       "operation":"rename_node",
                                       "id":data.rslt.obj.attr("id").replace("node_", ""),
                                       "title":data.rslt.new_name
                                   },
                                   function (r) {
                                       if (!r.status) {
                                           $.jstree.rollback(data.rlbk);
                                       }
                                   }
                           );
                       })
                       .bind("move_node.jstree", function (e, data) {
                           data.rslt.o.each(function (i) {
                               $.ajax({
                                   async:false,
                                   type:'POST',
                                   url:self.settings['move_node_url'],
                                   data:{
                                       "operation":"move_node",
                                       "id":$(this).attr("id").replace("node_", ""),
                                       "ref":data.rslt.cr === -1 ? 0 : data.rslt.np.attr("id").replace("node_", ""),
                                       "position":data.rslt.cp + i,
                                       "title":data.rslt.name,
                                       "copy":data.rslt.cy ? 1 : 0
                                   },
                                   success:function (r) {
                                       if (!r.status) {
                                           $.jstree.rollback(data.rlbk);
                                       }
                                       else {
                                           $(data.rslt.oc).attr("id", "node_" + r.id);
                                           if (data.rslt.cy && $(data.rslt.oc).children("UL").length) {
                                               data.inst.refresh(data.inst._get_parent(data.rslt.oc));
                                           }
                                       }
//                                       $("#analyze").click();
                                   }
                               });
                           });
                       })
                       .bind("select_node.jstree", function (NODE, REF_NODE) {
//                          console.log(NODE);
//                          console.log(REF_NODE);
//                          var selected_node = $.jstree._focused().get_selected();
//                          console.log(selected_node);
//                          load_page(selected_node.data('settings'));

                       });
           });

           object.delegate("a","click", function(e) {
               var selected_node = $(this).parent('li');
               load_page(selected_node.data('settings'));
               return false;
           });

           // Code for the menu buttons
           if (self.settings['menu_selector'])
           {
               $(function () {
                   var menu_selector = self.settings['menu_selector'] + " input";
                   $(menu_selector).click(function () {
                       switch (this.id) {
                           case "add_default":
//                           case "add_folder":
                               object.jstree("create",-1,"last",{ "data" : {"title" : self.settings['lang']['new_page']}, "attr":{ "rel":this.id.toString().replace("add_", "") } });
                               //object.jstree("create",-1,false,"Nová stránka",false,true);
                               //object.jstree("create", null, "last", { "attr":{ "rel":this.id.toString().replace("add_", "") } });
                               break;
                           case "search":
                               object.jstree("search", document.getElementById("text").value);
                               break;
                           case "text":
                               break;
                           case "edit_tree_node":
                               edit_tree_node($('#intranet_left_menu').jstree('get_selected').data('settings'));
                               break;
                           default:
                               object.jstree(this.id);
                               break;
                       }
                   });
               });
            }
        }
        new LadasJsTree($(this), settings);
    }

})(jQuery);