import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Complications;

class WatchDelegate extends WatchFaceDelegate {

	function initialize() {
		WatchFaceDelegate.initialize();
	}

  function onPress(clickEvent) as Boolean {
    var coords = clickEvent.getCoordinates();
    var x = coords[0];
    var y = coords[1];
    //System.println("onPress x:" + x + ",y:" + y);

    // dc.drawRectangle(185, 30, 35, 35);
    if (x >= 185 && y >= 30 && x <= 215 && y <= 65) {
      //System.println("launching altitude complication");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_ALTITUDE));
      return true;
    }

    // dc.drawRectangle(300, 100, 35, 35);
    if (x >= 300 && y >= 100 && x <= 335 && y <= 135) {
      //System.println("launching hr complication");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_HEART_RATE));
      return true;
    }

    // dc.drawRectangle(50, 100, 35, 35);
    if (x >= 50 && y >= 100 && x <= 85 && y <= 135) {
      //System.println("launching recovery time complication");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_RECOVERY_TIME));
      return true;
    }

    return false;
  }

  function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) as Void {
    System.println("onPowerBudgetExceeded: Allowed " + powerInfo.executionTimeLimit + " but avg was " + powerInfo.executionTimeAverage);
  }
}
