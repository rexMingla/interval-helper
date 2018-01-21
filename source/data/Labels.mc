using Toybox.WatchUi as Ui;

module data {
    class Labels {
        public var Distance;
        public var Hr;
        public var Time;
        public var Pace;
        public var Speed;
        public var TimeOfDay;

        function initialize(d, hr, time, pace, speed) {
            Distance = d;
            Hr = hr;
            Time = time;
            Pace = pace;
            Speed = speed;
            TimeOfDay = Ui.loadResource(Rez.Strings.view_time_of_day);
        }

        static var Lap = new data.Labels(
            Ui.loadResource(Rez.Strings.view_lap_dist),
            Ui.loadResource(Rez.Strings.view_current_hr),
            Ui.loadResource(Rez.Strings.view_lap_time),
            Ui.loadResource(Rez.Strings.view_current_pace),
            Ui.loadResource(Rez.Strings.view_current_speed)
        );
        static var Total = new data.Labels(
            Ui.loadResource(Rez.Strings.view_total_dist),
            Ui.loadResource(Rez.Strings.view_average_hr),
            Ui.loadResource(Rez.Strings.view_total_time),
            Ui.loadResource(Rez.Strings.view_average_pace),
            Ui.loadResource(Rez.Strings.view_average_speed)
        );
    }

}