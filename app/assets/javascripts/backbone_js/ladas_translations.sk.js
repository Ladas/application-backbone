



itl_gem_translations['sk'] = {
    total_sum:'Celkom: ',
    total_sum_on_page:'Celkom na stránke ',
    access_denied: "Prístup nepovolený.",
    access_denied_no_rights_for_this_action: "Nemáte dostatočné oprávnenia na túto akciu!",
    server_error: "Server error.",
    server_error_message: "There has been server error, please wait for the fix of the problem."
};


/* JQuery UI date picker plugin. */
jQuery(function ($) {
    $.datepicker.regional['sk'] = {
        closeText:'Zavrieť',
        prevText:'&#x3c;Predchodzí',
        nextText:'Nasledujúci&#x3e;',
        currentText:'Teraz',
        monthNames:['január', 'február', 'marec', 'apríl', 'máj', 'jún',
            'júl', 'august', 'september', 'október', 'november', 'december'],
        monthNamesShort:['jan', 'feb', 'mar', 'apr', 'máj', 'jún',
            'júl', 'aug', 'sep', 'okt', 'nov', 'dec'],
        dayNames:['neďeľa', 'pondelok', 'utorok', 'streda', 'štvrtok', 'piatok', 'sobota'],
        dayNamesShort:['ne', 'po', 'ut', 'st', 'št', 'pi', 'so'],
        dayNamesMin:['ne', 'po', 'út', 'st', 'št', 'pi', 'so'],
        weekHeader:'Týž',
        dateFormat:'dd.mm.yy',
        firstDay:1,
        isRTL:false,
        showMonthAfterYear:false,
        yearSuffix:''};
    $.datepicker.setDefaults($.datepicker.regional[window.itl_gem_active_language]);
});

/* DAteTime picker addon */
(function ($) {
    $.timepicker.regional['sk'] = {
        timeOnlyTitle:'Vyberte čas',
        timeText:'Čas',
        hourText:'Hodiny',
        minuteText:'Minúty',
        secondText:'Sekundy',
        millisecText:'Milisekundy',
        timezoneText:'Časové pásmo',
        currentText:'Teraz',
        closeText:'Zavrieť',
        timeFormat:'h:m',
        amNames:['dop.', 'AM', 'A'],
        pmNames:['pop.', 'PM', 'P'],
        ampm:false
    };
   $.timepicker.setDefaults($.timepicker.regional[window.itl_gem_active_language]);
})(jQuery);