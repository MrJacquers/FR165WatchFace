import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class WatchFaceView extends WatchUi.WatchFace {
  private var _devSize;
  private var _devCenter;
  private var _timeFont;
  private var _hidden;
  private var _lowPwrMode;
  private var _settings;
  private var _dataFields;

  function initialize() {
    //System.println("view initialize");
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

    if (_settings.timeFont == 0) {
      _timeFont = WatchUi.loadResource(Rez.Fonts.id_source_sans_pro_bold);
    } else if (_settings.timeFont == 1) {
      _timeFont = WatchUi.loadResource(Rez.Fonts.id_poppins_bold);
    } else {
      _timeFont = WatchUi.loadResource(Rez.Fonts.id_rajdhani_bold_mono);
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
    //_dataFields.subscribeComplications();
    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }

  // Updates the View:
  // Called once a minute in low power mode.
  // Called every second in high power mode, e.g. after a gesture, for a couple of seconds.
  (:fr165m)
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
      var history = Settings.getStorageValue("BatteryLevelHistory", "");
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

    // lines for positioning
    /*if (_settings.showGrid) {
      drawGrid(dc);
    }*/

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    // sleep mode display
    if (dateInfo.hour > 21 || dateInfo.hour < 6) {
      dc.setColor(_settings.textColorSleep, _settings.bgColor);
      
      // date
      var date = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.day, dateInfo.month]);
      dc.drawText(_devCenter, 85, Graphics.FONT_SMALL, date, Graphics.TEXT_JUSTIFY_CENTER);
      
      // hour
      dc.drawText(_devCenter - 5, _devCenter, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
      
      // minute
      dc.drawText(_devCenter + 5, _devCenter, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);

      // heart rate and battery
      dc.drawText(_devCenter, 260, Graphics.FONT_SMALL, _dataFields.getHeartRate() + "   " +  _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER);

      return;
    }

    // Set the foreground color.
    dc.setColor(dateInfo.hour < 18 ? _settings.textColorDay : _settings.textColorNight, _settings.bgColor);

    // altitude
    dc.drawText(_devCenter, 15, Graphics.FONT_SMALL, _dataFields.getAltitude(), Graphics.TEXT_JUSTIFY_CENTER);
    //dc.drawRectangle(160, 10, 80, 50);

    // hour
    dc.drawText(_devCenter, 77, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    // minute
    dc.drawText(_devCenter, 233, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    // phone connected
    if (System.getDeviceSettings().phoneConnected) {
      dc.drawText(60, _devCenter, Graphics.FONT_SMALL, "B", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // date
    var date = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.day, dateInfo.month]);
    dc.drawText(_devCenter, _devCenter, Graphics.FONT_SMALL, date, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // seconds
    dc.drawText(330, _devCenter, Graphics.FONT_SMALL, dateInfo.sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // recovery time
    dc.drawText(60, 95, Graphics.FONT_SMALL, _dataFields.getRecoveryTime(), Graphics.TEXT_JUSTIFY_CENTER);
    //dc.drawRectangle(20, 95, 85, 45);

    // heart rate
    dc.drawText(330, 95, Graphics.FONT_SMALL, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_CENTER);
    //dc.drawRectangle(300, 95, 65, 50);

    // body battery
    dc.drawText(60, 250, Graphics.FONT_SMALL, _dataFields.getBodyBattery(), Graphics.TEXT_JUSTIFY_CENTER);
    //dc.drawRectangle(20, 250, 85, 45);
    
    // battery
    dc.drawText(330, 250, Graphics.FONT_SMALL, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER);
    //dc.drawRectangle(290, 245, 80, 50);
    
    // steps
    dc.drawText(_devCenter, 325, Graphics.FONT_SMALL, _dataFields.getSteps(), Graphics.TEXT_JUSTIFY_CENTER);
    //dc.drawRectangle(155, 325, 80, 50);
  }

  (:fr255)
  function onUpdate(dc as Dc) as Void {
    //System.println("onUpdate");
    clearScreen(dc);

    if (_hidden) {
      //System.println("low power mode");
      if (_settings.battLogEnabled) {
        _dataFields.getBattery();
      }
      return;
    }
    
    // lines for positioning
    //if (_settings.showGrid) {
      //drawGrid(dc);
    //}

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
            
    // hour
    dc.setColor(_settings.hourColor, 0);
    dc.drawText(_devCenter, 52, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    // minute
    dc.setColor(_settings.minuteColor, 0);
    dc.drawText(_devCenter, 156, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    // phone connected
    if (System.getDeviceSettings().phoneConnected) {
      dc.setColor(_settings.connectColor, 0);
      dc.drawText(40, _devCenter, Graphics.FONT_SMALL, "B", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // date
    dc.setColor(_settings.dateColor, 0);
    var date = Lang.format("$1$ $2$ $3$", [dateInfo.day_of_week, dateInfo.day, dateInfo.month]);
    dc.drawText(_devCenter, _devCenter, Graphics.FONT_SMALL, date, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    if (_lowPwrMode) {
      // battery
      dc.setColor(_settings.battColor, 0);
      dc.drawText(_devCenter, 220, Graphics.FONT_SMALL, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER);
      return;
    }

    // altitude
    dc.setColor(_settings.altitudeColor, 0);
    dc.drawText(_devCenter, 10, Graphics.FONT_SMALL, _dataFields.getAltitude(), Graphics.TEXT_JUSTIFY_CENTER);

    // seconds
    dc.setColor(_settings.secColor, 0);
    dc.drawText(220, _devCenter, Graphics.FONT_SMALL, dateInfo.sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // recovery time
    dc.setColor(_settings.recoveryColor, 0);
    dc.drawText(40, 60, Graphics.FONT_SMALL, _dataFields.getRecoveryTime(), Graphics.TEXT_JUSTIFY_CENTER);

    // heart rate
    dc.setColor(_settings.hrColor, 0);
    dc.drawText(220, 60, Graphics.FONT_SMALL, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_CENTER);

    // body battery
    dc.setColor(_settings.bodyBattColor, 0);
    dc.drawText(40, 165, Graphics.FONT_SMALL, _dataFields.getBodyBattery(), Graphics.TEXT_JUSTIFY_CENTER);
    
    // battery
    dc.setColor(_settings.battColor, 0);
    dc.drawText(220, 165, Graphics.FONT_SMALL, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER);
    
    // steps
    dc.setColor(_settings.stepsColor, 0);
    dc.drawText(_devCenter, 220, Graphics.FONT_SMALL, _dataFields.getSteps(), Graphics.TEXT_JUSTIFY_CENTER);
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

  // for layout position development
  private function drawGrid(dc as Dc) {
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
