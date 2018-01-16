using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

module delegate {
    class RunningMenuDelegate extends Ui.MenuInputDelegate {

        hidden var mController;

        function initialize() {
            MenuInputDelegate.initialize();
            mController = Application.getApp().controller;
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :resume) {
                mController.resume();
                return true;
            } else if (item == :save) {
                mController.save();
                return true;
            } else {
                mController.discard();
                return true;
            }
            return false;
        }
    }
}