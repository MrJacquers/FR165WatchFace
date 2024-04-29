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
  
  function initialize() {
    //System.println("view initialize");
    WatchFace.initialize();
    
    _settings = new Settings();
    loadSettings();
    
    _dataFields = new DataFields();
    //_dataFields.registerComplications();
    _dataFields.battLogEnabled = _settings.battLogEnabled;

    /*if (Toybox.WatchUi.WatchFace has :onPartialUpdate) {
      System.println("onPartialUpdate available");
    }*/
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
    //_dataFields.subscribeStress();
  }

  // Updates the View.
  // Called every second in high power mode, e.g. after a gesture, for +- 5 seconds.
  // Called once a minute in low power mode.
  function onUpdate(dc as Dc) as Void {
    //System.print("onUpdate: ");

    if (_hidden) {
      // I haven't seen this message and don't think it will ever be shown.
      dc.drawText(_devCenter, _devCenter, Graphics.FONT_MEDIUM, "Hidden", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
      return;
    }

    if (_lowPwrMode) {
      //System.println("low power mode");
      if (_settings.colorTest) {
        var colors = [Graphics.COLOR_WHITE, Graphics.COLOR_LT_GRAY, Graphics.COLOR_DK_GRAY,
                      Graphics.COLOR_RED, Graphics.COLOR_DK_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW,
                      Graphics.COLOR_GREEN, Graphics.COLOR_DK_GREEN, Graphics.COLOR_BLUE, Graphics.COLOR_DK_BLUE,
                      Graphics.COLOR_PURPLE, Graphics.COLOR_PINK];
        var y = 3;
        for (var i=0; i < colors.size(); i++) {
          y += 15;
          dc.setColor(colors[i], -1);
          dc.fillRectangle(0, y, _devSize, 15);
          y += 3;
        }      
        return;
      }
    }

    //System.println("drawing");
    //clearScreen(dc); // no need for this on actual device.

    // lines for positioning
    //if (_settings.showGrid) {
      //drawGrid(dc);
    //}

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    drawDate(dc, dateInfo);
    drawHour(dc, dateInfo);
    drawMinutes(dc, dateInfo);
    drawConnectionStatus(dc);
    if (!_lowPwrMode) {
      drawHR(dc);
      drawSeconds(dc, dateInfo.sec);
      drawBodyBattery(dc);
      drawSteps(dc);
      drawTimeToRecovery(dc);
    }
    drawBattery(dc);
  }

  private function clearScreen(dc as Dc) {
    dc.setColor(0, _settings.bgColor);
    dc.clear();
  }

  function drawHR(dc) {
    dc.setColor(_settings.hrColor, _settings.bgColor);
    dc.drawText(_devCenter, 35, Graphics.FONT_SMALL, _dataFields.getHeartRate(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawDate(dc, dateInfo as Gregorian.Info) {
    dc.setColor(_settings.dateColor, _settings.bgColor);
    dc.drawText(_devCenter, 70, Graphics.FONT_SMALL, _dataFields.getDate(dateInfo), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawConnectionStatus(dc) {
    if (System.getDeviceSettings().phoneConnected) {
      dc.setColor(_settings.connectColor, _settings.bgColor);    
      dc.drawText(24, _devCenter, Graphics.FONT_SMALL, "B", Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
    }
  }

  function drawHour(dc, dateInfo as Gregorian.Info) {
    dc.setColor(_settings.hourColor, _settings.bgColor);
    dc.drawText(125, _devCenter, _timeFont, dateInfo.hour.format("%02d"), Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawMinutes(dc, dateInfo as Gregorian.Info) {
    dc.setColor(_settings.minuteColor, _settings.bgColor);
    dc.drawText(135, _devCenter, _timeFont, dateInfo.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawSeconds(dc, sec as Number) {
    dc.setColor(_settings.secColor, _settings.bgColor);
    dc.drawText(235, 92, Graphics.FONT_SMALL, sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
  }

  function drawBodyBattery(dc) {
    dc.setColor(_settings.bodyBattColor, _settings.bgColor);
    dc.drawText(60, 190, Graphics.FONT_SMALL, _dataFields.getBodyBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawStress(dc) {
    dc.setColor(_settings.stressColor, _settings.bgColor);
    dc.drawText(60, 190, Graphics.FONT_SMALL, _dataFields.getStress(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawSteps(dc) {
    dc.setColor(_settings.stepsColor, _settings.bgColor);
    dc.drawText(_devCenter, 190, Graphics.FONT_SMALL, _dataFields.getSteps(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawTimeToRecovery(dc) {
    dc.setColor(_settings.timeToRecoveryColor, _settings.bgColor);
    dc.drawText(200, 190, Graphics.FONT_SMALL, _dataFields.getTimeToRecovery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }

  function drawBattery(dc) {
    dc.setColor(_settings.battColor, _settings.bgColor);
    dc.drawText(_devCenter, _lowPwrMode ? 190 : 230, Graphics.FONT_SMALL, _dataFields.getBattery(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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
    //_dataFields.unsubscribeStress();
  }

  // Terminate any active timers and prepare for slow updates (once a minute).
  function onEnterSleep() as Void {
    //System.println("onEnterSleep");    
    _lowPwrMode = true;
    //_dataFields.unsubscribeStress();
    //WatchUi.requestUpdate();
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    //System.println("onExitSleep");
    _lowPwrMode = false;
    //_dataFields.subscribeStress();
    //WatchUi.requestUpdate();
  }
}
