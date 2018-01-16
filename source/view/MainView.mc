using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Lang;
using Toybox.Graphics;

module view {
    class MainView extends Ui.View {
        hidden var mModel;
        hidden var mTimer;
        hidden var mDetails;

        function initialize() {
            View.initialize();
            mModel = Application.getApp().model;
            mTimer = new Timer.Timer();
        }

        function onLayout(dc) {
            mDetails = data.PositionDetails.createFromDataContext(dc);
        }

        function onShow() {
            mTimer.start(method(:onTimer), 1000, true);
        }

        // Update the view
        function onUpdate(dc) {
            View.onUpdate(dc);

            var view = mModel.getCurrentView();
            var labels = view == Model.Lap ? data.Labels.Lap : data.Labels.Total;
            var data = view == Model.Lap ? mModel.getLapData() : mModel.getTotalData();

            var lapLabelString = data.IsActive ? "On" : "Off";
            var lapNumberString = data.Formatter.getInt(data.LapNumber);
            var paceLabel = data.Activity == ActivityRecording.SPORT_CYCLING ? labels.Speed : labels.Pace;
            var paceString = data.Activity == ActivityRecording.SPORT_CYCLING
                ? data.Formatter.getFloat(data.SpeedInKmsPerHour)
                : data.Formatter.getPace(data.PaceInMinsPerKm);
            var distString = data.Formatter.getFloat(data.DistanceInKms);
            var hrString = data.Formatter.getInt(data.HeartRate);
            var timeString = data.Formatter.getTimeFromSecs(data.ElapsedSeconds);
            var now = System.getClockTime();
            var todString = data.Formatter.getTime(now.hour, now.min);

            if (data.LapNumber == 0) {
                var welcomeString = Lang.format("Press Start To Begin\nGPS signal: $1$", [getGpsAccuracy(data)]);
                dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, welcomeString, "", mDetails.CentreColumn, mDetails.TopRow);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                var lapColour = data.IsActive ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
                dc.setColor(lapColour, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, lapLabelString, lapNumberString, mDetails.LeftColumn, mDetails.TopRow);
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                drawTextAndData(dc, labels.Distance, distString, mDetails.RightColumn, mDetails.TopRow);
            }

            drawTextAndData(dc, paceLabel, paceString, mDetails.LeftColumn, mDetails.CentreRow);
            drawTextAndData(dc, labels.Time, timeString, mDetails.RightColumn, mDetails.CentreRow);

            drawTextAndData(dc, "Time", todString, mDetails.LeftColumn, mDetails.BottomRow);
            drawTextAndData(dc, labels.Hr, hrString, mDetails.RightColumn, mDetails.BottomRow);
        }

        private function drawTextAndData(dc, label, data, x, y) {
            dc.drawText(x, y - mDetails.DataHeight / 2, mDetails.LabelFont, label, Graphics.TEXT_JUSTIFY_CENTER);
            if (data != "") {
                dc.drawText(x, y, mDetails.DataFont, data, Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        // Called when this View is removed from the screen. Save the
        // state of this View here. This includes freeing resources from
        // memory.
        function onHide() {
            mTimer.stop();
        }

        // Handler for the timer callback
        function onTimer() {
            Ui.requestUpdate();
        }

        private function getGpsAccuracy(data) {
            if (data.GpsAccuracy == Position.QUALITY_GOOD) {
                return "Good";
            } else if (data.GpsAccuracy == Position.QUALITY_USABLE) {
                return "Ok";
            }
            return "Poor";
        }
    }
}
