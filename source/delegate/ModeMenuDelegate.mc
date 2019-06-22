using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

// This delegate handles input for the Menu pushed when the user
// selects the mode
module delegate {
    class ModeMenuDelegate extends Ui.MenuInputDelegate {

        private var _controller;

        function initialize() {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :record) {
                _controller.setOffLapRecordingMode(true);
                return true;
            } else if (item == :norecord) {
                _controller.setOffLapRecordingMode(false);
                return true;
            }
            return false;
        }
    }
}