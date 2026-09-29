import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class FhemApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary or Null) as Void {
        IdleTimer.start();
    }

    function onStop(state as Dictionary or Null) as Void {
    }

    // Startansicht: Liste der Geraete-Gruppen (Rolladen Alle, Drucker, ...)
    function getInitialView() as [WatchUi.Views] or [WatchUi.Views, WatchUi.InputDelegates] {
        var menu = new FhemGroupMenu();
        var delegate = new FhemGroupMenuDelegate();
        return [menu, delegate] as [WatchUi.Views, WatchUi.InputDelegates];
    }

}
