using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

module delegate {
    // This delegate handles input for the Menu pushed when the user
    // selects the sport
    class StartMenuDelegate extends Ui.MenuInputDelegate {

        private var _controller as Controller;

        function initialize() {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :start) {
                _controller.start();
                return true;
            } else if (item == :select) {
                _controller.onSelectActivity();
                return true;
            } else if (item == :mode) {
                _controller.onSelectMode();
                return true;
            } else if (item == :lapOff) {
                _controller.onSelectLapEnd(Model.LapOff);
                return true;
            } else if (item == :lapOn) {
                _controller.onSelectLapEnd(Model.LapOn);
                return true;
            }
            return false;
        }
    }
}