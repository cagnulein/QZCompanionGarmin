using Toybox.Communications as Comms;
using Toybox.Lang;

class CommsRelay extends Comms.ConnectionListener {
    hidden var mCallback as Lang.Method;

    function initialize(callback as Lang.Method) as Void {
        ConnectionListener.initialize();
        mCallback = callback;
    }

    function onComplete() as Void {
        mCallback.invoke(true);
    }

    function onError() as Void {
        mCallback.invoke(false);
    }
}
