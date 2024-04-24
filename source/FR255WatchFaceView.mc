import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class FR255WatchFaceView extends WatchUi.WatchFace {  
  private var _devSize;
  private var _devCenter;
  private var _timeFont;
  //private var _blanked = false;
  private var _hidden;
  private var _lowPwrMode;
  private var _settings;
  private var _dataFields;
  
  function initialize() {
    //System.println("view initialize");
    WatchFace.initialize();
    
    _settings = new Settings();
    loadSettings();
    
    _dataFields = new DataFields();
    _dataFields.registerComplications();
    _dataFields.battLogEnabled = _settings.battLogEnabled;
  }

  function loadSettings() {
    _settings.loadSettings();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    //System.println("onLayout");
    _devSize = dc.getWidth();
    _devCenter = _devSize / 2;
    _timeFont = WatchUi.loadResource(Rez.Fonts.id_monofonto_outline);
  }

  // Called when this View is brought to the foreground.
  // Restore the state of this View and prepare it to be shown.
  // This includes loading resources into memory.
  function onShow() as Void {
    //System.println("onShow");
    //_settings.loadSettings();
    _hidden = false;
    _lowPwrMode = false;
    _dataFields.subscribeStress();
  }

  // Updates the View.
  // Called every second in high power mode, e.g. after a gesture, for +- 5 seconds.
  // Called once a minute in low power mode.
  function onUpdate(dc as Dc) as Void {
    //System.print("onUpdate: ");

    if (_hidden) {
        return;
    }

    if (_lowPwrMode) {
      //System.println("low power mode");      
      if (_settings.battLogEnabled) {
        _dataFields.getBattery();
      }
      return;
    }

    //System.println("drawing");
    clearScreen(dc);

    // lines for positioning
    //if (_settings.showGrid) {
      //drawGrid(dc);
    //}

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    drawHR(dc);
    drawDate(dc, dateInfo);
    drawConnectionStatus(dc);
    drawHour(dc, dateInfo);
    drawMinutes(dc, dateInfo);
    if (!_lowPwrMode) {
        drawSeconds(dc, dateInfo.sec);
    }
    drawStress(dc);
    drawSteps(dc);
    drawTemperature(dc);
    drawBattery(dc);
  }

  private function clearScreen(dc as Dc) {
    dc.setColor(0, _settings.bgColor);
    dc.clear();
  }

  function drawHR(dc) {
    dc.setColor(_settings.hrColor, -1);
    dc.drawText(_devCenter, 35, Graphics.FONT_TINY, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawDate(dc, dateInfo as Gregorian.Info) {
    dc.setColor(_settings.dateColor, -1);
    dc.drawText(_devCenter, 70, Graphics.FONT_TINY, _dataFields.getDate(dateInfo), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawConnectionStatus(dc) {
    dc.setColor(_settings.connectColor, -1);
    var cs = System.getDeviceSettings().phoneConnected ? "B" : "";
    dc.drawText(24, _devCenter, Graphics.FONT_TINY, cs, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawHour(dc, dateInfo as Gregorian.Info) {
    dc.setColor(_settings.hourColor, -1);
    dc.drawText(120, _devCenter, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawMinutes(dc, dateInfo as Gregorian.Info) {
    dc.setColor(_settings.minuteColor, -1);
    dc.drawText(140, _devCenter, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawSeconds(dc, sec) {
    dc.setColor(_settings.secColor, -1);
    dc.drawText(236, 94, Graphics.FONT_TINY, sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
  }

  function drawStress(dc) {
    dc.setColor(_settings.stressColor, -1);
    dc.drawText(60, 190, Graphics.FONT_TINY, _dataFields.getStress(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawSteps(dc) {
    dc.setColor(_settings.stepsColor, -1);
    dc.drawText(_devCenter, 190, Graphics.FONT_TINY, _dataFields.getSteps(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawTemperature(dc) {
    dc.setColor(_settings.tempColor, -1);
    dc.drawText(200, 190, Graphics.FONT_TINY, _dataFields.getTemperature(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawBattery(dc) {
    dc.setColor(_settings.battColor, -1);
    dc.drawText(_devCenter, 230, Graphics.FONT_TINY, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  // for layout position debugging
  private function drawGrid(dc as Dc) {
    var i = 0;
    var step = 16;

    dc.setColor(Graphics.COLOR_DK_GRAY, -1);
    do {
      i += step;      
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
    _dataFields.unsubscribeStress();
  }

  // Terminate any active timers and prepare for slow updates (once a minute).
  function onEnterSleep() as Void {
    //System.println("onEnterSleep");    
    _lowPwrMode = true;
    _dataFields.unsubscribeStress();
    //_blanked = false;
    //WatchUi.requestUpdate();
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    //System.println("onExitSleep");
    _lowPwrMode = false;
    _dataFields.subscribeStress();
    //WatchUi.requestUpdate();
  }
}
