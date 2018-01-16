using Toybox.Lang;

module data {
    class Formatter {
        static function getInt(n) {
            return n.format("%d");
        }

        static function getFloat(n) {
            return n.format("%0.2f");
        }

        static function getPace(kmsPerHour) {
            return getTime(kmsPerHour, ((100 * kmsPerHour) % 100) / 60);
        }

        static function getTimeFromSecs(secs) {
            return getTime(secs / 60, secs % 60);
        }

        static function getTime(hours, mins) {
            return Lang.format("$1$:$2$", [hours.format("%d"), mins.format("%02d")]);
        }
    }
}