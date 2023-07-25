using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

// This delegate handles input for the Menu pushed when the user
// selects the sport
module delegate {
    class LapMenuInputDelegate extends Ui.Menu2InputDelegate {

        private var _controller;
        private var _lapEnd as data.LapEnd;

        // replace with lapEnd
        function initialize(lapEnd as data.LapEnd) {
            Menu2InputDelegate.initialize();
            _lapEnd = lapEnd;
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onSelect(item) {
            var trigger = item.getId();
            if (trigger == Model.LapButtonPress) {
                _controller.setLapEnd(new data.LapEnd(_lapEnd.LapType, trigger, null));
                return true;
            }

            if (trigger == Model.TimeElapsed) {
                var defaultValue = _lapEnd.Trigger == trigger ? _lapEnd.Units : "1:30";
                WatchUi.pushView(new delegate.pickers.TimePicker(defaultValue), new delegate.pickers.TimePickerDelegate(_lapEnd.LapType), WatchUi.SLIDE_UP);
                return true;
            }

            if (trigger == Model.DistanceElapsed) {
                var defaultValue = _lapEnd.Trigger == trigger ? _lapEnd.Units : "1 km";
                WatchUi.pushView(new delegate.pickers.DistancePicker(defaultValue), new delegate.pickers.DistancePickerDelegate(_lapEnd.LapType), WatchUi.SLIDE_UP);
                return true;
            }

            return false;
        }
    }
}