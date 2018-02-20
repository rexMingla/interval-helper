using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Graphics;

module view {
    class MainView extends Ui.View {
        hidden var _model;
        hidden var _timer;
        hidden var _posDetails;
        hidden var _timeDisplayModulus;

        function initialize() {
            View.initialize();
            _model = Application.getApp().getModel();
            _timer = new Timer.Timer();
            _timeDisplayModulus = System.getDeviceSettings().is24Hour ? 24 : 12;
        }

        function onLayout(dc) {
            _posDetails = data.PositionDetails.createFromDataContext(dc);
        }

        function onShow() {
            _timer.start(method(:onTimer), 1000, true);
        }

        // Update the view
        function onUpdate(dc) {
            View.onUpdate(dc);

            var view = _model.getCurrentView();
            var labels = view == Model.Lap ? data.Labels.Lap : data.Labels.Total;
            var data = view == Model.Lap ? _model.getLapData() : _model.getTotalData();

            var lapLabelString = data.IsActive ? Ui.loadResource(Rez.Strings.lap_on) : Ui.loadResource(Rez.Strings.lap_off);
            var lapNumberString = data.Formatter.getInt(data.LapNumber);
            var paceLabel = getPaceLabel(data.Activity, labels);
            var paceString = getPaceString(data);
            var distString = data.Formatter.get2dpFloat(data.Distance);
            var hrString = data.Formatter.getInt(data.HeartRate);
            var timeString = data.Formatter.getTimeFromSecs(data.ElapsedSeconds);
            var now = System.getClockTime();
            var todString = data.Formatter.getTime(now.hour % _timeDisplayModulus, now.min);

            if (!data.IsRunning) {
                var messageFormat = data.LapNumber == 0 ? Ui.loadResource(Rez.Strings.welcome_format) : Ui.loadResource(Rez.Strings.resume_format);
                var welcomeString = Lang.format(messageFormat, [getGpsAccuracy(data)]);
                dc.setColor(data.GpsAccuracy == Position.QUALITY_GOOD ? Graphics.COLOR_GREEN : Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, welcomeString, "", _posDetails.CentreColumn, _posDetails.TopRow);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                var lapColour = data.IsActive ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
                dc.setColor(lapColour, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, lapLabelString, lapNumberString, _posDetails.LeftColumn, _posDetails.TopRow);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, labels.Distance, distString, _posDetails.RightColumn, _posDetails.TopRow);
            }

            drawTextAndData(dc, paceLabel, paceString, _posDetails.LeftColumn, _posDetails.CentreRow);
            drawTextAndData(dc, labels.Time, timeString, _posDetails.RightColumn, _posDetails.CentreRow);

            drawTextAndData(dc, labels.Hr, hrString, _posDetails.LeftColumn, _posDetails.BottomRow);
            drawTextAndData(dc, labels.TimeOfDay, todString, _posDetails.RightColumn, _posDetails.BottomRow);
        }

        private function drawTextAndData(dc, label, data, x, y) {
            dc.drawText(x, y - _posDetails.DataAndLabelOffset, _posDetails.LabelFont, label, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, y, _posDetails.DataFont, data, Graphics.TEXT_JUSTIFY_CENTER);
        }

        private function getPaceLabel(activity, labels) {
            if (activity == ActivityRecording.SPORT_CYCLING) {
                return labels.Speed;
            }
            if (activity == ActivityRecording.SPORT_SWIMMING) {
                return labels.SwimPace;
            }
            return labels.Pace;
        }

        private function getPaceString(data) {
            if (data.Activity == ActivityRecording.SPORT_CYCLING) {
                return data.Formatter.get1dpFloat(data.Speed);
            }
            var multiplier = data.Activity == ActivityRecording.SPORT_SWIMMING ? 0.1 : 1.0; // swimming is per 100m
            return data.Formatter.getPace(data.Pace * multiplier);
        }

        // Called when this View is removed from the screen. Save the
        // state of this View here. This includes freeing resources from
        // memory.
        function onHide() {
            _timer.stop();
        }

        // Handler for the _timer callback
        function onTimer() {
            Ui.requestUpdate();
        }

        private function getGpsAccuracy(data) {
            if (data.GpsAccuracy == Position.QUALITY_GOOD) {
                return Ui.loadResource(Rez.Strings.gps_good);
            } else if (data.GpsAccuracy == Position.QUALITY_USABLE) {
                return Ui.loadResource(Rez.Strings.gps_ok);
            }
            return Ui.loadResource(Rez.Strings.gps_poor);
        }
    }
}
