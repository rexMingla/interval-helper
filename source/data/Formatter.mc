import Toybox.Lang;

module data {
    class Formatter {
        static function getInt(n as Numeric) as String {
            return n.format("%d");
        }

        static function get1dpFloat(n as Numeric) as String {
            return n.format("%0.1f");
        }

        static function get2dpFloat(n as Numeric) as String {
            return n.format("%0.2f");
        }

        // 5.17 -> 5:10
        static function getPace(unitPerHour as Numeric) as String {
            var mins = 60 * ((100 * unitPerHour).toNumber() % 100) / 100;
            return getTime(unitPerHour, mins);
        }

        static function getTimeFromSecs(secs as Number) as String {
            return getTime(secs / 60, secs % 60);
        }

        static function getTime(units as Numeric, unitsMod60 as Numeric) as String {
            return Lang.format("$1$:$2$", [units.format("%d"), unitsMod60.format("%02d")]);
        }
    }
}
