import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Position;
using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;
using Toybox.System;

module view {
    class MainView extends Ui.View {
        hidden var _model as Model;
        hidden var _timer as Timer.Timer = new Timer.Timer();
        hidden var _posDetails as data.PositionDetails or Null = null;
        hidden var _timeDisplayModulus as Number;

        function initialize() {
            View.initialize();
            _model = (Application.getApp() as IntervalApp).getModel();
            _timeDisplayModulus = System.getDeviceSettings().is24Hour ? 24 : 12;
        }

        function onLayout(dc as Dc) as Void {
            _posDetails = data.PositionDetails.createFromDataContext(dc);
        }

        function onShow() as Void {
            _timer.start(method(:onTimer), 1000, true);
        }

        // Update the view
        function onUpdate(dc as Dc) as Void {
            View.onUpdate(dc);

            var pos = _posDetails;
            if (pos == null) {
                return;
            }

            var currentView = _model.getCurrentView();
            var labels = currentView == Model.Lap ? data.Labels.Lap : data.Labels.Total;
            var dataset = currentView == Model.Lap ? _model.getLapData() : _model.getTotalData();

            var lapLabelString = Ui.loadResource(dataset.IsActive ? Rez.Strings.lap_on : Rez.Strings.lap_off) as String;
            var lapNumberString = data.Formatter.getInt(dataset.LapNumber);
            var paceLabel = getPaceLabel(dataset.Activity, labels);
            var paceString = getPaceString(dataset);
            var distString = data.Formatter.get2dpFloat(dataset.Distance);
            var hrString = data.Formatter.getInt(dataset.HeartRate);
            var timeString = data.Formatter.getTimeFromSecs(dataset.ElapsedSeconds);
            var now = System.getClockTime();
            var todString = data.Formatter.getTime(now.hour % _timeDisplayModulus, now.min);

            if (!dataset.IsRunning) {
                var messageFormat = Ui.loadResource(dataset.LapNumber == 0 ? Rez.Strings.welcome_format : Rez.Strings.resume_format) as String;
                var welcomeString = Lang.format(messageFormat, [getGpsAccuracy(dataset)]);
                dc.setColor(dataset.GpsAccuracy == Position.QUALITY_GOOD ? Graphics.COLOR_GREEN : Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, pos, welcomeString, "", pos.CentreColumn, pos.TopRow);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                var lapColour = dataset.IsActive ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
                dc.setColor(lapColour, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, pos, lapLabelString, lapNumberString, pos.LeftColumn, pos.TopRow);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, pos, labels.Distance, distString, pos.RightColumn, pos.TopRow);
            }

            drawTextAndData(dc, pos, paceLabel, paceString, pos.LeftColumn, pos.CentreRow);
            drawTextAndData(dc, pos, labels.Time, timeString, pos.RightColumn, pos.CentreRow);

            drawTextAndData(dc, pos, labels.Hr, hrString, pos.LeftColumn, pos.BottomRow);
            drawTextAndData(dc, pos, labels.TimeOfDay, todString, pos.RightColumn, pos.BottomRow);
        }

        private function drawTextAndData(dc as Dc, pos as data.PositionDetails, label as String, value as String, x as Number, y as Number) as Void {
            dc.drawText(x, y - pos.DataAndLabelOffset, pos.LabelFont, label, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, y, pos.DataFont, value, Graphics.TEXT_JUSTIFY_CENTER);
        }

        private function getPaceLabel(activity as Number, labels as data.Labels) as String {
            if (activity == Model.SPORT_CYCLING) {
                return labels.Speed;
            }
            if (activity == Model.SPORT_SWIMMING) {
                return labels.SwimPace;
            }
            return labels.Pace;
        }

        private function getPaceString(dataset as data.ViewDataset) as String {
            if (dataset.Activity == Model.SPORT_CYCLING) {
                return data.Formatter.get1dpFloat(dataset.Speed);
            }
            var multiplier = dataset.Activity == Model.SPORT_SWIMMING ? 0.1 : 1.0; // swimming is per 100m
            return data.Formatter.getPace(dataset.Pace * multiplier);
        }

        // Called when this View is removed from the screen. Save the
        // state of this View here. This includes freeing resources from
        // memory.
        function onHide() as Void {
            _timer.stop();
        }

        // Handler for the _timer callback
        function onTimer() as Void {
            Ui.requestUpdate();
        }

        private function getGpsAccuracy(dataset as data.ViewDataset) as String {
            if (dataset.GpsAccuracy == Position.QUALITY_GOOD) {
                return Ui.loadResource(Rez.Strings.gps_good) as String;
            } else if (dataset.GpsAccuracy == Position.QUALITY_USABLE) {
                return Ui.loadResource(Rez.Strings.gps_ok) as String;
            }
            return Ui.loadResource(Rez.Strings.gps_poor) as String;
        }
    }
}
