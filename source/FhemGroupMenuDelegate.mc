import Toybox.WatchUi;
import Toybox.Lang;

// Reagiert auf Auswahl einer Gruppe -> oeffnet die zweite Menueebene
// mit den konkreten Aktionen (z.B. "Zu"/"Auf").
class FhemGroupMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        IdleTimer.reset();
        var group = item.getId() as Dictionary;
        var menu = new FhemActionMenu(group);
        var delegate = new FhemActionMenuDelegate();
        WatchUi.pushView(menu, delegate, WatchUi.SLIDE_LEFT);
    }

}
