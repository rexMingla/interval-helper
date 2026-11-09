import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application;

module delegate {
    class LapSummaryDelegate extends Ui.BehaviorDelegate {

        private var _controller as Controller;

        function initialize() {
            BehaviorDelegate.initialize();
            _controller = (Application.getApp() as IntervalApp).getController();
        }

        // Input handling of start/stop is mapped to onSelect
        function onSelect() as Boolean {
            _controller.hideLapSummaryView();
            _controller.onStartStop();
            return true;
        }

        // start lap
        function onBack() as Boolean {
            _controller.onLap();
            return true;
        }

        // Block access to the menu button
        function onMenu() as Boolean {
            return true;
        }

        function onNextPage() as Boolean {
            _controller.hideLapSummaryView();
            return true;
        }

        function onPreviousPage() as Boolean {
            _controller.hideLapSummaryView();
            return true;
        }
    }
}
