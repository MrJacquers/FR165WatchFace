import Toybox.Lang;
import Toybox.Application.Storage;

class Settings {
    var bgColor;
    var dateColor;
    var hrColor;
    var connectColor;
    var hourColor;
    var minuteColor;
    var secColor;
    var bodyBattColor;
    var stressColor;
    var stepsColor;
    var timeToRecoveryColor;
    var battColor;
    var colorTest = false;

    var showGrid;
    var appAODEnabled = false;
    var battLogEnabled = false;

    function loadSettings() {
        // Set via ConnectIQ App.
        // https://developer.garmin.com/connect-iq/core-topics/properties-and-app-settings/
        if (Toybox.Application has :Properties) {
            bgColor = Application.Properties.getValue("BGColor").toNumberWithBase(16);
            dateColor = Application.Properties.getValue("DateColor").toNumberWithBase(16);
            hrColor = Application.Properties.getValue("HRColor").toNumberWithBase(16);
            connectColor = Application.Properties.getValue("ConnectColor").toNumberWithBase(16);            
            hourColor = Application.Properties.getValue("HourColor").toNumberWithBase(16);
            minuteColor = Application.Properties.getValue("MinuteColor").toNumberWithBase(16);
            secColor = Application.Properties.getValue("SecColor").toNumberWithBase(16);
            bodyBattColor = Application.Properties.getValue("BodyBattColor").toNumberWithBase(16);
            stressColor = Application.Properties.getValue("StressColor").toNumberWithBase(16);
            stepsColor = Application.Properties.getValue("StepsColor").toNumberWithBase(16);
            timeToRecoveryColor = Application.Properties.getValue("TimeToRecoveryColor").toNumberWithBase(16);
            battColor = Application.Properties.getValue("BattColor").toNumberWithBase(16);
            colorTest = Application.Properties.getValue("ColorTest");
        }

        // On-device settings, accessible via select watch face edit menu.
        if (Toybox.Application has :Storage) {
            showGrid = getValue("GridEnabled", false);
            appAODEnabled = getValue("AODModeEnabled", false);
            battLogEnabled = getValue("BattLogEnabled", false);
        }
    }

    function getValue(name, defaultValue) {
        var value = Storage.getValue(name);
        if (value != null) {
            return value;
        } else {
            return defaultValue;
        }
    }

    function setValue(key, value) {
        Storage.setValue(key, value);
    }
}
