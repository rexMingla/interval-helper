module data {
    class Labels {
        var Distance;
        var Hr;
        var Time;
        var Pace;
        var Speed;

        function initialize(d, hr, time, pace, speed) {
            Distance = d;
            Hr = hr;
            Time = time;
            Pace = pace;
            Speed = speed;
        }

        static var Lap = new data.Labels("Lap Dist", "Curr HR", "Lap Time", "Curr Pace", "Curr Speed");
        static var Total = new data.Labels("Total Dist", "Avg HR", "Total Time", "Avg Pace", "Avg Speed");
    }

}