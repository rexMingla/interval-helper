import Toybox.Lang;
import Toybox.Graphics;
using Toybox.WatchUi as Ui;

module view {
    class LapSummaryView extends Ui.View {
        hidden var _data as data.ViewDataset;
        hidden var _posDetails as data.PositionDetails or Null = null;

        function initialize(dataset as data.ViewDataset) {
            View.initialize();
            _data = dataset;
        }

        function onLayout(dc as Dc) as Void {
            _posDetails = data.PositionDetails.createFromDataContext(dc);
        }

        function onShow() as Void {
            Ui.requestUpdate();
        }

        // Update the view
        function onUpdate(dc as Dc) as Void {
            View.onUpdate(dc);

            var pos = _posDetails;
            if (pos == null) {
                return;
            }

            var labels = data.Labels.Lap;
            var lapColour = _data.IsActive ? Graphics.COLOR_GREEN : Graphics.COLOR_RED;
            dc.setColor(lapColour, Graphics.COLOR_TRANSPARENT);

            var lapLabelString = Ui.loadResource(_data.IsActive ? Rez.Strings.lap_on : Rez.Strings.lap_off) as String;
            var lapNumberString = data.Formatter.getInt(_data.LapNumber);
            drawTextAndData(dc, pos, lapLabelString, lapNumberString, pos.CentreColumn, pos.TopRow);

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var timeString = data.Formatter.getTimeFromSecs(_data.ElapsedSeconds);
            drawTextAndData(dc, pos, labels.Time, timeString, pos.CentreColumn, pos.CentreRow);

            var bottomLabelString = _data.IsActive ? labels.Distance : labels.Hr;
            var bottomLabelData = _data.IsActive ? data.Formatter.get2dpFloat(_data.Distance) : data.Formatter.getInt(_data.HeartRate);
            drawTextAndData(dc, pos, bottomLabelString, bottomLabelData, pos.CentreColumn, pos.BottomRow);
        }

        private function drawTextAndData(dc as Dc, pos as data.PositionDetails, label as String, value as String, x as Number, y as Number) as Void {
            dc.drawText(x, y - pos.DataAndLabelOffset, pos.LabelFont, label, Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(x, y, pos.DataFont, value, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
