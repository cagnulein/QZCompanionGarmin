import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class QZCompanionGarminApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new QZCompanionGarminView() ];
    }
}