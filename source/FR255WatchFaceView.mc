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
  private var _dataFieldLayout;

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

    // example of font height
    //var dim = dc.getTextDimensions("123", Graphics.FONT_SMALL);
    //var h = dc.getFontHeight(Graphics.FONT_SMALL);
    //System.println(dim + " > " + h);

    var dataFieldFont = Graphics.FONT_SMALL;
    var dataFontDim = dc.getTextDimensions("00", dataFieldFont);
    var timeFontDim = dc.getTextDimensions("00", _timeFont);

    // 260x260 devCenter=130
    // horizontal digital layout
    var dateY = _devCenter - timeFontDim[1] / 2 - dataFontDim[1] / 2 - 10;
    var hrY = dateY - dataFontDim[1] - 5;
    var dataY = _devCenter + timeFontDim[1] / 2 + dataFontDim[1] / 2 + 10;
    var battY = dataY + dataFontDim[1] + 10;
    var secY = _devCenter - timeFontDim[1] / 2 - 4;

    _dataFieldLayout = new [10];
    _dataFieldLayout[0] = [_settings.hrColor, _devCenter, hrY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER];
    _dataFieldLayout[1] = [_settings.dateColor, _devCenter, dateY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER];
    _dataFieldLayout[2] = [_settings.connectColor, 20, _devCenter, dataFieldFont, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER];
    _dataFieldLayout[3] = [_settings.hourColor, _devCenter - 5, _devCenter, _timeFont, Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER];
    _dataFieldLayout[4] = [_settings.minuteColor, _devCenter + 5, _devCenter, _timeFont, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER];
    _dataFieldLayout[5] = [_settings.secColor, 235, secY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER];
    _dataFieldLayout[6] = [_settings.bodyBattColor, _devCenter - 70, dataY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER];
    _dataFieldLayout[7] = [_settings.stepsColor, _devCenter, dataY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER];
    _dataFieldLayout[8] = [_settings.timeToRecoveryColor, _devCenter + 70, dataY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER];
    _dataFieldLayout[9] = [_settings.battColor, _devCenter, battY, dataFieldFont, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER];

    // TODO: vertical digital layout
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
      //System.println("hidden");
      return;
    }

    if (_lowPwrMode) {
      //System.println("low power mode");
      if (_settings.colorTest) {
        drawTestPattern(dc, true);
        return;
      }
    }

    //System.println("drawing");
    clearScreen(dc);

    // lines for positioning
    //if (_settings.showGrid) {
    //drawGrid(dc);
    //}

    // Get the date info, the strings will be localized.
    var dateInfo = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);

    drawDataField(dc, _dataFieldLayout[1], _dataFields.getDate(dateInfo));
    drawDataField(dc, _dataFieldLayout[3], dateInfo.hour.format("%02d"));
    drawDataField(dc, _dataFieldLayout[4], dateInfo.min.format("%02d"));

    if (System.getDeviceSettings().phoneConnected) {
      drawDataField(dc, _dataFieldLayout[2], "B");
    }

    if (!_lowPwrMode) {
      drawDataField(dc, _dataFieldLayout[0], _dataFields.getHeartRate());
      drawDataField(dc, _dataFieldLayout[5], dateInfo.sec.format("%02d"));
      drawDataField(dc, _dataFieldLayout[6], _dataFields.getBodyBattery());
      drawDataField(dc, _dataFieldLayout[7], _dataFields.getSteps());
      drawDataField(dc, _dataFieldLayout[8], _dataFields.getTimeToRecovery());
    }

    _dataFieldLayout[9][2] = _lowPwrMode ? 190 : 230;
    drawDataField(dc, _dataFieldLayout[9], _dataFields.getBattery());
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

  function drawDataField(dc, info as Array, text) {
    dc.setColor(info[0], _settings.bgColor);
    dc.drawText(info[1], info[2], info[3], text, info[4]);
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

  function drawTestPattern(dc, horizontal) {
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
    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }

  // The user has just looked at their watch. Timers and animations may be started here.
  function onExitSleep() as Void {
    //System.println("onExitSleep");
    _lowPwrMode = false;
    //_dataFields.subscribeStress();
    //WatchUi.requestUpdate(); // not really required, onUpdate will be called anyway.
  }
}
