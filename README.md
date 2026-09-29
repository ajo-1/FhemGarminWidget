# FHEM-Steuerung für Garmin Venu 4 (Connect IQ Widget)

Ersatz für die alte, unbenutzte "FHEM App" (GarminFhem) von Talkabout, die
die Venu 4 noch nicht unterstützt. Dieses Widget bietet dieselben Aktionen
wie deine bisherige Konfiguration:

- Rolladen Alle / Hinten / EG / Schlafzimmer (Zu/Auf)
- Drucker, Zisterne, Druck (An/Aus)
- Gastherme (An/Aus)

Es unterstützt **HTTP Basic Auth** direkt (dein `openvas.home.2cv-6.de`
verlangt ja eine Anmeldung) – Benutzername/Passwort werden sicher über
die normalen Connect-IQ-App-Einstellungen eingetragen (genau wie bei
APICall), nicht im Quellcode.

## Voraussetzungen

- Garmin Connect IQ SDK (aktuelle Version, mit Venu-4-Unterstützung)
- VS Code mit der "Monkey C" Extension (empfohlen) **oder** Eclipse mit
  Connect-IQ-Plugin
- Ein Connect-IQ-Entwickler-Account auf https://apps.garmin.com/developer

## Einrichtung

1. **Neues Projekt anlegen**: In VS Code über die Kommandopalette
   `Monkey C: New Project` wählen, Typ **Widget**, Template **Blank**,
   als Zielgerät **Venu 4** auswählen. Das erzeugt automatisch ein
   passendes `manifest.xml`, `monkey.jungle` und die Ordnerstruktur mit
   der für deine SDK-Version korrekten Geräte-ID für "venu4".

2. **Dateien ersetzen/ergänzen**: Kopiere aus diesem Projekt die Ordner
   `source/` und `resources/` in dein neu angelegtes Projekt (die
   generierten Platzhalter-Dateien wie `HelloWorldApp.mc` etc. kannst du
   löschen). Übernimm aus meiner `manifest.xml` nur die Zeilen
   `<iq:permissions><iq:uses-permission id="Communications"/></iq:permissions>`
   und ggf. die Produktliste – die App-ID (`id="..."`) und
   `minSdkVersion` lässt du so, wie sie dein Projekt-Assistent erzeugt
   hat.

3. **App im Developer-Bereich anlegen**: Auf
   https://apps.garmin.com/developer eine neue App erstellen (Typ
   Widget). Die dort vergebene App-ID trägst du in `manifest.xml` als
   `id="..."` ein, bevor du das finale Paket baust.

4. **Bauen**: Über die Monkey C Extension "Build for Device" (Zielgerät
   Venu 4) ausführen, das erzeugt eine `.prg`- bzw. für den Store eine
   `.iq`-Datei.

5. **Testen (Sideload)**: `.prg`-Datei per USB in den `GARMIN/APPS`-Ordner
   der Uhr kopieren, oder über den Simulator testen, bevor du im
   Developer-Bereich hochlädst.

6. **Einstellungen setzen**: Nach der Installation auf der Uhr (oder via
   Garmin Express/Connect Mobile, genau wie bei APICall) folgende
   App-Einstellungen ausfüllen:
   - **FHEM-URL**: `https://openvas.home.2cv-6.de/fhem`
   - **Benutzername** / **Passwort**: deine Basic-Auth-Zugangsdaten
   - **FHEM CSRF-Token**: `csrf_01234567890123456` (oder dein aktueller,
     falls du ihn zwischenzeitlich geändert hast)

## Bedienung auf der Uhr

Widget öffnen → Gruppe wählen (z.B. "Drucker") → Aktion wählen (z.B.
"An") → Untertitel zeigt "sende...", danach "OK" oder "Fehler <Code>".

## Geräte/Befehle anpassen (ohne neu zu bauen!)

Die Liste der Geräte/Befehle ist **keine feste Codeliste mehr**, sondern eine
normale App-Einstellung ("Geraete/Befehle") – du kannst sie also jederzeit in
Garmin Express oder der Garmin-Connect-App ändern, ohne die App neu zu bauen
oder hochzuladen, genau wie URL/Benutzer/Passwort/CSRF.

Format (ein Eintrag pro Zeile/Aktion, mit `;` getrennt):

```
Gruppe|Beschriftung|FHEM-Geraet|Befehl;Gruppe|Beschriftung|FHEM-Geraet|Befehl;...
```

Beispiel für zwei Aktionen in der Gruppe "Drucker":

```
Drucker|An|MQTT2_zigbee_Power_drucker|on;Drucker|Aus|MQTT2_zigbee_Power_drucker|off
```

Aktionen mit derselben Gruppe werden automatisch zusammengefasst (Reihenfolge
= Reihenfolge im Text). Zum Umsortieren einfach die Textstücke im Feld
verschieben; zum Hinzufügen ein weiteres `Gruppe|Label|Geraet|Befehl` per `;`
anhängen. Ist das Feld leer oder fehlerhaft, nutzt die App automatisch die
eingebaute Standardliste (deine ursprüngliche Konfiguration), damit nie
"nichts" passiert.

Die Rohliste (falls du sie mal direkt im Code brauchst oder zurücksetzen
willst) steht weiterhin als Fallback in `source/FhemData.mc`.

## Dateien in diesem Paket

```
manifest.xml                      – Basis-Manifest (Permissions, Produkte)
monkey.jungle                     – Jungle-Datei
resources/strings/strings.xml     – Texte (App-Name, Einstellungs-Labels)
resources/settings/properties.xml – App-Einstellungen (URL/User/Pass/CSRF)
resources/drawables/drawables.xml – Icon-Deklaration
resources/drawables/launcher_icon.png – einfaches Platzhalter-Icon
source/FhemApp.mc                 – App-Einstiegspunkt
source/FhemData.mc                – Geräte-/Befehlsliste (hier anpassen!)
source/FhemCommands.mc            – HTTP-Request inkl. Basic Auth
source/FhemGroupMenu.mc           – 1. Menüebene (Gruppen)
source/FhemGroupMenuDelegate.mc   – Klick-Logik 1. Ebene
source/FhemActionMenu.mc          – 2. Menüebene (Aktionen)
source/FhemActionMenuDelegate.mc  – Klick-Logik 2. Ebene, sendet Befehl
```
