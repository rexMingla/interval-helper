import Toybox.Lang;

module data {
    class LapSample {
        public var Seconds as Number;
        public var Metres as Number;

        public function initialize(seconds as Number, metres as Number) {
            Seconds = seconds;
            Metres = metres;
        }
    }
}