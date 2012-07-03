(function (window, undefined) {

    //redirect for ajax navigation, must do this before our history.js
//    	if(window.location.hash.length > 0){
//    		window.location = "http://stealthwd.ca/" + window.location.hash.slice(1);
//    	}


    // Prepare
    var History = window.History; // Note: We are using a capital H instead of a lower h
    if (!History.enabled) {
        // History.js is disabled for this browser.
        // This is because we can optionally choose to support HTML4 browsers or not.
        return false;
    }
    //    console.log('init');
    //    console.log(History);
    historyBool = true; //true is our default

    // Bind to StateChange Event
    History.Adapter.bind(window, 'statechange', function () { // Note: We are using statechange instead of popstate
        var State = History.getState(); // Note: We are using History.getState() instead of event.state
        //        console.log('state');
        //        console.log(window.location.href);
//                console.log(State);
        //        History.log(State.data, State.title, State.url);
        //        console.log(window.location.hash)

        // /don't run our function when we do a pushState
        if (historyBool) {
            //            console.log("going back by browser")
            historyBool = false;
            // ToDo bude mozne zde volat funkci ulozenou ve state, pokud budu potrebovat vic nez jednu ajaxovou plochu
            load_page({url:State.url, symlink_remote:true})
        }
        //set to our default of true
        historyBool = true;
    });


})(window);

