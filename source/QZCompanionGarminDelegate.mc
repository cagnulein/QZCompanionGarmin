import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.ActivityRecording;
using Toybox.Attention;

class QZCompanionGarminDelegate extends WatchUi.BehaviorDelegate {

    var session = null;  
    function initialize() {
        BehaviorDelegate.initialize();        

        // Start activity session
        session = ActivityRecording.createSession({
                        :name=>"QZ Run",
                        :sport=>Activity.SPORT_RUNNING,
                        :subSport=>Activity.SUB_SPORT_INDOOR_RUNNING
                });
        session.start();
        Attention.playTone(Attention.TONE_START);

        WatchUi.requestUpdate();
    }

    function onSelect() {
        if (Toybox has :ActivityRecording) {    
            if( session != null && session.isRecording()) {
                Attention.playTone(Attention.TONE_STOP);
                WatchUi.pushView(new Rez.Menus.StopActivity(), new QZCompanionGarminStopActivityDelegate(session), WatchUi.SLIDE_IMMEDIATE);   
            }
        }
        return true;
    }

    function onBack() {
        if (Toybox has :ActivityRecording) {    
            // Add Lap
            if( session != null && session.isRecording() )
            {
                session.addLap();
                Attention.playTone(Attention.TONE_LAP);
                return true;
            }
        }
        return false;
    }

    function onShow() {
        WatchUi.requestUpdate();
    }
}