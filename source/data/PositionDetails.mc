using Toybox.System;
import Toybox.Lang;
import Toybox.Graphics;

module data {
    class PositionDetails {
        public var Height as Double;
        public var Width as Double;
        public var DataHeight as Double;
        public var DataFont as Double;
        public var LabelHeight as Double;
        public var LabelFont as String;
        public var DataAndLabelOffset as Double;

        public var LeftColumn as Double;
        public var CentreColumn as Double;
        public var RightColumn as Double;
        public var TopRow as Double;
        public var CentreRow as Double;
        public var BottomRow as Double;

        static function createFromDataContext(dc as Dc) as PositionDetails {
            var useSmallerFonts = needsSmallFont(dc);

            var details = new PositionDetails();
            details.Width = dc.getWidth();
            details.Height = dc.getHeight();
            details.DataFont = useSmallerFonts ? dc.FONT_SMALL : dc.FONT_NUMBER_MILD;
            details.DataHeight = dc.getFontHeight(details.DataFont);
            details.LabelFont = useSmallerFonts ? dc.FONT_XTINY : dc.FONT_SMALL;
            details.LabelHeight = dc.getFontHeight(details.LabelFont);
            details.DataAndLabelOffset = getLabelOffset(details.LabelHeight, dc);

            var xOffset = 10;
            details.LeftColumn = details.Width / 3 - xOffset;
            details.RightColumn = 2 * details.Width / 3 + xOffset;
            details.CentreColumn = details.Width / 2;

            details.TopRow = getTopOffset(dc);
            details.BottomRow = details.Height - details.TopRow;
            details.CentreRow = details.Height / 2;
            return details;
        }

        private static function getLabelOffset(labelHeight as String, dc as Dc) as Double {
            return labelHeight - getTopOffset(dc) / 10;
        }

        private static function needsSmallFont(dc as Dc) as Boolean {
            // reference: https://developer.garmin.com/connect-iq/user-experience-guide/appendices/
            // hacky way to get 735xt to use larger fonts than the fenix
            return dc.getFontHeight(dc.FONT_SMALL) > 19;
        }

        private static function getTopOffset(dc as Dc) as Double {
            if (isShortScreen(dc)) {
                return 25;
            }
            var screenShape = System.getDeviceSettings().screenShape;
            return screenShape == System.SCREEN_SHAPE_ROUND ? 50 : 40;
        }

        private static function isShortScreen(dc as Dc) as Boolean {
            return dc.getHeight() == 148;
        }
    }
}