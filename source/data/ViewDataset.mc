import Toybox.Lang;
import Toybox.Position;

module data {
    class ViewDataset {
        public var LapNumber as Number = 0;
        public var IsActive as Boolean = false;
        public var Distance as Numeric = 0;
        public var HeartRate as Numeric = 0;
        public var Pace as Numeric = 0;
        public var Speed as Numeric = 0;
        public var ElapsedSeconds as Number = 0;
        public var GpsAccuracy as Position.Quality or Null = null;
        public var Activity as Number = 0;
        public var IsRunning as Boolean = false;

        function initialize() {
        }

        function clone() as ViewDataset {
            var ret = new ViewDataset();
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
