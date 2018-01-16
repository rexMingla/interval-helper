using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

module delegate {
    // This delegate handles input for the Menu pushed when the user
    // selects the sport
    class StartMenuDelegate extends Ui.MenuInputDelegate {

        hidden var mController;

        function initialize() {
            MenuInputDelegate.initialize();
            mController = Application.getApp().controller;
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :start) {
                mController.start();
                return true;
            } else if (item == :select) {
                mController.onSelectActivity();
                return true;
            }
            return false;
        }
    }
}