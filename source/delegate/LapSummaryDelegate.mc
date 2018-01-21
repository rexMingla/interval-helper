using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording;
using Toybox.Application;

module delegate {
    class LapSummaryDelegate extends Ui.BehaviorDelegate {

        private var _controller;

        function initialize() {
            BehaviorDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        // Input handling of start/stop is mapped to onSelect
        function onSelect() {
            _controller.hideLapSummaryView();
            _controller.onStartStop();
            return true;
        }

        // start lap
        function onBack() {
            _controller.onLap();
            return true;
        }

        // Block access to the menu button
        function onMenu() {
            return true;
        }

        function onNextPage() {
            _controller.hideLapSummaryView();
        }

        function onPreviousPage() {
            _controller.hideLapSummaryView();
        }
    }
}