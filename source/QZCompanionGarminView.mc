import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Graphics;
using Toybox.Timer;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.UserProfile;

using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.Sensor;
using Toybox.Application;
using Toybox.Position;
using Toybox.Math;
using Toybox.Attention;

using Toybox.Communications;
using Toybox.Timer;

var log = new Log(LOG_LEVEL_VERBOSE);

class QZCompanionGarminView extends WatchUi.View {

    hidden var timer;

    // HR
    private var _heartRate;
    private var hr;

    // Foot cadence
    //private var _FOOTCAD;
    private var foot_cad;

    // Activity elapsed time
    private var _elapsedLabel;

    // Current HR zone
    private var _zone;
    hidden var zoneLowerBounds = [0, 120, 140, 160, 180]; // default values
    hidden var zoneFillColors  = [Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLUE, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED];

    // Current Distance
    private var _distance;

    // Current Pace
    private var _pace;

    // Communication
    hidden var message = new Communications.PhoneAppMessage();

    function initialize() {
        // HR Zones init
        computeHeartRateZoneBounds();

        // Initialize
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _heartRate = findDrawableById("Hr");
        _elapsedLabel = findDrawableById("Elapsed");
        _zone  = findDrawableById("Zone");
        _distance  = findDrawableById("Distance");
        _pace = findDrawableById("Pace");
    }

    // HR bounds computation based on user profile
    hidden function computeHeartRateZoneBounds() as Void{
        /* zones
        [0] min zone 1 - The minimum heart rate threshold for zone 1
        [1] max zone 1 - The maximum heart rate threshold for zone 1
        [2] max zone 2 - The maximum heart rate threshold for zone 2
        [3] max zone 3 - The maximum heart rate threshold for zone 3
        [4] max zone 4 - The maximum heart rate threshold for zone 4
        [5] max zone 5 - The maximum heart rate threshold for zone 5 */
        var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
        zoneLowerBounds = [ 0,zones[0],zones[1]+1,zones[2]+1,zones[3]+1,zones[4]+1 ];
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD] );
        Sensor.enableSensorEvents(method(:onSnsr));

        timer = new Timer.Timer();
		timer.start(method(:tick), 1000, true);
        Communications.registerForPhoneAppMessages(method(:phoneMessageCallback));
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
        if(timer!= null) {
            timer.stop();
            timer = null;    
        }
    }

    function updateMessage() as Void {
        // standard dictionary
        var message = [
            {
                0 => hr,
                1 => foot_cad
            },
        ];

        // Transmitting message
        Communications.transmit(message, null, new CommsRelay(method(:onTransmitComplete)));
    }

    // If you're debugging a problem with connecting/transmitting message, consult `README.md`.
    function onTransmitComplete(isSuccess) {
        if (isSuccess) {
            $.log.info("Message sent successfully.");
        } else {
            $.log.error("Message failed to send.");
        }
    }

    function phoneMessageCallback(_message as Toybox.Communications.Message) as Void {
        $.log.info("Message received: " + message);
        message = _message.data;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // returns Heart rate zone from 0 to 5
    hidden function getCurrentZoneIdForHR(hr) {
        var i=0;
        for ( i = 0; i < zoneLowerBounds.size() && hr > zoneLowerBounds[i]; ++i) { }
        return i;
    }

    function onSnsr(sensor_info as Toybox.Sensor.Info) as Void {
        var heartRateStr;
        var zoneStr;
        var zoneColor;

        var distanceStr;

        var info = Activity.getActivityInfo();
        if(info != null ) {
            var seconds_elapsed = (info.elapsedTime/1000);
            var elapsed_s = seconds_elapsed % 60;
            var elapsed_h = seconds_elapsed / 3600;
            var elapsed_m = (seconds_elapsed / 60) - (elapsed_h * 60);
            _elapsedLabel.setText(elapsed_h.format("%02d") + ":" + elapsed_m.format("%02d") + ":" + elapsed_s.format("%02d") );
        }

        if( sensor_info != null && sensor_info.heartRate != null ) {
            var hr = sensor_info.heartRate;
            heartRateStr = hr.toString();

            var currentZone = getCurrentZoneIdForHR(hr);
            // creating a
            zoneStr = "  Z" + currentZone.toString() + "  ";
            zoneColor = currentZone < zoneFillColors.size() ? zoneFillColors[currentZone] : Graphics.COLOR_TRANSPARENT;
        } else {
            heartRateStr = "---";
            zoneStr = "--";
            zoneColor = Graphics.COLOR_TRANSPARENT;
        }

        var distance;
        var activityMonitorInfo = Activity.getActivityInfo();
        distance = (activityMonitorInfo != null) ? activityMonitorInfo.elapsedDistance : null;
        distanceStr = (distance != null ) ? (distance/1000).format("%.2f") + " km" : "--";

        var paceStr;
        var speed = (activityMonitorInfo != null) ? activityMonitorInfo.currentSpeed : null;
        if( speed != null && speed > 0){
            // converts m/s to min/km
            var pace_minutes = 1 / (speed * 60 / 1000);
            var pace_seconds = (pace_minutes - floor(pace_minutes)) * 60 /*seconds*/;
            paceStr = pace_minutes.format("%02d") + ":" + pace_seconds.format("%02d"); // mm::ss
        } else {
            paceStr = "--";
        }

        // watch face texts
        _heartRate.setText(heartRateStr);
        _distance.setText(distanceStr);
        _pace.setText(paceStr);
        _zone.setText(zoneStr);
        _zone.setBackgroundColor(zoneColor);

        WatchUi.requestUpdate();
    }

    function tick() as Void {
        updateMessage();
    }
}
