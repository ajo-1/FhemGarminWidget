import Toybox.Communications;
import Toybox.Application;
import Toybox.Lang;
import Toybox.StringUtil;

// Baut die FHEM-URL/den Request zusammen und schickt ihn ab.
// Liest Basis-URL, Benutzername/Passwort (HTTP Basic Auth) und den
// FHEM-CSRF-Token aus den App-Einstellungen (siehe resources/settings/properties.xml).
module FhemCommands {

    function send(device as String, cmd as String, callback as Method) as Void {
        var baseUrl = Application.Properties.getValue("fhemBaseUrl") as String;
        var user    = Application.Properties.getValue("fhemUser") as String;
        var pass    = Application.Properties.getValue("fhemPass") as String;
        var csrf    = Application.Properties.getValue("fhemCsrf") as String;

        var params = {
            "cmd"    => "set " + device + " " + cmd,
            "XHR"    => "1",
            "fwcsrf" => csrf
        } as Dictionary;

        var headers = {
            "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
        } as Dictionary;
        if (user != null && !user.equals("")) {
            headers.put("Authorization", "Basic " + StringUtil.encodeBase64(user + ":" + pass));
        }

        var options = {
            :method       => Communications.HTTP_REQUEST_METHOD_GET,
            :headers      => headers,
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
        } as Dictionary;

        Communications.makeWebRequest(baseUrl, params, options, callback);
    }

}
