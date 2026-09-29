import Toybox.WatchUi;
import Toybox.Lang;

// Reagiert auf Auswahl einer konkreten Aktion: schickt den FHEM-Befehl
// und zeigt das Ergebnis (OK / Fehler <code>) direkt als Untertitel des
// Menuepunkts an.
class FhemActionMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _pendingItem as WatchUi.MenuItem or Null;

    function initialize() {
        Menu2InputDelegate.initialize();
        _pendingItem = null;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        IdleTimer.reset();
        var action = item.getId() as Dictionary;
        _pendingItem = item;
        item.setSubLabel("sende...");
        WatchUi.requestUpdate();

        FhemCommands.send(
            action.get("device") as String,
            action.get("cmd") as String,
            method(:onResponse)
        );
    }

    function onResponse(responseCode as Number, data as Dictionary or String or Null) as Void {
        if (_pendingItem == null) {
            return;
        }
        if (responseCode == 200) {
            _pendingItem.setSubLabel("     OK");
        } else {
            _pendingItem.setSubLabel("   Fehler " + responseCode.toString());
        }
        WatchUi.requestUpdate();
    }

}
