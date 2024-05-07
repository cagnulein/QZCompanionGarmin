import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Graphics;
using Toybox.Timer;
using Toybox.ActivityMonitor as Act;
using Toybox.Activity as Acty;

using Toybox.System;
using Toybox.Lang;
using Toybox.Time.Gregorian;
using Toybox.Sensor;
using Toybox.Application;
using Toybox.Position;

using Toybox.Communications;

//var log = new Log(LOG_LEVEL_VERBOSE);

class QZCompanionGarminView extends WatchUi.View {

    hidden var timer;
    private var _HR;
    private var hr;
    private var _FOOTCAD;
    private var foot_cad;
    private var _ELAPSED;
    private var _INFO;
    hidden var message = new Communications.PhoneAppMessage();

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        _HR = findDrawableById("HR");
        _FOOTCAD = findDrawableById("FOOTCAD");
        _ELAPSED = findDrawableById("ELAPSED");
        _INFO = findDrawableById("INFO");
    }

    function phoneMessageCallback(_message as Toybox.Communications.Message) as Void {
        //$.log.info("Message received. Contents:");
        message = _message.data;
        //$.log.info(message);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
        var deviceSettings = System.getDeviceSettings().monkeyVersion;

        // Now you can use apiLevel as needed
        System.println("API Level: " + deviceSettings);

        if((deviceSettings[0] == 3 && deviceSettings[1] >= 2) || deviceSettings[0] > 3) {
            Sensor.setEnabledSensors( [Sensor.SENSOR_ONBOARD_HEARTRATE, Sensor.SENSOR_FOOTPOD] );
        } else {
            Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD] );
        }
        Sensor.enableSensorEvents(method(:onSnsr));

        timer = new Timer.Timer();
		timer.start(method(:tick), 1000, true);
        Communications.registerForPhoneAppMessages(method(:phoneMessageCallback));
    }

    function updateMessage() as Void {
        //$.log.verbose("Updating message.");

		// standard dictionary
        var message = [
            {
                0 => hr,
                1 => foot_cad,
            },
        ];
        //$.log.verbose("Transmitting message.");
        Communications.transmit(message, null, new CommsRelay(method(:onTransmitComplete)));
        //$.log.verbose("Message transmitted.");
    }

    // If you're debugging a problem with connecting/transmitting message, consult `README.md`.
    function onTransmitComplete(isSuccess) {/*
        if (isSuccess) {
            $.log.info("Message sent successfully.");
        } else {
            $.log.error("Message failed to send.");
        }*/
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

    function onSnsr(sensor_info as Toybox.Sensor.Info) as Void {
        var string_HR;
        var string_FOOTCAD;
        var info = Activity.getActivityInfo();
        if(info != null) {
            var seconds_elapsed = (info.elapsedTime/1000);
            var elapsed_s = seconds_elapsed % 60;
            var elapsed_h = seconds_elapsed / 3600;
            var elapsed_m = (seconds_elapsed / 60) - (elapsed_h * 60); 
            _ELAPSED.setText(elapsed_h.format("%02d") + ":" + elapsed_m.format("%02d") + ":" + elapsed_s.format("%02d") );      
        } 
        hr = sensor_info.heartRate;
        foot_cad = sensor_info.cadence;
        if( sensor_info.heartRate != null )
        {
            string_HR = hr.toString() + "bpm";
            _INFO.setText("");
         }
        else
        {
            string_HR = "---bpm";
            _INFO.setText("press start");
        }

        if( sensor_info.cadence != null )
        {
            string_FOOTCAD = foot_cad.toString() + "rpm";
        }
        else
        {
            string_FOOTCAD = "---rpm";
        }

        _HR.setText("HR: " + string_HR);
        _FOOTCAD.setText("STEP: " + string_FOOTCAD);
        

        WatchUi.requestUpdate();
    }

    function tick() as Void {
        updateMessage();
    }
}
