import Toybox.Lang;
import Toybox.Application;

// Zentrale Liste aller steuerbaren FHEM-Geraete/Gruppen.
//
// Die Liste wird aus der App-Einstellung "fhemActionsConfig" gelesen (siehe
// resources/settings/properties.xml), damit du Geraete, Befehle und die
// Reihenfolge aendern kannst, OHNE die App neu zu bauen -- einfach die
// Einstellung in Garmin Express / Garmin Connect bearbeiten.
//
// Format (ein Eintrag pro Aktion, mit ";" getrennt):
//   Gruppe|Beschriftung|FHEM-Geraet|Befehl;Gruppe|Beschriftung|FHEM-Geraet|Befehl;...
//
// Beispiel:
//   Drucker|An|MQTT2_zigbee_Power_drucker|on;Drucker|Aus|MQTT2_zigbee_Power_drucker|off
//
// Aktionen mit gleicher "Gruppe" werden automatisch zusammengefasst (in der
// Reihenfolge, in der sie zuerst auftauchen). Ist die Einstellung leer oder
// fehlerhaft, wird die eingebaute Standardliste (deine urspruengliche
// Konfiguration) verwendet, damit die App immer funktioniert.
module FhemData {

    function getGroups() as Array<Dictionary> {
        var raw = Application.Properties.getValue("fhemActionsConfig");
        if (raw == null || !(raw instanceof String) || (raw as String).equals("")) {
            return getDefaultGroups();
        }

        var groups = parseConfig(raw as String);
        if (groups.size() == 0) {
            return getDefaultGroups();
        }
        return groups;
    }

    // Zerlegt den Konfig-String in Gruppen/Aktionen. Ungueltige oder
    // unvollstaendige Eintraege werden einfach uebersprungen.
    function parseConfig(raw as String) as Array<Dictionary> {
        var groups = [] as Array<Dictionary>;
        var groupIndex = {} as Dictionary;

        var records = splitString(raw, ";");
        for (var i = 0; i < records.size(); i += 1) {
            var rec = records[i];
            if (rec.equals("")) {
                continue;
            }

            var fields = splitString(rec, "|");
            if (fields.size() < 4) {
                continue;
            }

            var groupLabel = fields[0];
            var label = fields[1];
            var device = fields[2];
            var cmd = fields[3];

            var idx = groupIndex.get(groupLabel);
            if (idx == null) {
                groups.add({
                    "label"   => groupLabel,
                    "actions" => [] as Array<Dictionary>
                });
                idx = groups.size() - 1;
                groupIndex.put(groupLabel, idx);
            }

            var actions = groups[idx as Number].get("actions") as Array<Dictionary>;
            actions.add({
                "label"  => label,
                "device" => device,
                "cmd"    => cmd
            });
        }

        return groups;
    }

    // Kleiner, abhaengigkeitsfreier String-Split (Monkey C hat kein
    // eingebautes String.split).
    function splitString(str as String, sep as String) as Array<String> {
        var result = [] as Array<String>;
        var rest = str;
        var idx = rest.find(sep);
        while (idx != null) {
            result.add(rest.substring(0, idx as Number) as String);
            rest = rest.substring((idx as Number) + sep.length(), rest.length()) as String;
            idx = rest.find(sep);
        }
        result.add(rest);
        return result;
    }

    // Eingebaute Standardliste (= deine urspruengliche Konfiguration), falls
    // die Einstellung leer ist oder nicht gelesen werden kann.
    function getDefaultGroups() as Array<Dictionary> {
        return [
            {
                "label" => "Rolladen Alle",
                "actions" => [
                    { "label" => "Zu",  "device" => "MQTT2_zigbee_Rolladen_all", "cmd" => "close" },
                    { "label" => "Auf", "device" => "MQTT2_zigbee_Rolladen_all", "cmd" => "open"  }
                ]
            },
            {
                "label" => "Rolladen Hinten",
                "actions" => [
                    { "label" => "Zu",  "device" => "MQTT2_zigbee_Rolladen_hinten", "cmd" => "close" },
                    { "label" => "Auf", "device" => "MQTT2_zigbee_Rolladen_hinten", "cmd" => "open"  }
                ]
            },
            {
                "label" => "Rolladen EG",
                "actions" => [
                    { "label" => "Zu",  "device" => "MQTT2_zigbee_Rolladen_EG", "cmd" => "close" },
                    { "label" => "Auf", "device" => "MQTT2_zigbee_Rolladen_EG", "cmd" => "open"  }
                ]
            },
            {
                "label" => "Rolladen Schlafzimmer",
                "actions" => [
                    { "label" => "Zu",  "device" => "MQTT2_zigbee_Rol_Schlafzimmer", "cmd" => "close" },
                    { "label" => "Auf", "device" => "MQTT2_zigbee_Rol_Schlafzimmer", "cmd" => "open"  }
                ]
            },
            {
                "label" => "Drucker",
                "actions" => [
                    { "label" => "An",  "device" => "MQTT2_zigbee_Power_drucker", "cmd" => "on"  },
                    { "label" => "Aus", "device" => "MQTT2_zigbee_Power_drucker", "cmd" => "off" }
                ]
            },
            {
                "label" => "Zisterne",
                "actions" => [
                    { "label" => "An",  "device" => "MQTT2_zigbee_Power_zisterne", "cmd" => "on"  },
                    { "label" => "Aus", "device" => "MQTT2_zigbee_Power_zisterne", "cmd" => "off" }
                ]
            },
            {
                "label" => "Druck",
                "actions" => [
                    { "label" => "An",  "device" => "MQTT2_zigbee_Power_Druck", "cmd" => "on"  },
                    { "label" => "Aus", "device" => "MQTT2_zigbee_Power_Druck", "cmd" => "off" }
                ]
            },
            {
                "label" => "Gastherme",
                "actions" => [
                    { "label" => "An",  "device" => "ESPEasy_Gastherme_gastherme", "cmd" => "on"  },
                    { "label" => "Aus", "device" => "ESPEasy_Gastherme_gastherme", "cmd" => "off" }
                ]
            }
        ] as Array<Dictionary>;
    }

}
