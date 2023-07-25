using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

module delegate {
    class RunningMenuDelegate extends Ui.MenuInputDelegate {

        private var _controller;

        function initialize() {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :resume) {
                _controller.start();
                return true;
            } else if (item == :save) {
                _controller.save();
                return true;
            } else if (item == :auto_lap_off) {
                _controller.turnOffAutoLap();
                return true;
            } else {
                _controller.discard();
                return true;
            }
            return false;
        }
    }
}