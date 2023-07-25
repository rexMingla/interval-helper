using Toybox.Lang;

module data {
    class LapEnd {
        public var Trigger;
        public var LapType;
        // seconds for time
        // metres for distance?
        public var Units;

        public function initialize(lapType, trigger, units) {
            LapType = lapType;
            Trigger = trigger != null ? trigger : Model.LapButtonPress;
            Units = units;
        }

        public function toDisplay() {
            var lapType = LapType == Model.LapOn ? "on" : "off";
            return Lang.format("$1$ $2$", [lapType, Units]);
        }

        private function triggerString() {
            return Trigger == Model.LapButtonPress ? "manual" : Units;
        }
    }
}