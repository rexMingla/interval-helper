using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording;
using Toybox.Application;

module delegate {
    class MainDelegate extends Ui.BehaviorDelegate {
        private var mController;

        function initialize() {
            BehaviorDelegate.initialize();
            mController = Application.getApp().controller;
        }

        // Input handling of start/stop is mapped to onSelect
        function onSelect() {
            mController.onStartStop();
            return true;
        }

        // start lap
        function onBack() {
            if (!mController.hasStarted()) {
                mController.onExit();
                return true;
            }
            if (!mController.isRunning()) {
                return false;
            }
            mController.onLap();
            return true;
        }

        // Block access to the menu button
        function onMenu() {
            return true;
        }

        function onNextPage() {
            mController.cycleView(1);
        }

        function onPreviousPage() {
            mController.cycleView(-1);
        }
    }
}