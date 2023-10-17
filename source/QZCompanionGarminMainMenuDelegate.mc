import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class QZCompanionGarminMainMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
        WatchUi.requestUpdate();
    }

    function onMenuItem(item as Symbol) as Void {
        var requestedExit = false;
        switch(item) {
            case :Start :
                WatchUi.pushView(new QZCompanionGarminView(), new QZCompanionGarminDelegate(), WatchUi.SLIDE_IMMEDIATE);
                break;
            case :Quit :
                requestedExit = true;
                break;
        }

        if(requestedExit) {
            System.exit();
        }
        return;
    }
}