



itl_gem_translations['cs'] = {
    total_sum:'Celkem: ',
    total_sum_on_page:'Celkem na stránce ',
    access_denied: "Přístup nepovolen.",
    access_denied_no_rights_for_this_action: "Nemáte dostatečná oprávnění na tuto akci!",
    server_error: "Server error.",
    server_error_message: "There has been server error, please wait for the fix of the problem."
};


/* JQuery UI date picker plugin. */
jQuery(function ($) {
    $.datepicker.regional['cs'] = {
        closeText:'Zavřít',
        prevText:'&#x3c;Dříve',
        nextText:'Později&#x3e;',
        currentText:'Nyní',
        monthNames:['leden', 'únor', 'březen', 'duben', 'květen', 'červen',
            'červenec', 'srpen', 'září', 'říjen', 'listopad', 'prosinec'],
        monthNamesShort:['led', 'úno', 'bře', 'dub', 'kvě', 'čer',
            'čvc', 'srp', 'zář', 'říj', 'lis', 'pro'],
        dayNames:['neděle', 'pondělí', 'úterý', 'středa', 'čtvrtek', 'pátek', 'sobota'],
        dayNamesShort:['ne', 'po', 'út', 'st', 'čt', 'pá', 'so'],
        dayNamesMin:['ne', 'po', 'út', 'st', 'čt', 'pá', 'so'],
        weekHeader:'Týd',
        dateFormat:'dd.mm.yy',
        firstDay:1,
        isRTL:false,
        showMonthAfterYear:false,
        yearSuffix:''};
    $.datepicker.setDefaults($.datepicker.regional[window.itl_gem_active_language]);
});

/* DAteTime picker addon */
(function ($) {
    $.timepicker.regional['cs'] = {
        timeOnlyTitle:'Vyberte čas',
        timeText:'Čas',
        hourText:'Hodiny',
        minuteText:'Minuty',
        secondText:'Vteřiny',
        millisecText:'Milisekundy',
        timezoneText:'Časové pásmo',
        currentText:'Nyní',
        closeText:'Zavřít',
        timeFormat:'h:m',
        amNames:['dop.', 'AM', 'A'],
        pmNames:['odp.', 'PM', 'P'],
        ampm:false
    };
   $.timepicker.setDefaults($.timepicker.regional[window.itl_gem_active_language]);
})(jQuery);