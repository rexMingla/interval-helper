using Toybox.WatchUi as Ui;
import Toybox.Lang;
import Toybox.Application;

typedef LoadResourceType as Application.ResourceType or Application.ResourceReferenceType;

module data {
    class Labels {
        public var Distance as LoadResourceType;
        public var Hr as LoadResourceType;
        public var Time as LoadResourceType;
        public var Pace as LoadResourceType;
        public var SwimPace as LoadResourceType;
        public var Speed as LoadResourceType;
        public var TimeOfDay as LoadResourceType;

        function initialize(d as LoadResourceType, 
            hr as LoadResourceType, 
            time as LoadResourceType, 
            pace as LoadResourceType, 
            swimPace as LoadResourceType, 
            speed as LoadResourceType) {
            Distance = d;
            Hr = hr;
            Time = time;
            Pace = pace;
            SwimPace = swimPace;
            Speed = speed;
            TimeOfDay = Ui.loadResource(Rez.Strings.view_time_of_day);
        }

        static var Lap as data.Labels = new data.Labels(
            Ui.loadResource(Rez.Strings.view_lap_dist),
            Ui.loadResource(Rez.Strings.view_current_hr),
            Ui.loadResource(Rez.Strings.view_lap_time),
            Ui.loadResource(Rez.Strings.view_current_pace),
            Ui.loadResource(Rez.Strings.view_current_swim_pace),
            Ui.loadResource(Rez.Strings.view_current_speed)
        );
        static var Total as data.Labels = new data.Labels(
            Ui.loadResource(Rez.Strings.view_total_dist),
            Ui.loadResource(Rez.Strings.view_average_hr),
            Ui.loadResource(Rez.Strings.view_total_time),
            Ui.loadResource(Rez.Strings.view_average_pace),
            Ui.loadResource(Rez.Strings.view_average_swim_pace),
            Ui.loadResource(Rez.Strings.view_average_speed)
        );
    }
}