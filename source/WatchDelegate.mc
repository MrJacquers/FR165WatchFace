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

    // dc.drawRectangle(200, 270, 90, 50);
    if (x >= 200 && y >= 270 && x <= 290 && y <= 320) {
      //System.println("onPress: battery");
      ShowBatteryHistory = true;
      return true;
    }

    return true;
  }

  // Handle a partial update exceeding the power budget.
  function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) as Void {
    System.println("onPowerBudgetExceeded: Allowed " + powerInfo.executionTimeLimit + " but avg was " + powerInfo.executionTimeAverage);
  }
}
