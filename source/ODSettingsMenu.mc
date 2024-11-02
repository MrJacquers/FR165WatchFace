import Toybox.Lang;
import Toybox.WatchUi;

// https://developer.garmin.com/connect-iq/core-topics/native-controls/
class ODSettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize(null);
        Menu2.setTitle("Settings");

        var settings = new Settings();
        settings.loadSettings();
        Menu2.addItem(new WatchUi.ToggleMenuItem("Battery Log", "Log Battery Level", "BattLogEnabled", settings.battLogEnabled, null));
        Menu2.addItem(new WatchUi.ToggleMenuItem("Grid", "Draw Grid Lines", "GridEnabled", settings.showGrid, null));
    }
}
