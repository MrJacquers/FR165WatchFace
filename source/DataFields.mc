import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.Complications;

class DataFields {
    var battLogEnabled = false;
    private var _stress;
    private var _stressId;

    // https://developer.garmin.com/connect-iq/core-topics/complications/
    // https://developer.garmin.com/connect-iq/api-docs/Toybox/Complications.html
    function registerComplications() {
        if (Toybox has :Complications) {
            //System.println("registering complications");
            _stressId = new Complications.Id(Complications.COMPLICATION_TYPE_STRESS);
            Complications.registerComplicationChangeCallback(self.method(:onComplicationChanged));
        }
    }

    function subscribeToComplications() {
        _stress = null;
        if (_stressId != null) {
            Complications.subscribeToUpdates(_stressId);
        }
    }

    function unsubscribeFromComplications() {
        _stress = null;
        if (_stressId != null) {
            Complications.unsubscribeFromUpdates(_stressId);
        }
    }

    function onComplicationChanged(id as Complications.Id) as Void {
        //System.println("onComplicationChanged");
        var comp = Complications.getComplication(id);

        if (id == _stressId) {
            //System.println("stress updated: " + comp.value);
            _stress = comp.value;
            return;
        }
    }

    function getHeartRate() {
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr != null && hr != 0 && hr != 255) {
            return hr;
        }
        return "--";
    }

    function getBodyBattery() {
        var comp = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_BODY_BATTERY));
        if (comp.value != null) {
            return (comp.value);
        }
        return "--";
    }
    
    function getStress() {
        return ActivityMonitor.getInfo().stressScore + "%"; // rolling 30s average
    }

    function getSteps() {
        return ActivityMonitor.getInfo().steps;
    }

    function getRecoveryTime() {
        /*if (ActivityMonitor.getInfo() has :timeToRecovery) {
            return ActivityMonitor.getInfo().timeToRecovery;
        }*/

        if (Toybox has :Complications) {
            var compId = new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME);
            var comp = Complications.getComplication(compId);
            if (comp.value != null) {
                return (comp.value / 60.0).format("%.1f");
            }
        }

        return "--";
    }

    function getAltitude() {
        if (Activity.getActivityInfo() has :altitude) {
            var altitude = Activity.getActivityInfo().altitude;
            if (altitude != null) {
                return altitude.toNumber();
            }
        }
        return "--";        
    }

    function getBattery() {
        //System.println("getBattery");
        var battery = System.getSystemStats().battery;

        if (battLogEnabled && battery != BatteryLevel) {
            BatteryLevel = battery;

            // get the battery level history
            var history = Settings.getStorageValue("BatteryLevelHistory", "");
            //System.println("history: " + history);
                        
            // add the battery level to the history
            var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            history += Lang.format("$1$ $2$:$3$ $4$,", [dateInfo.day.format("%02d"), dateInfo.hour.format("%02d"), dateInfo.min.format("%02d"), battery.format("%02d")]);

            // split the history into entries
            var entries = Utils.splitString(history, ",");
            //System.println("entries: " + entries.toString());

            var maxToKeep = 10;
            if (entries.size() > maxToKeep) {
                history = "";
                for (var i = entries.size() - maxToKeep; i < entries.size(); i++) {
                    history += entries[i] + ",";
                }
            }

            // save the history
            Settings.setStorageValue("BatteryLevelHistory", history);
        }

        //return battery.format("%.2f") + "%";
        return Lang.format("$1$%", [battery.format("%d")]);
    }
}
