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

var log = new Log(LOG_LEVEL_VERBOSE);

class QZCompanionGarminView extends Ui.DataField {

    hidden var timer;
    private var _HR;
    private var hr;
    private var _FOOTCAD;
    private var foot_cad;
    hidden var message = new Communications.PhoneAppMessage();

    function initialize() {
        DataField.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 22;
        	labelView.setJustification(Gfx.TEXT_JUSTIFY_RIGHT);
        	labelView.setColor(Gfx.COLOR_BLACK);

            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 0;
            valueView.setFont(Gfx.FONT_NUMBER_MEDIUM);
        }

        View.findDrawableById("label").setText(Rez.Strings.label);
        return true;
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
        var bgColor = Gfx.COLOR_WHITE;
        var fgColor = Gfx.COLOR_BLACK;
        var profile = UserProfile.getProfile();

        if( profile != null ) {
	        mHRZones = profile.getHeartRateZones(profile.getCurrentSport());
	    }


        if( mHeartRate >= mHRZones[4])
        { 
        	bgColor = Gfx.COLOR_RED;
        }
        else if( mHeartRate >= mHRZones[3])
        {
			bgColor = Gfx.COLOR_YELLOW;
        }
        else if( mHeartRate >= mHRZones[2])
        {
        	bgColor = Gfx.COLOR_GREEN;
        }
        else if( mHeartRate >= mHRZones[1])
        {
        	bgColor = Gfx.COLOR_BLUE;
        }
        else if( mHeartRate >= mHRZones[0])
        {
        	bgColor = Gfx.COLOR_LT_GRAY;
        }

        // Set the background color
        View.findDrawableById("Background").setColor(bgColor);

        // Set the foreground color and value
        var value = View.findDrawableById("value");
        value.setColor(fgColor);

        value.setText(mHeartRate.format("%d"));

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
        updateMessage();
    }
}
