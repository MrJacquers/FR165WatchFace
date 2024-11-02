import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;

class WatchDelegate extends WatchFaceDelegate {

	function initialize() {
		WatchFaceDelegate.initialize();
	}

  function onPress(clickEvent) as Boolean {
    ShowBatteryHistory = false;
    
    var coords = clickEvent.getCoordinates();
    var x = coords[0];
    var y = coords[1];
    //System.println("onPress x:" + x + ",y:" + y);

    // dc.drawRectangle(160, 10, 80, 50);
    if (x >= 160 && y >= 10 && x <= 240 && y <= 60) {
      //System.println("onPress: altitude");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_ALTITUDE));
      return true;
    }

    // dc.drawRectangle(300, 95, 65, 50);
    if (x >= 300 && y >= 95 && x <= 365 && y <= 145) {
      //System.println("onPress: heart rate");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_HEART_RATE));
      return true;
    }

    // dc.drawRectangle(20, 95, 85, 45);
    if (x >= 20 && y >= 95 && x <= 105 && y <= 140) {
      //System.println("onPress: recovery time");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME));
      return true;
    }

    // dc.drawRectangle(20, 250, 85, 45);
    if (x >= 20 && y >= 250 && x <= 105 && y <= 295) {
      //System.println("onPress: body battery");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_BODY_BATTERY));
      return true;
    }

    // dc.drawRectangle(290, 245, 80, 50);
    if (x >= 290 && y >= 245 && x <= 370 && y <= 295) {
      //System.println("onPress: battery");
      ShowBatteryHistory = true;
      return true;
    }

    //dc.drawRectangle(155, 325, 80, 50);
    if (x >= 155 && y >= 325 && x <= 235 && y <= 375) {
      //System.println("onPress: steps");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_STEPS));
      return true;
    }

    return true;
  }

  // Handle a partial update exceeding the power budget.
  function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) as Void {
    System.println("onPowerBudgetExceeded: Allowed " + powerInfo.executionTimeLimit + " but avg was " + powerInfo.executionTimeAverage);
  }
}
