import Toybox.Lang;
import Toybox.Time.Gregorian;
import Toybox.Complications;

class DataFields {
    var battLogEnabled = false;
    private var _battery;
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

    function subscribeStress() {
        _stress = null;
        if (_stressId != null) {
            Complications.subscribeToUpdates(_stressId);
        }
    }

    function unsubscribeStress() {
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

    function getDate(dateInfo as Gregorian.Info) {
        return Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.month, dateInfo.day]);
    }

    // current hr
    function getHeartRate() {
        var hr = Activity.getActivityInfo().currentHeartRate;
        if (hr != null && hr != 0 && hr != 255) {
            return hr;
        }
        return "--";
    }

    function getBodyBattery() {
        // https://developer.garmin.com/connect-iq/api-docs/Toybox/SensorHistory.html
        if ((Toybox has :SensorHistory) && (SensorHistory has :getBodyBatteryHistory)) {
            var sample = SensorHistory.getBodyBatteryHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST }).next();
            if (sample != null && sample.data != null && sample.data >= 0 && sample.data <= 100) {
                return sample.data.format("%d") + "%";
            }
            return "--";
        }
        return "n/a";
    }

    function getStress() {
        return ActivityMonitor.getInfo().stressScore + "%"; // rolling 30s average
    }

    function getSteps() {
        // https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityMonitor/Info.html
        return ActivityMonitor.getInfo().steps;
    }

    function getTimeToRecovery() {
        //return ActivityMonitor.getInfo().timeToRecovery;
        var comp = Complications.getComplication(new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME));
        if (comp.value != null) {
            return (comp.value / 60).toNumber();
        }
        return "--";
    }

    function getBattery() {
        //System.println("getBattery");
        var battery = System.getSystemStats().battery;
        if (battLogEnabled && battery != _battery) {
            _battery = battery;
            var time = System.getClockTime();
            System.println(Lang.format("Battery,$1$:$2$:$3$,$4$", [time.hour.format("%02d"), time.min.format("%02d"), time.sec.format("%02d"), battery]));
        }
        //return battery.format("%.2f") + "%";
        return Lang.format("$1$%", [battery.format("%d")]);
    }
}
