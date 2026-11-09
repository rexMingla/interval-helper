import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.Application;

// This delegate handles input for the Menu pushed when the user
// selects the sport
module delegate {
    class ActivityInputDelegate extends Ui.Menu2InputDelegate {

        private var _controller as Controller;

        function initialize() {
            Menu2InputDelegate.initialize();
            _controller = (Application.getApp() as IntervalApp).getController();
        }

        // Handle the menu input
        function onSelect(item as Ui.MenuItem) as Void {
            _controller.setActivity(item.getId() as Number);
        }
    }
}
