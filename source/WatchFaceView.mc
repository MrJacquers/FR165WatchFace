import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class WatchFaceView extends WatchUi.WatchFace {
  private var _devSize;
  private var _devCenter;
  private var _iconFont;
  private var _timeFont;
  private var _hidden;
  private var _lowPwrMode;
  private var _settings;
  private var _dataFields;
  private var _isDay = true;

  function initialize() {
    //System.println("view.initialize");
    WatchFace.initialize();

    loadSettings();
    
    _dataFields = new DataFields();
    _dataFields.registerComplications();
    _dataFields.battLogEnabled = _settings.battLogEnabled;
  }

  function loadSettings() {
    if (_settings == null) {
      _settings = new Settings();
    }
    
    _settings.loadSettings();

    _iconFont = WatchUi.loadResource(Rez.Fonts.id_icons);

    if (_settings.timeFont == 0) {
      _timeFont = WatchUi.loadResource(Rez.Fonts.id_rajdhani_bold_mono);
    } else if (_settings.timeFont == 1) {
      _timeFont = WatchUi.loadResource(Rez.Fonts.id_saira_outline);
    } else {
      _timeFont = WatchUi.loadResource(Rez.Fonts.id_saira_reg);
    }
  }

  function onLayout(dc as Dc) as Void {
    //System.println("onLayout");
    _devSize = dc.getWidth();
    _devCenter = _devSize / 2;
  }

  // Called when this View is brought to the foreground.
  // Restore the state of this View and prepare it to be shown.
  // This includes loading resources into memory.
  function onShow() as Void {
    //System.println("onShow");
    _hidden = false;
    _lowPwrMode = false;
    checkIfDayOrNight();
    //_dataFields.subscribeComplications();
  }

  // Called when this View is removed from the screen. Save the state of this View here.
  // This includes freeing resources from memory.
  function onHide() as Void {
    //System.println("onHide");
    _hidden = true;
    //_dataFields.unsubscribeComplications();
  }

  // Terminate any active timers and prepare for slow updates (once a minute).
  function onEnterSleep() as Void {
    //System.println("onEnterSleep");
    _lowPwrMode = true;
    //_dataFields.unsubscribeComplications();
    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    //System.println("onExitSleep");
    _lowPwrMode = false;
    checkIfDayOrNight();
    //_dataFields.subscribeComplications();
    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }

  // Updates the View:
  // Called once a minute in low power mode.
  // Called every second in high power mode, e.g. after a gesture, for a couple of seconds.
  function onUpdate(dc as Dc) as Void {
    //System.println("onUpdate");
    clearScreen(dc);

    if (_hidden || _lowPwrMode) {
      //System.println("low power mode");
      if (_settings.battLogEnabled) {
        _dataFields.getBattery();
      }
      return;
    }

    if (ShowBatteryHistory) {
      dc.setColor(Graphics.COLOR_DK_GRAY, _settings.bgColor);
      
      if (!_settings.battLogEnabled) {
        dc.drawText(_devCenter, _devCenter, Graphics.FONT_SMALL, "Battery Log Disabled", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        return;
      }

      _dataFields.getBattery();
      var history = Settings.getStorageValue("BatteryHistory", "");
      var entries = Utils.splitString(history, ",");

      if (entries.size() == 0) {
        dc.drawText(_devCenter, _devCenter, Graphics.FONT_SMALL, "No Battery History", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        return;
      }
      
      var y = 60;
      for (var i = 0; i < entries.size(); i++) {
        dc.drawText(_devCenter, y, Graphics.FONT_TINY, entries[i], Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += 30;
      }
      
      return;
    }

    // get the device settings
    var deviceSettings = System.getDeviceSettings();

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    // dnd (sleep mode) display
    if (deviceSettings.doNotDisturb) {
      dc.setColor(_settings.textColorSleep, _settings.bgColor);

      // phone connected
      if (deviceSettings.phoneConnected) {
        dc.drawText(_devCenter, 40, _iconFont, "b", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      }
      
      // date
      var date = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.day, dateInfo.month]);
      dc.drawText(_devCenter, 85, Graphics.FONT_SMALL, date, Graphics.TEXT_JUSTIFY_CENTER);
      
      // hour
      dc.drawText(_devCenter - 5, _devCenter, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
      
      // minute
      dc.drawText(_devCenter + 5, _devCenter, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

      // heart rate and battery
      dc.drawText(_devCenter, 260, Graphics.FONT_SMALL, _dataFields.getHeartRate() + "   " +  _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER);

      // lines for positioning   
      drawGrid(dc);
      return;
    }

    // foreground color
    dc.setColor(_isDay ? _settings.textColorDay : _settings.textColorNight, _settings.bgColor);
    
    // hour
    dc.drawText(110, 85, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    // minute
    dc.drawText(110, 235, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    // phone connected
    if (deviceSettings.phoneConnected) {
      dc.drawText(285, _devCenter, _iconFont, "b", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // date
    var date = Lang.format("$1$ $2$", [dateInfo.day_of_week, dateInfo.day]);
    dc.drawText(45, _devCenter, Graphics.FONT_SMALL, date, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // heart rate
    dc.drawText(210, 80, _iconFont, "h", Graphics.TEXT_JUSTIFY_LEFT);
    dc.drawText(255, 75, Graphics.FONT_SMALL, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_LEFT);

    // steps
    dc.drawText(210, 120, _iconFont, "s", Graphics.TEXT_JUSTIFY_LEFT);
    dc.drawText(255, 115, Graphics.FONT_SMALL, _dataFields.getSteps(), Graphics.TEXT_JUSTIFY_LEFT);

    // seconds
    dc.drawText(210, _devCenter, Graphics.FONT_SMALL, dateInfo.sec.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

    // recovery time
    dc.drawText(210, 235, _iconFont, "r", Graphics.TEXT_JUSTIFY_LEFT);
    dc.drawText(255, 230, Graphics.FONT_SMALL, _dataFields.getRecoveryTime(), Graphics.TEXT_JUSTIFY_LEFT);
    
    // battery
    dc.drawText(210, 270, Graphics.FONT_SMALL, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_LEFT);
    //dc.drawRectangle(200, 270, 90, 50);

    // lines for positioning
    drawGrid(dc);    
  }

  private function checkIfDayOrNight() {
    var now = Time.now();
    var location = Activity.getActivityInfo().currentLocation;

    if (location == null) {
      // get last known location from storage
      var latitude = Settings.getStorageValue("LastLocationLat", null);
      var longitude = Settings.getStorageValue("LastLocationLon", null);
      if (latitude != null && longitude != null) {
        location = new Position.Location({ :latitude => latitude, :longitude => longitude, :format => :degrees });
      }
    }

    if (location != null) {
      // save in storage
      var locationInfo = location.toDegrees();			
			Settings.setStorageValue("LastLocationLat", locationInfo[0]);
			Settings.setStorageValue("LastLocationLon", locationInfo[1]);

      // get sunrise and sunset times
      var sunrise = Weather.getSunrise(location, now);
      var sunset = Weather.getSunset(location, now);
      //var sunriseInfo = Gregorian.info(sunrise, Time.FORMAT_MEDIUM);
      //var sunsetInfo = Gregorian.info(sunset, Time.FORMAT_MEDIUM);

      // check if it's day or night
      _isDay = now.value() >= sunrise.value() && now.value() <= sunset.value();
      return;
    }
    
    // no location info, use default values
    var dateInfo = Gregorian.info(now, Time.FORMAT_SHORT);
    _isDay = dateInfo.hour > 5 && dateInfo.hour < 18;
  }
  
  (:debug)
  private function clearScreen(dc as Dc) {
    dc.setColor(0, _settings.bgColor);
    dc.clear();
  }

  (:release)
  private function clearScreen(dc as Dc) {
    // no need for this on actual device
  }

  // lines for layout positioning
  private function drawGrid(dc as Dc) {
    if (!_settings.showGrid) {
      return;
    }

    var i = 0;
    var gapSize = _devSize / 20.0;

    dc.setColor(Graphics.COLOR_DK_GRAY, -1);
    do {
      i += gapSize;
      dc.drawLine(0, i, _devSize, i); // horizontal line
      dc.drawLine(i, 0, i, _devSize); // vertical line
      //dc.drawCircle(_devCenter,_devCenter,i);  // x,y,r
    } while (i < _devSize);

    i = _devCenter;
    dc.setColor(Graphics.COLOR_LT_GRAY, -1);
    dc.drawLine(0, i, _devSize, i); // horizontal line
    dc.drawLine(i, 0, i, _devSize); // vertical line
  }
}
