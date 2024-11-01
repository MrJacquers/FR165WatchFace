import Toybox.Lang;
import Toybox.WatchUi;

// https://developer.garmin.com/connect-iq/core-topics/native-controls/
class ODSettingsMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize(null);
        Menu2.setTitle("Settings");

        var settings = new Settings();
        settings.loadSettings();
        Menu2.addItem(new WatchUi.ToggleMenuItem("Show Grid", "Show Grid", "GridEnabled", settings.showGrid, null));
        Menu2.addItem(new WatchUi.ToggleMenuItem("Batt Log", "Log Battery Level", "BattLogEnabled", settings.battLogEnabled, null));
    }
}
