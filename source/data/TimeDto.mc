using Toybox.System;
import Toybox.Lang;

module data {
    class TimeDto {
        public var Minutes as Number;
        public var Seconds as Number;

        public function initialize(minutes as Number, seconds as Number) {
            Minutes = minutes;
            Seconds = seconds;
        }

        function toString() as String {
            return data.Formatter.getTime(Minutes, Seconds);
        }

        function toSeconds() as Number {
            return Minutes * 60 + Seconds;
        }

        static function fromString(timeString as String) as DistanceDto {
            var index = timeString.find(":");
            if (index == null) {
                // 1 min
                return new TimeDto(1, 0);
            }
            var mins = timeString.substring(0, index).toNumber();
            var seconds = timeString.substring(index + 1, timeString.length()).toNumber();

            return new TimeDto(mins, seconds);
        }
    }
}
