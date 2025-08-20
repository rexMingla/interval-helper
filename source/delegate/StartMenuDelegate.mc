using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;
import Toybox.Lang;

module delegate {
    // This delegate handles input for the Menu pushed when the user
    // selects the sport
    class StartMenuDelegate extends Ui.MenuInputDelegate {

        private var _controller;

        function initialize() {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onMenuItem(item as Symbol) as Void {
            if (item == :start) {
                _controller.start();
            } else if (item == :select) {
                _controller.onSelectActivity();
            } else if (item == :mode) {
                _controller.onSelectMode();
            }
        }
    }
}