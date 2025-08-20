using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;
import Toybox.Lang;

module delegate {
    class RunningMenuDelegate extends Ui.MenuInputDelegate {

        private var _controller;

        function initialize() {
            MenuInputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Handle the menu input
        function onMenuItem(item as Symbol) as Void {
            if (item == :resume) {
                _controller.start();
            } else if (item == :save) {
                _controller.save();
            } else {
                _controller.discard();
            }
        }
    }
}