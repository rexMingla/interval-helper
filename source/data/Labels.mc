import Toybox.Lang;
using Toybox.WatchUi as Ui;

module data {
    class Labels {
        public var Distance as String;
        public var Hr as String;
        public var Time as String;
        public var Pace as String;
        public var SwimPace as String;
        public var Speed as String;
        public var TimeOfDay as String;

        function initialize(d as String, hr as String, time as String, pace as String, swimPace as String, speed as String) {
            Distance = d;
            Hr = hr;
            Time = time;
            Pace = pace;
            SwimPace = swimPace;
            Speed = speed;
            TimeOfDay = Ui.loadResource(Rez.Strings.view_time_of_day) as String;
        }

        static var Lap as Labels = new data.Labels(
            Ui.loadResource(Rez.Strings.view_lap_dist) as String,
            Ui.loadResource(Rez.Strings.view_current_hr) as String,
            Ui.loadResource(Rez.Strings.view_lap_time) as String,
            Ui.loadResource(Rez.Strings.view_current_pace) as String,
            Ui.loadResource(Rez.Strings.view_current_swim_pace) as String,
            Ui.loadResource(Rez.Strings.view_current_speed) as String
        );
        static var Total as Labels = new data.Labels(
            Ui.loadResource(Rez.Strings.view_total_dist) as String,
            Ui.loadResource(Rez.Strings.view_average_hr) as String,
            Ui.loadResource(Rez.Strings.view_total_time) as String,
            Ui.loadResource(Rez.Strings.view_average_pace) as String,
            Ui.loadResource(Rez.Strings.view_average_swim_pace) as String,
            Ui.loadResource(Rez.Strings.view_average_speed) as String
        );
    }

}
