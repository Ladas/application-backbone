


/* JQuery UI date picker plugin. */
jQuery(function($){
	$.datepicker.regional['sk'] = {
		closeText: 'Zavřít',
		prevText: '&#x3c;Dříve',
		nextText: 'Později&#x3e;',
		currentText: 'Nyní',
		monthNames: ['leden','únor','březen','duben','květen','červen',
        'červenec','srpen','září','říjen','listopad','prosinec'],
		monthNamesShort: ['led','úno','bře','dub','kvě','čer',
		'čvc','srp','zář','říj','lis','pro'],
		dayNames: ['neděle', 'pondělí', 'úterý', 'středa', 'čtvrtek', 'pátek', 'sobota'],
		dayNamesShort: ['ne', 'po', 'út', 'st', 'čt', 'pá', 'so'],
		dayNamesMin: ['ne','po','út','st','čt','pá','so'],
		weekHeader: 'Týd',
		dateFormat: 'dd.mm.yy',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''};
	$.datepicker.setDefaults($.datepicker.regional[itl_gem_active_language]);
});

/* DAteTime picker addon */
(function($) {
	$.timepicker.regional['sk'] = {
		timeOnlyTitle: 'Vyberte čas',
		timeText: 'Čas',
		hourText: 'Hodiny',
		minuteText: 'Minuty',
		secondText: 'Vteřiny',
		millisecText: 'Milisekundy',
		timezoneText: 'Časové pásmo',
		currentText: 'Nyní',
		closeText: 'Zavřít',
		timeFormat: 'h:m',
		amNames: ['dop.', 'AM', 'A'],
		pmNames: ['odp.', 'PM', 'P'],
		ampm: false
	};
	$.timepicker.setDefaults($.timepicker.regional[itl_gem_active_language]);
})(jQuery);