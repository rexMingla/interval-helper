import Toybox.Lang;

module data {
    class ViewDataset {
        public var LapNumber as Number;
        public var IsActive as Boolean;
        public var Distance as Double;
        public var HeartRate as Number;
        public var Pace as Double;
        public var Speed as Double;
        public var ElapsedSeconds as Double;
        public var GpsAccuracy as Toybox.Position;
        public var Activity as Toybox.Activity;
        public var IsRunning as Boolean;

        function initialize() {
            LapNumber = 0;
            IsActive = false;
            Distance = 0;
            HeartRate = 0;
            Pace = 0;
            Speed = 0;
            ElapsedSeconds = 0;
            GpsAccuracy = null;
            Activity = null;
            IsRunning = false;
        }

        function clone() {
            var ret =  new ViewDataset();
            ret.LapNumber = LapNumber;
            ret.IsActive = IsActive;
            ret.Distance = Distance;
            ret.HeartRate = HeartRate;
            ret.Pace = Pace;
            ret.Speed = Speed;
            ret.ElapsedSeconds = ElapsedSeconds;
            ret.GpsAccuracy = GpsAccuracy;
            ret.Activity = Activity;
            ret.IsRunning = IsRunning;
            return ret;
        }
    }
}
