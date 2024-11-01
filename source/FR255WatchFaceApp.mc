import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

var BatteryLevel = 0;
var ShowBatteryHistory = false;

class FR255WatchFaceApp extends Application.AppBase {
    private var _faceView = null;

    function initialize() {
        //System.println("app initialize");
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        //System.println("app onStart");

        //Settings.setValue("BatteryLevelHistory", "");
        //Settings.setValue("BatteryLevelHistory", "01 10:15 50");

        // get the battery level history
        var history = Settings.getValue("BatteryLevelHistory", "");
        if (!history.equals("")) {
            var entries = Utils.splitString(history, ",");
            //System.println(entries.toString());
            var last = entries[entries.size() - 1];
            var parts = Utils.splitString(last, " ");
            //System.println(parts.toString());
            BatteryLevel = parts[parts.size() -1].toNumber();
        }
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        //System.println("app onStop");
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        //System.println("getInitialView");
        _faceView = new FR255WatchFaceView();
        return [_faceView, new WatchDelegate()];
    }

    function getSettingsView() {
        //System.println("getSettingsView");
        return [new ODSettingsMenu(), new ODSettingsMenuDelegate()];
    }

    // New app settings have been received so trigger a UI update.
    // This applies to settings via ConnectIQ, not on-device settings.
    // I think that when using ODS the app gets restarted.
    function onSettingsChanged() as Void {
        //System.println("onSettingsChanged");
        if (_faceView != null) {
            _faceView.loadSettings();
            WatchUi.requestUpdate();
        }
    }
}

function getApp() as FR255WatchFaceApp {
    return Application.getApp() as FR255WatchFaceApp;
}
