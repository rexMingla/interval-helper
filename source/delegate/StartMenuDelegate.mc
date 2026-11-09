import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application;

module delegate {
    // Handles input for the menu shown before the activity starts
    class StartMenuDelegate extends Ui.Menu2InputDelegate {

        private var _controller;

        function initialize() {
            Menu2InputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        function onSelect(item as Ui.MenuItem) as Void {
            var id = item.getId();
            // unlike the legacy Menu, Menu2 does not close itself on selection
            Ui.popView(Ui.SLIDE_DOWN);
            if (id == :start) {
                _controller.start();
            } else if (id == :select) {
                _controller.onSelectActivity();
            } else if (id == :mode) {
                _controller.onSelectMode();
            }
        }
    }
}
