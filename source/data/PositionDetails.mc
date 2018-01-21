using Toybox.System;

module data {
    class PositionDetails {
        public var Height;
        public var Width;
        public var DataHeight;
        public var DataFont;
        public var LabelHeight;
        public var LabelFont;
        public var DataAndLabelOffset;

        public var LeftColumn;
        public var CentreColumn;
        public var RightColumn;
        public var TopRow;
        public var CentreRow;
        public var BottomRow;

        static function createFromDataContext(dc) {
            // hacky way to get 735xt to use larger fonts than the fenix
            // reference: https://developer.garmin.com/connect-iq/user-experience-guide/appendices/
            var useSmallerFonts = dc.getFontHeight(dc.FONT_SMALL) > 19;

            var details = new PositionDetails();
            details.Width = dc.getWidth();
            details.Height = dc.getHeight();
            details.DataFont = useSmallerFonts ? dc.FONT_SMALL : dc.FONT_NUMBER_MILD;
            details.DataHeight = dc.getFontHeight(details.DataFont);
            details.LabelFont = useSmallerFonts ? dc.FONT_XTINY : dc.FONT_SMALL;
            details.LabelHeight = dc.getFontHeight(details.LabelFont);
            details.DataAndLabelOffset = details.LabelHeight - 5;

            var yOffset = 10;
            details.LeftColumn = details.Width / 3 - yOffset;
            details.RightColumn = 2 * details.Width / 3 + yOffset;
            details.CentreColumn = details.Width / 2;

            details.TopRow = getTopOffset();
            details.BottomRow = details.Height - details.TopRow;
            details.CentreRow = details.Height / 2;
            return details;
        }

        private static function getTopOffset() {
            var screenShape = System.getDeviceSettings().screenShape;
            return screenShape == System.SCREEN_SHAPE_ROUND ? 50 : 40;
        }
    }
}