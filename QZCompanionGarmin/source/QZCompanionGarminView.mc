import Toybox.Graphics;
import Toybox.WatchUi;

using Toybox.Graphics as Gfx;
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

var log = new Log(LOG_LEVEL_VERBOSE);

class QZCompanionGarminView extends WatchUi.DataField {

    hidden var timer;
    private var _HR;
    private var hr;
    private var _FOOTCAD;
    private var foot_cad;
    hidden var message = new Communications.PhoneAppMessage();
    hidden var mHRZones = [120, 132, 145,158, 171];

    function initialize() {
        DataField.initialize();
    }


    function phoneMessageCallback(_message as Toybox.Communications.Message) as Void {
        $.log.info("Message received. Contents:");
        message = _message.data;
        $.log.info(message);
    }

    //! The given info object contains all the current workout
    //! information. Calculate a value and save it locally in this method.
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        if (info.currentHeartRate != null)
        {
        	hr = info.currentHeartRate;
            foot_cad = info.currentCadence;
        }
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

    function updateMessage() as Void {
        $.log.verbose("Updating message.");

		// standard dictionary
        var message = [
            {
                0 => hr,
                1 => foot_cad,
            },
        ];
        $.log.verbose("Transmitting message.");
        Communications.transmit(message, null, new CommsRelay(method(:onTransmitComplete)));
        $.log.verbose("Message transmitted.");
    }

    // If you're debugging a problem with connecting/transmitting message, consult `README.md`.
    function onTransmitComplete(isSuccess) {
        if (isSuccess) {
            $.log.info("Message sent successfully.");
        } else {
            $.log.error("Message failed to send.");
        }
    }

    //! Display the value you computed here. This will be called
    //! once a second when the data field is visible.
    function onUpdate(dc) {
        //var bgColor = Gfx.COLOR_WHITE;
        //var fgColor = Gfx.COLOR_BLACK;
        //var profile = UserProfile.getProfile();

        /*if( profile != null ) {
	        mHRZones = profile.getHeartRateZones(profile.getCurrentSport());
	    }*/

/*
        if( hr >= mHRZones[4])
        { 
        	bgColor = Gfx.COLOR_RED;
        }
        else if( hr >= mHRZones[3])
        {
			bgColor = Gfx.COLOR_YELLOW;
        }
        else if( hr >= mHRZones[2])
        {
        	bgColor = Gfx.COLOR_GREEN;
        }
        else if( hr >= mHRZones[1])
        {
        	bgColor = Gfx.COLOR_BLUE;
        }
        else if( hr >= mHRZones[0])
        {
        	bgColor = Gfx.COLOR_LT_GRAY;
        }

        // Set the background color
        View.findDrawableById("Background").setColor(bgColor);

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        value.setColor(fgColor);

        value.setText(hr.format("%d"));*/

        // Call parent's onUpdate(dc) to redraw the layout
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
        hr = sensor_info.heartRate;
        foot_cad = sensor_info.cadence;
        if( sensor_info.heartRate != null )
        {
            string_HR = hr.toString() + "bpm";
        }
        else
        {
            string_HR = "---bpm";
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
        var step = Activity.getCurrentWorkoutStep();
        if(step != null) {
            $.log.info("duration " + step.step.durationValue);
        }
        updateMessage();
    }
}
