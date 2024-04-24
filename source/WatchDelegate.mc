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

    // dc.drawRectangle(devCenter - 26, 90, 52, 40);
    if (x >= 182 && y >= 90 && x <= 234 && y <= 130) {
      //System.println("launching hr complication");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_HEART_RATE));
      return true;
    }
    
    // dc.drawRectangle(70, 294, 70, 40);
    if (x >= 70 && y >= 294 && x <= 140 && y <= 334) {
      //System.println("launching stress complication");
      Complications.exitTo(new Complications.Id(Complications.COMPLICATION_TYPE_STRESS));
      return true;
    }

    return false;
  }

  function onPowerBudgetExceeded(powerInfo as WatchUi.WatchFacePowerInfo) as Void {
    System.println("Power budget exceeded. Allowed " + powerInfo.executionTimeLimit + " but avg was " + powerInfo.executionTimeAverage);
  }
}
