import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class FR255WatchFaceView extends WatchUi.WatchFace {
  private var _devSize;
  private var _devCenter;
  private var _timeFont;
  private var _hidden;
  private var _lowPwrMode;
  private var _settings;
  private var _dataFields;
  private var _rowSize;
  private var _canBurnIn;

  function initialize() {
    //System.println("view initialize");
    WatchFace.initialize();

    _settings = new Settings();
    loadSettings();
    
    _dataFields = new DataFields();
    //_dataFields.registerComplications();
    _dataFields.battLogEnabled = _settings.battLogEnabled;

    var deviceSettings = System.getDeviceSettings();
    if (deviceSettings has :requiresBurnInProtection) {
      _canBurnIn = deviceSettings.requiresBurnInProtection;
    }
  }

  function loadSettings() {
    _settings.loadSettings();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    //System.println("onLayout");

    _devSize = dc.getWidth();
    _devCenter = _devSize / 2;
    _rowSize = _devSize / 20.0;

    if (_settings.timeFont == 0) {
      _timeFont = WatchUi.loadResource(Rez.Fonts.id_rajdhani_bold_mono);
    } else {
      _timeFont = WatchUi.loadResource(Rez.Fonts.id_monofonto_bold_mono);
    }
  }

  // Called when this View is brought to the foreground.
  // Restore the state of this View and prepare it to be shown.
  // This includes loading resources into memory.
  function onShow() as Void {
    //System.println("onShow");
    //_settings.loadSettings();
    _hidden = false;
    _lowPwrMode = false;
    //_dataFields.subscribeToComplications();
  }

  // Updates the View:
  // Called once a minute in low power mode.
  // Called every second in high power mode, e.g. after a gesture, for a couple of seconds.
  function onUpdate(dc as Dc) as Void {
    //System.print("onUpdate: ");
    clearScreen(dc);

    if (_hidden) {
      //System.println("hidden");
      //if (_settings.battLogEnabled) {
      //  _dataFields.getBattery();
      //}
      return;
    }

    if (_lowPwrMode && _canBurnIn) {
      //System.println("low power mode");
      //if (_settings.battLogEnabled) {
      //  _dataFields.getBattery();
      //}
      return;
    }

    // lines for positioning
    //if (_settings.showGrid) {
    //drawGrid(dc);
    //}

    //System.println("drawing");

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
    
    dc.setColor(_settings.textColor, _settings.bgColor);

    // altitude
    dc.drawText(_devCenter, 25, Graphics.FONT_TINY, _dataFields.getAltitude(), Graphics.TEXT_JUSTIFY_CENTER);
    //dc.drawRectangle(185, 30, 35, 35);

    // hour
    dc.drawText(_devCenter, 77, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    // minute
    dc.drawText(_devCenter, 233, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

    // phone connected
    if (System.getDeviceSettings().phoneConnected) {
      dc.drawText(70, _devCenter, Graphics.FONT_TINY, "B", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // date
    dc.drawText(_devCenter, _devCenter, Graphics.FONT_TINY, _dataFields.getDate(dateInfo), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // seconds
    dc.drawText(320, _devCenter, Graphics.FONT_TINY, dateInfo.sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    // recovery time
    dc.drawText(70, 100, Graphics.FONT_TINY, _dataFields.getRecoveryTime(), Graphics.TEXT_JUSTIFY_CENTER);
    //dc.drawRectangle(50, 100, 35, 35);

    // body battery
    dc.drawText(70, 260, Graphics.FONT_TINY, _dataFields.getBodyBattery(), Graphics.TEXT_JUSTIFY_CENTER);

    // heart rate
    dc.drawText(320, 100, Graphics.FONT_TINY, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_CENTER);
    //dc.drawRectangle(300, 100, 35, 35);
    
    // battery
    dc.drawText(320, 260, Graphics.FONT_TINY, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER);
    
    // steps
    dc.drawText(_devCenter, 335, Graphics.FONT_TINY, _dataFields.getSteps(), Graphics.TEXT_JUSTIFY_CENTER);
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

    dc.setColor(Graphics.COLOR_DK_GRAY, -1);
    do {
      i += _rowSize;
      dc.drawLine(0, i, _devSize, i); // horizontal line
      dc.drawLine(i, 0, i, _devSize); // vertical line
      //dc.drawCircle(_devCenter,_devCenter,i);  // x,y,r
    } while (i < _devSize);

    i = _devCenter;
    dc.setColor(Graphics.COLOR_LT_GRAY, -1);
    dc.drawLine(0, i, _devSize, i); // horizontal line
    dc.drawLine(i, 0, i, _devSize); // vertical line
  }
  
  // Called when this View is removed from the screen. Save the state of this View here.
  // This includes freeing resources from memory.
  function onHide() as Void {
    //System.println("onHide");
    _hidden = true;
    //_dataFields.unsubscribeFromComplications();
  }

  // Terminate any active timers and prepare for slow updates (once a minute).
  function onEnterSleep() as Void {
    //System.println("onEnterSleep");
    _lowPwrMode = true;
    //_dataFields.unsubscribeFromComplications();
    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    //System.println("onExitSleep");
    _lowPwrMode = false;
    //_dataFields.subscribeToComplications();
    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }
}
