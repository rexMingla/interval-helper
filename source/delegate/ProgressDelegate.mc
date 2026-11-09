//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Lang;
using Toybox.WatchUi;

module delegate {
    // This handles input while the progress bar is up
    class ProgressDelegate extends WatchUi.BehaviorDelegate {

        function initialize() {
            BehaviorDelegate.initialize();
        }

        function onBack() as Boolean {
            return true;
        }
    }
}
