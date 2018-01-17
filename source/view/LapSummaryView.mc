using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Graphics;

module view {
    class LapSummaryView extends Ui.View {
        hidden var mData;
        hidden var mDetails;

        function initialize(data) {
            View.initialize();
            mData = data;
        }

        function onLayout(dc) {
            mDetails = data.PositionDetails.createFromDataContext(dc);
        }

        function onShow() {
            Ui.requestUpdate();
        }

        // Update the view
        function onUpdate(dc) {
            View.onUpdate(dc);

            var labels = mData.Labels.Lap;
            var lapColour = mData.IsActive ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
            dc.setColor(lapColour, Graphics.COLOR_TRANSPARENT);

            var lapLabelString = mData.IsActive ? "On" : "Off";
            var lapNumberString = data.Formatter.getInt(mData.LapNumber);
            drawTextAndData(dc, lapLabelString, lapNumberString, mDetails.CentreColumn, mDetails.TopRow);

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var timeString = data.Formatter.getTimeFromSecs(mData.ElapsedSeconds);
            drawTextAndData(dc, labels.Time, timeString, mDetails.CentreColumn, mDetails.CentreRow);

            var distString = data.Formatter.getFloat(mData.DistanceInKms);
            drawTextAndData(dc, labels.Distance, distString, mDetails.CentreColumn, mDetails.BottomRow);
        }

        private function drawTextAndData(dc, label, data, x, y) {
            dc.drawText(x, y - mDetails.DataHeight / 2, mDetails.LabelFont, label, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, y, mDetails.DataFont, data, Graphics.TEXT_JUSTIFY_CENTER);
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
