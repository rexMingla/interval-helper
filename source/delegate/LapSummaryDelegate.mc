using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording;
using Toybox.Application;

module delegate {
    class LapSummaryDelegate extends Ui.BehaviorDelegate {
        private var mController;

        function initialize() {
            BehaviorDelegate.initialize();
            mController = Application.getApp().controller;
        }

        // Input handling of start/stop is mapped to onSelect
        function onSelect() {
            mController.hideLapSummaryView();
            mController.onStartStop();
            return true;
        }

        // start lap
        function onBack() {
            mController.onLap();
            return true;
        }

        // Block access to the menu button
        function onMenu() {
            return true;
        }

        function onNextPage() {
            mController.hideLapSummaryView();
        }

        function onPreviousPage() {
            mController.hideLapSummaryView();
        }
    }
}