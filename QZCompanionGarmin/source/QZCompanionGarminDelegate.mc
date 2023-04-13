import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.ActivityRecording;

class QZCompanionGarminDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new QZCompanionGarminMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    var session = null;                                             // set up session variable

    function onBack() {
        if (Toybox has :ActivityRecording) {         
            return false;
        }
        return true;
    }

    // use the select Start/Stop or touch for recording
    function onSelect() {
        if (Toybox has :ActivityRecording) {                         // check device for activity recording
            if ((session == null) || (session.isRecording() == false)) {
                session = ActivityRecording.createSession({          // set up recording session
                        :name=>"QZ Run",                              // set session name
                        :sport=>Activity.SPORT_RUNNING,                // set sport type
                        :subSport=>Activity.SUB_SPORT_INDOOR_RUNNING          // set sub sport type
                });
                session.start();                                     // call start session
            }
            else if ((session != null) && session.isRecording()) {
                session.stop();                                      // stop the session
                session.discard();                                   // discard the session
                session = null;                                      // set session control variable to null
            }
        }
        return true;                                                 // return true for onSelect function
    }

}