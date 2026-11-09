import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application;

module delegate {
    // Handles input for the menu shown when the activity is paused
    class RunningMenuDelegate extends Ui.Menu2InputDelegate {

        private var _controller;

        function initialize() {
            Menu2InputDelegate.initialize();
            _controller = Application.getApp().getController();
        }

        function onSelect(item as Ui.MenuItem) as Void {
            var id = item.getId();
            // unlike the legacy Menu, Menu2 does not close itself on selection
            Ui.popView(Ui.SLIDE_DOWN);
            if (id == :resume) {
                _controller.start();
            } else if (id == :save) {
                _controller.save();
            } else {
                _controller.discard();
            }
        }
    }
}
