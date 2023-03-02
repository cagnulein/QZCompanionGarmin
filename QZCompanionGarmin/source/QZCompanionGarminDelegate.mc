import Toybox.Lang;
import Toybox.WatchUi;

class QZCompanionGarminDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new QZCompanionGarminMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

}