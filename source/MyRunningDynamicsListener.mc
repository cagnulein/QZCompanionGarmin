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
using Toybox.AntPlus;
import Toybox.AntPlus;

using Toybox.Communications;

class MyRunningDynamicsListener  extends RunningDynamicsListener {
    public var stepLength;

    function initialize() {
        RunningDynamicsListener.initialize();
    }

    function onRunningDynamicsUpdate(data) {
        stepLength = data.stepLength;
    }
}