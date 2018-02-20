module data {
    class ViewDataset {
        public var LapNumber;
        public var IsActive;
        public var Distance;
        public var HeartRate;
        public var Pace;
        public var Speed;
        public var ElapsedSeconds;
        public var GpsAccuracy;
        public var Activity;
        public var IsRunning;

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
