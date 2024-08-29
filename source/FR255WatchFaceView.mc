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
  private var _dataFieldLayout as Array;
  private var _rowSize;
  private var _colSize;
  private var _canBurnIn = false;

  function initialize() {
    //System.println("view initialize");
    WatchFace.initialize();

    _settings = new Settings();
    loadSettings();

    _dataFieldLayout = new [10];
    _dataFields = new DataFields();
    //_dataFields.registerComplications();
    _dataFields.battLogEnabled = _settings.battLogEnabled;

    /*if (Toybox.WatchUi.WatchFace has :onPartialUpdate) {
      System.println("onPartialUpdate available");
    }*/

    var deviceSettings = System.getDeviceSettings();
    if(deviceSettings has :requiresBurnInProtection) {
      _canBurnIn = deviceSettings.requiresBurnInProtection;
      System.println("Can Burn In" + _canBurnIn);
    }
  }

  function loadSettings() {
    _settings.loadSettings();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    //System.println("onLayout");
    // FR255 260x260 devCenter=130
    // FR255 218x218 devCenter=109
    _devSize = dc.getWidth();
    _devCenter = _devSize / 2;
    _rowSize = _devSize / 8.0;
    _colSize = _devSize / 8.0;
    _timeFont = WatchUi.loadResource(Rez.Fonts.id_rajdhani_bold_mono);

    // example of font height
    //var dim = dc.getTextDimensions("123", Graphics.FONT_SMALL);
    //var h = dc.getFontHeight(Graphics.FONT_SMALL);
    //System.println(dim + " > " + h);

    var dataFieldFont = Graphics.FONT_SMALL;
    var timeFontDim = dc.getTextDimensions("00", _timeFont);

    if (_settings.layoutType == 0) {
      // horizontal layout
      var dataY = _rowSize * 6;
      var secX = _devSize - (_devSize < 220 ? 16 : 32);
      var secY = _devCenter - (timeFontDim[1] / 2) - 4;

      _dataFieldLayout[0] = [_devCenter, _rowSize, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // heart rate
      _dataFieldLayout[1] = [_devCenter, _rowSize * 2, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // date
      _dataFieldLayout[2] = [24, _devCenter, dataFieldFont, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER]; // connection status
      _dataFieldLayout[3] = [_devCenter - 2, _devCenter, _timeFont, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER]; // hour
      _dataFieldLayout[4] = [_devCenter + 2, _devCenter, _timeFont, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER]; // minute
      _dataFieldLayout[5] = [secX, secY, Graphics.FONT_SYSTEM_TINY, Graphics.TEXT_JUSTIFY_CENTER]; // seconds
      _dataFieldLayout[6] = [_rowSize * 2, dataY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // body battery
      _dataFieldLayout[7] = [_devCenter, dataY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // steps
      _dataFieldLayout[8] = [_rowSize * 6, dataY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // time to recovery
      _dataFieldLayout[9] = [_devCenter, _rowSize * 7 + 5, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // battery
    } 
    
    if (_settings.layoutType == 1) {
      // vertical layout
      _dataFieldLayout[0] = [_colSize * 6.5, _devCenter, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // heart rate
      _dataFieldLayout[1] = [_devCenter, _rowSize, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // date
      _dataFieldLayout[2] = [_colSize * 1.5, _rowSize * 2.5, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // connection status
      _dataFieldLayout[3] = [_devCenter, _devCenter - timeFontDim[1] - 3, _timeFont, Graphics.TEXT_JUSTIFY_CENTER]; // hour
      _dataFieldLayout[4] = [_devCenter, _devCenter + 2, _timeFont, Graphics.TEXT_JUSTIFY_CENTER]; // minute
      _dataFieldLayout[5] = [_colSize * 6.5, _rowSize * 2.5, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // seconds
      _dataFieldLayout[6] = [_colSize * 1.5, _rowSize * 5.5, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // body battery
      _dataFieldLayout[7] = [_colSize * 1.5, _devCenter, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // steps
      _dataFieldLayout[8] = [_colSize * 6.5, _rowSize * 5.5, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // time to recovery
      _dataFieldLayout[9] = [_devCenter, _rowSize * 7, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER]; // battery
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
    //_dataFields.subscribeStress();
  }

  // Updates the View.
  // Called every second in high power mode, e.g. after a gesture, for +- 5 seconds.
  // Called once a minute in low power mode.
  function onUpdate(dc as Dc) as Void {
    //System.print("onUpdate: ");
    clearScreen(dc);

    if (_hidden) {
      //System.println("hidden");
      return;
    }

    if (_lowPwrMode && _canBurnIn) {
      //System.println("low power mode");
      return;
    }

    if (_settings.colorTest) {
      drawColorPattern(dc, true);
      return;
    }

    //System.println("drawing");

    // lines for positioning
    //if (_settings.showGrid) {
    //drawGrid(dc);
    //}

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    drawDataField(dc, _dataFields.getDate(dateInfo), _dataFieldLayout[1], _settings.dateColor);
    drawDataField(dc, dateInfo.hour.format("%02d"), _dataFieldLayout[3], _settings.hourColor);
    drawDataField(dc, dateInfo.min.format("%02d"), _dataFieldLayout[4], _settings.minuteColor);

    if (System.getDeviceSettings().phoneConnected) {
      drawDataField(dc, "B", _dataFieldLayout[2], _settings.connectColor);
    }

    if (!_lowPwrMode) {
      drawDataField(dc, _dataFields.getHeartRate(), _dataFieldLayout[0], _settings.hrColor);
      drawDataField(dc, dateInfo.sec.format("%02d"), _dataFieldLayout[5], _settings.secColor);
      drawDataField(dc, _dataFields.getBodyBattery(), _dataFieldLayout[6], _settings.bodyBattColor);
      drawDataField(dc, _dataFields.getSteps(), _dataFieldLayout[7], _settings.stepsColor);
      drawDataField(dc, _dataFields.getTimeToRecovery(), _dataFieldLayout[8], _settings.timeToRecoveryColor);
    }

    drawDataField(dc, _dataFields.getBattery(), _dataFieldLayout[9], _settings.battColor);
  }

  (:debug)
  private function clearScreen(dc as Dc) {
    dc.setColor(0, _settings.bgColor);
    dc.clear();
  }

  (:release)
  private function clearScreen(dc as Dc) {
    // no need for this on actual device.
  }

  function drawDataField(dc as Dc, text as String, info as Array, color as Number) {
    dc.setColor(color, _settings.bgColor);
    dc.drawText(info[0], info[1], info[2], text, info[3]);
  }

  // for layout position debugging
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

  function drawColorPattern(dc, horizontal) {
    var _colors = [
      Graphics.COLOR_WHITE,
      Graphics.COLOR_LT_GRAY,
      Graphics.COLOR_DK_GRAY,
      Graphics.COLOR_RED,
      Graphics.COLOR_DK_RED,
      Graphics.COLOR_ORANGE,
      Graphics.COLOR_YELLOW,
      Graphics.COLOR_GREEN,
      Graphics.COLOR_DK_GREEN,
      Graphics.COLOR_BLUE,
      Graphics.COLOR_DK_BLUE,
      Graphics.COLOR_PURPLE,
      Graphics.COLOR_PINK,
    ];

    var pos = 0;
    var gapSize = 2;
    var colorSize = _colors.size();
    var barSize = (_devSize - colorSize * gapSize) / colorSize;

    for (var i = 0; i < colorSize; i++) {
      dc.setColor(_colors[i], 0);

      if (horizontal) {
        dc.fillRectangle(0, pos, _devSize, barSize);
      } else {
        dc.fillRectangle(pos, 0, barSize, _devSize);
      }

      pos += barSize + gapSize;
    }
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

    if (_settings.layoutType == 0 && !_canBurnIn) {
      // battery y pos for horizontal
      _dataFieldLayout[9][1] = _rowSize * 6;
    }

    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    //System.println("onExitSleep");
    _lowPwrMode = false;
    //_dataFields.subscribeStress();

    if (_settings.layoutType == 0 && !_canBurnIn) {
      // battery y pos for horizontal
      _dataFieldLayout[9][1] = _rowSize * 7 + 5;
    }

    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }
}
