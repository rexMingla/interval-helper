using Toybox.System;
import Toybox.Lang;

module data {
    class DistanceDto {
        hidden const KmsToMiles = 0.621371;

        public var IntValue as Number;
        public var FractionValue as Number;
        public var Units as String;

        public function initialize(intValue as Number, fractionValue as Number, units as String) {
            IntValue = intValue;
            FractionValue = fractionValue;
            Units = units;
        }

        function toString() as String {
            return Lang.format("$1$.$2$ $3$", [IntValue.format("%d"), FractionValue.format("%d"), Units]);
        }

        function toMetres() as Number {
            if ("km".equals(Units)) {
                var metres = (IntValue + (1.0 * FractionValue / 10)) * 1000;
                return metres;
            }

            var miles = (IntValue + (1.0 * FractionValue / 10));
            return (miles / KmsToMiles) * 1000;
        }

        static function fromString(timeString as String) as DistanceDto {
            var spaceIndex = timeString.find(" ");
            if (spaceIndex == null) {
                return new DistanceDto(1, 0, "km");
            }
            var distance = timeString.substring(0, spaceIndex);
            var dotIndex = distance.find(".");
            if (dotIndex == null) {
                return new DistanceDto(1, 0, "km");
            }
            var intValue = distance.substring(0, dotIndex).toNumber();
            var fractionValue = distance.substring(dotIndex + 1, distance.length()).toNumber();
            var units = timeString.substring(spaceIndex + 1, timeString.length());
            return new DistanceDto(intValue, fractionValue, units);
        }
    }
}