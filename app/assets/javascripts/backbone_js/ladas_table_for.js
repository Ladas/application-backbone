function apply_modifiers_of_the_table(area) {
//    console.log("ua")
    area.find("a, span").each(function () {
        var a_obj = $(this);
        if (a_obj.data("tr_class")) {
//            console.log("jooo")
//            console.log(a_obj.data("tr_class"))
            a_obj.parents("tr").addClass(a_obj.data("tr_class"));
        }
        if (a_obj.data("td_class")) {
            //            console.log("jooo")
            //            console.log(a_obj.data("tr_class"))
            a_obj.parents("td").addClass(a_obj.data("td_class"));
        }
    })
}