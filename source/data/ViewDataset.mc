module data {
    class ViewDataset {
        public var LapNumber;
        public var IsActive;
        public var DistanceInKms;
        public var HeartRate;
        public var PaceInMinsPerKm;
        public var SpeedInKmsPerHour;
        public var ElapsedSeconds;
        public var GpsAccuracy;
        public var Activity;

        function initialize() {
            LapNumber = 0;
            IsActive = false;
            DistanceInKms = 0;
            HeartRate = 0;
            PaceInMinsPerKm = 0;
            SpeedInKmsPerHour = 0;
            ElapsedSeconds = 0;
            GpsAccuracy = null;
            Activity = null;
        }

        function clone() {
            var ret =  new ViewDataset();
            ret.LapNumber = LapNumber;
            ret.IsActive = IsActive;
            ret.DistanceInKms = DistanceInKms;
            ret.HeartRate = HeartRate;
            ret.PaceInMinsPerKm = PaceInMinsPerKm;
            ret.SpeedInKmsPerHour = SpeedInKmsPerHour;
            ret.ElapsedSeconds = ElapsedSeconds;
            ret.GpsAccuracy = GpsAccuracy;
            ret.Activity = Activity;
            return ret;
        }
    }
}
