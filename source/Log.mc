using Toybox.System;
using Toybox.Lang;

enum {
    LOG_LEVEL_VERBOSE,
    LOG_LEVEL_DEBUG,
    LOG_LEVEL_INFO,
    LOG_LEVEL_WARNING,
    LOG_LEVEL_ERROR
}

class Log {
    private var logLevel as Number?;
    public function initialize(_logLevel as Number?) as Void {
        logLevel = _logLevel;
    }

    public function verbose(message as Lang.Object or String or Null) as Void {
        if (logLevel != null && logLevel <= LOG_LEVEL_VERBOSE) {
            System.print("VERBOSE: ");
            System.println(message);
        }
    }

    public function debug(message as Lang.Object or String or Null) as Void {
        if (logLevel != null && logLevel <= LOG_LEVEL_DEBUG) {
            System.print("DEBUG: ");
            System.println(message);
        }
    }

    public function info(message as Lang.Object or String or Null) as Void {
        if (logLevel != null && logLevel <= LOG_LEVEL_INFO) {
            System.print("INFO: ");
            System.println(message);
        }
    }

    public function warning(message as Lang.Object or String or Null) as Void {
        if (logLevel != null && logLevel <= LOG_LEVEL_WARNING) {
            System.print("WARNING: ");
            System.println(message);
        }
    }

    public function error(message as Lang.Object or String or Null) as Void {
        if (logLevel != null && logLevel <= LOG_LEVEL_ERROR) {
            System.print("ERROR: ");
            System.println(message);
        }
    }
}
