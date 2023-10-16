import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class QZCompanionGarminStopActivityDelegate extends WatchUi.MenuInputDelegate {

    private var _session;

    function initialize(session) {
        MenuInputDelegate.initialize();
        _session = session;
        WatchUi.requestUpdate();
    }

    function onMenuItem(item as Symbol) as Void {
        var requestedExit = false;
        switch(item) {
            case :Resume :
                //WatchUi.popView(SLIDE_IMMEDIATE);
                break;
            case :Discard :
                if(_session!=null) {
                    _session.discard();
                    _session = null;
                }
                requestedExit = true;
                break;
            case :Save :
                if(_session!=null) {
                    _session.save();
                    _session = null;
                }
                requestedExit = true;
                break;
        }
        if( requestedExit ) {
            System.exit();
        }
        return;
    }
}