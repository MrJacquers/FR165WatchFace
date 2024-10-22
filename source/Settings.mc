import Toybox.Lang;
import Toybox.Application.Storage;

class Settings {
    var layoutType;
    var bgColor;
    var textColor;
    var timeFont;
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

    var showGrid;
    var appAODEnabled = false;
    var battLogEnabled = false;

    function loadSettings() {
        // Set via ConnectIQ App.
        // https://developer.garmin.com/connect-iq/core-topics/properties-and-app-settings/
        if (Toybox.Application has :Properties) {
            layoutType = Application.Properties.getValue("LayoutType");
            bgColor = Application.Properties.getValue("BGColor");
            textColor = Application.Properties.getValue("TextColor");
            timeFont = Application.Properties.getValue("TimeFont");
            dateColor = Application.Properties.getValue("DateColor");
            hrColor = Application.Properties.getValue("HRColor");
            connectColor = Application.Properties.getValue("ConnectColor");            
            hourColor = Application.Properties.getValue("HourColor");
            minuteColor = Application.Properties.getValue("MinuteColor");
            secColor = Application.Properties.getValue("SecColor");
            bodyBattColor = Application.Properties.getValue("BodyBattColor");
            stressColor = Application.Properties.getValue("StressColor");
            stepsColor = Application.Properties.getValue("StepsColor");
            timeToRecoveryColor = Application.Properties.getValue("TimeToRecoveryColor");
            battColor = Application.Properties.getValue("BattColor");
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
