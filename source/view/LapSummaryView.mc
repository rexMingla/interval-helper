using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Graphics;

module view {
    class LapSummaryView extends Ui.View {
        hidden var _data;
        hidden var _posDetails;

        function initialize(data) {
            View.initialize();
            _data = data;
        }

        function onLayout(dc) {
            _posDetails = data.PositionDetails.createFromDataContext(dc);
        }

        function onShow() {
            Ui.requestUpdate();
        }

        // Update the view
        function onUpdate(dc) {
            View.onUpdate(dc);

            var labels = _data.Labels.Lap;
            var lapColour = _data.IsActive ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
            dc.setColor(lapColour, Graphics.COLOR_TRANSPARENT);

            var lapLabelString = _data.IsActive ? Ui.loadResource(Rez.Strings.lap_on) : Ui.loadResource(Rez.Strings.lap_off);
            var lapNumberString = data.Formatter.getInt(_data.LapNumber);
            drawTextAndData(dc, lapLabelString, lapNumberString, _posDetails.CentreColumn, _posDetails.TopRow);

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var timeString = data.Formatter.getTimeFromSecs(_data.ElapsedSeconds);
            drawTextAndData(dc, labels.Time, timeString, _posDetails.CentreColumn, _posDetails.CentreRow);

            var bottomLabelString = _data.IsActive ? labels.Distance : labels.Hr;
            var bottomLabelData = _data.IsActive ? data.Formatter.get2dpFloat(_data.Distance) : data.Formatter.getInt(_data.HeartRate);
            drawTextAndData(dc, bottomLabelString, bottomLabelData, _posDetails.CentreColumn, _posDetails.BottomRow);
        }

        private function drawTextAndData(dc, label, data, x, y) {
            dc.drawText(x, y - _posDetails.DataAndLabelOffset, _posDetails.LabelFont, label, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, y, _posDetails.DataFont, data, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
