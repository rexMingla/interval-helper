import Toybox.Lang;
import Toybox.Graphics;
using Toybox.System;

module data {
    class PositionDetails {
        public var Height as Number = 0;
        public var Width as Number = 0;
        public var DataHeight as Number = 0;
        public var DataFont as Graphics.FontType = Graphics.FONT_SMALL;
        public var LabelHeight as Number = 0;
        public var LabelFont as Graphics.FontType = Graphics.FONT_XTINY;
        public var DataAndLabelOffset as Number = 0;

        public var LeftColumn as Number = 0;
        public var CentreColumn as Number = 0;
        public var RightColumn as Number = 0;
        public var TopRow as Number = 0;
        public var CentreRow as Number = 0;
        public var BottomRow as Number = 0;

        static function createFromDataContext(dc as Dc) as PositionDetails {
            var useSmallerFonts = needsSmallFont(dc);

            var details = new PositionDetails();
            details.Width = dc.getWidth();
            details.Height = dc.getHeight();
            details.DataFont = useSmallerFonts ? Graphics.FONT_SMALL : Graphics.FONT_NUMBER_MILD;
            details.DataHeight = dc.getFontHeight(details.DataFont);
            details.LabelFont = useSmallerFonts ? Graphics.FONT_XTINY : Graphics.FONT_SMALL;
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

        private static function getLabelOffset(labelHeight as Number, dc as Dc) as Number {
            return labelHeight - getTopOffset(dc) / 10;
        }

        private static function needsSmallFont(dc as Dc) as Boolean {
            // reference: https://developer.garmin.com/connect-iq/user-experience-guide/appendices/
            // hacky way to get 735xt to use larger fonts than the fenix
            return dc.getFontHeight(Graphics.FONT_SMALL) > 19;
        }

        private static function getTopOffset(dc as Dc) as Number {
            if (isShortScreen(dc)) {
                return 25;
            }
            var screenShape = System.getDeviceSettings().screenShape;
            if (screenShape != System.SCREEN_SHAPE_ROUND) {
                return 40;
            }
            // 50px was tuned on 240px round screens (5/24 of the height). On larger round screens a fixed
            // 50px leaves the top and bottom rows too close to the curved edge, so scale it with the
            // screen, never going below the original value.
            var scaled = dc.getHeight() * 5 / 24;
            return scaled > 50 ? scaled : 50;
        }

        private static function isShortScreen(dc as Dc) as Boolean {
            return dc.getHeight() == 148;
        }
    }
}
