using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

// This delegate handles input for the Menu pushed when the user
// selects the mode
module delegate {
    class ModeInputDelegate extends Ui.Menu2InputDelegate {

        private var _controller;

        function initialize() {
            Menu2InputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onSelect(item) {
            var id = item.getId();
            if (id == :record) {
                _controller.setOffLapRecordingMode(true);
                return true;
            } else if (id == :norecord) {
                _controller.setOffLapRecordingMode(false);
                return true;
            }
            return false;
        }

        function onWrap(key) {
            return true; // wrap ok
        }
    }
}