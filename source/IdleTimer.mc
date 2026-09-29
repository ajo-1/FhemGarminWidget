import Toybox.Timer;
import Toybox.System;
import Toybox.Lang;

// Bringt die App nach ca. 30 Sekunden ohne Bedienung automatisch
// zum Zifferblatt zurueck (System.exit() beendet das Widget).
// IdleTimer.start() wird beim App-Start aufgerufen, IdleTimer.reset()
// bei jeder Bedienung (Gruppe auswaehlen, Aktion auswaehlen), damit
// der Timer neu beginnt.
//
// "method(:symbol)" funktioniert in Monkey C nur innerhalb einer Klasse
// (braucht ein "self"), deshalb steckt die eigentliche Timer-Logik in
// der Klasse _IdleTimerImpl; das Modul IdleTimer haelt eine einzelne
// Instanz davon und reicht start()/reset() einfach durch.

class _IdleTimerImpl {

    private var _timer as Timer.Timer;

    const TIMEOUT_MS = 30000;

    function initialize() {
        _timer = new Timer.Timer();
    }

    function start() as Void {
        _timer.start(method(:onTimeout), TIMEOUT_MS, false);
    }

    function onTimeout() as Void {
        System.exit();
    }

}

module IdleTimer {

    var _impl as _IdleTimerImpl or Null = null;

    function start() as Void {
        if (_impl == null) {
            _impl = new _IdleTimerImpl();
        }
        _impl.start();
    }

    function reset() as Void {
        start();
    }

}
