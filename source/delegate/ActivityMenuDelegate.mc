using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;

// This delegate handles input for the Menu pushed when the user
// selects the sport
module delegate {
    class ActivityMenuDelegate extends Ui.MenuInputDelegate {

        hidden var mController;

        function initialize() {
            MenuInputDelegate.initialize();
            mController = Application.getApp().controller;
        }

        // Handle the menu input
        function onMenuItem(item) {
            if (item == :run) {
                mController.setActivity(ActivityRecording.SPORT_RUNNING);
                return true;
            } else if (item == :bike) {
                mController.setActivity(ActivityRecording.SPORT_CYCLING);
                return true;
            } else if (item == :swim) {
                mController.setActivity(ActivityRecording.SPORT_SWIMMING);
                return true;
            } else {
                mController.setActivity(ActivityRecording.SPORT_GENERIC);
                return true;
            }
            return false;
        }
    }
}