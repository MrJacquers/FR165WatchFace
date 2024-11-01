public class Utils {
    static function splitString(string, separator) {
        var tokens = [];

        var found = string.find(separator);

        while (found != null) {
            var token = string.substring(0, found);
            tokens.add(token);
            string = string.substring(found + separator.length(), string.length());
            found = string.find(separator);
        }

        if (string.length() > 0) {
            tokens.add(string);
        }

        return tokens;
    }
}
