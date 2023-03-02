import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Graphics;
using Toybox.Timer;
using Toybox.ActivityMonitor as Act;
using Toybox.Activity as Acty;


class QZCompanionGarminView extends WatchUi.View {

    hidden var timer;
    private var HR;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        HR = findDrawableById("HR");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        timer = new Timer.Timer();
		timer.start(method(:tick), 1000, true);
		//updateMessage();
        //Comms.registerForPhoneAppMessages(method(:phoneMessageCallback));
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function tick() as Void {
        if (Act has :getHeartRateHistory) {
            var heartRate = Activity.getActivityInfo().currentHeartRate;
            if(heartRate==null) {
                var HRH=Act.getHeartRateHistory(1, true);
                var HRS=HRH.next();
                if(HRS!=null && HRS.heartRate!= Act.INVALID_HR_SAMPLE){
                    heartRate = HRS.heartRate;
                }
            }
            if(heartRate!=null) {
                heartRate = heartRate.toString();
            } else{
                heartRate = "--";
            }
            
            HR.setText("HR: " + heartRate);
            WatchUi.requestUpdate();
        }
    }
}
