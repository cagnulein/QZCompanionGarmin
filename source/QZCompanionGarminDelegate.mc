import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.ActivityRecording;
import Toybox.System;

class QZCompanionGarminDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new Rez.Menus.MainMenu(), new QZCompanionGarminMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    var session as ActivityRecording.Session?;                                             // set up session variable

    function onBack() {
        if (Toybox has :ActivityRecording) {
            if ((session != null) && session.isRecording()) {
                session.discard();                                   // discard the session
                session = null;                                      // set session control variable to null
                // and don't exit
                return true;
            }
        }
        // now you can exit since the activity is discarded
        return false;
    }

    // use the select Start/Stop or touch for recording
    function onSelect() {
        if (Toybox has :ActivityRecording) {                         // check device for activity recording
            if ((session == null) || (session.isRecording() == false)) {
                if(QZCompanionGarminView.bike == false) {
                    session = ActivityRecording.createSession({          // set up recording session
                            :name=>"QZ Run",                              // set session name
                            :sport=>Activity.SPORT_RUNNING,                // set sport type
                            :subSport=>Activity.SUB_SPORT_INDOOR_RUNNING,          // set sub sport type
                            :disableGps=>true                              // disable GPS to save battery
                    });
                } else {
                    session = ActivityRecording.createSession({          // set up recording session
                            :name=>"QZ Ride",                              // set session name
                            :sport=>Activity.SPORT_CYCLING,                // set sport type
                            :subSport=>Activity.SUB_SPORT_INDOOR_CYCLING,          // set sub sport type
                            :disableGps=>true                              // disable GPS to save battery
                    });
                }
                session.start();                                     // call start session
            }
            else if ((session != null) && session.isRecording()) {
                session.discard();                                   // discard the session
                session = null;                                      // set session control variable to null
            }
        }
        return true;                                                 // return true for onSelect function
    }

// Detect Menu button input
    function onKey(keyEvent) {
        if(keyEvent.getKey() == 4) {
            onSelect(); // for Venu4
            return true;
        }
        System.println(keyEvent); // e.g. KEY_MENU = 7
        return false;
    }
}