module data {
    class PositionDetails {
        var Height;
        var Width;
        var DataHeight;
        var DataFont;
        var LabelFont;

        var LeftColumn;
        var CentreColumn;
        var RightColumn;
        var TopRow;
        var CentreRow;
        var BottomRow;

        static function createFromDataContext(dc) {
            var details = new PositionDetails();
            details.Width = dc.getWidth();
            details.Height = dc.getHeight();
            details.DataFont = dc.FONT_NUMBER_MILD;
            details.DataHeight = dc.getFontHeight(details.DataFont);
            details.LabelFont = dc.FONT_SMALL;
            details.LeftColumn = details.Width / 3;
            details.RightColumn = 2 * details.Width / 3;
            details.CentreColumn = details.Width / 2;
            details.TopRow = 30;
            details.BottomRow = details.Height - details.TopRow;
            details.CentreRow = details.Height / 2;
            return details;
        }
    }
}