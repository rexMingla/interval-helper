//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module delegate {
    module pickers {

        class DistancePicker extends WatchUi.Picker {
            //! Constructor
            public function initialize(timeString) {
                var distance = data.DistanceDto.fromString(timeString);

                var title = new WatchUi.Text({:text=>"x.y mi|km", :locX=>WatchUi.LAYOUT_HALIGN_CENTER,
                    :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
                var factories;
                factories = new Array<PickerFactory or WatchUi.Text>[4];
                factories[0] = new delegate.pickers.NumberFactory(0, 10, 1, {});
                factories[1] = new WatchUi.Text({:text=> ".", :font=>Graphics.FONT_MEDIUM, 
                    :locX=>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER, :color=>Graphics.COLOR_WHITE});
                factories[2] = new delegate.pickers.NumberFactory(0, 9, 1, {});
                factories[3] = new delegate.pickers.WordFactory(["mi", "km"], {:font=>Graphics.FONT_MEDIUM});

                var defaults = new Array<Number or Number>[factories.size()];
                defaults[0] = (factories[0] as NumberFactory).getIndex(distance.IntValue);
                defaults[2] = (factories[2] as NumberFactory).getIndex(distance.FractionValue);
                defaults[3] = (factories[3] as NumberFactory).getIndex(distance.Units);

                Picker.initialize({:title=>title, :pattern=>factories, :defaults=>defaults});
            }

            //! Update the view
            //! @param dc Device Context
            public function onUpdate(dc as Dc) as Void {
                dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
                dc.clear();
                Picker.onUpdate(dc);
            }
        }

        //! Responds to a time picker selection or cancellation
        class DistancePickerDelegate extends WatchUi.PickerDelegate {

            private var _controller;
            private var _lapType;

            public function initialize(lapType) {
                PickerDelegate.initialize();
                _lapType = lapType;
                _controller = Application.getApp().getController();
            }

            //! Handle a cancel event from the picker
            //! @return true if handled, false otherwise
            public function onCancel() as Boolean {
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                return true;
            }

            //! Handle a confirm event from the picker
            //! @param values The values chosen in the picker
            //! @return true if handled, false otherwise
            public function onAccept(values as Array) as Boolean {
                var intValue = values[0] as Number;
                var decimalValue = values[2] as Number;
                if (intValue == 0 && decimalValue == 0) {
                    // can't be zero
                    return false;
                }
                var units = values[3] as String;

                var formattedValue = new data.DistanceDto(intValue, decimalValue, units).toString();
                _controller.setLapEnd(new data.LapEnd(_lapType, Model.DistanceElapsed, formattedValue));

                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
                return true;
            }

        }
    }
}