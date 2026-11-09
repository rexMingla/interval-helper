import Toybox.Lang;
import Toybox.Graphics;
import Toybox.Math;
using Toybox.System;

module data {
    // Where each label/value pair is drawn. Values are the y of the top of the data text; the label
    // is drawn DataAndLabelOffset above it.
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

            if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                layoutRound(details, dc);
            } else {
                layoutRectangular(details, dc);
            }
            return details;
        }

        // Round screens: the outer corners of the top and bottom rows must stay inside the circle, so the
        // inset is worked out from the circle rather than being a fixed number of pixels. The result is
        // close to the values hand-tuned for 240px screens and scales to any size.
        private static function layoutRound(details as PositionDetails, dc as Dc) as Void {
            var colOffset = details.Width / 24;
            details.LeftColumn = details.Width / 3 - colOffset;
            details.RightColumn = 2 * details.Width / 3 + colOffset;
            details.CentreColumn = details.Width / 2;
            details.DataAndLabelOffset = details.LabelHeight - details.Height / 48;

            // horizontal extent of the outermost text: column distance from centre plus half a typical value
            var textHalfWidth = dc.getTextWidthInPixels("00:00", details.DataFont) / 2;
            var extent = details.RightColumn - details.CentreColumn + textHalfWidth;
            var radius = (details.Width < details.Height ? details.Width : details.Height) / 2;
            var maxExtent = radius * 9 / 10;
            if (extent > maxExtent) {
                extent = maxExtent;
            }
            // distance from the top of the screen to where the circle is wide enough for that extent
            var inset = (radius - Math.sqrt(radius * radius - extent * extent)).toNumber();

            // top pair starts at the inset, bottom pair ends at the inset, centre pair is centred
            var offset = details.DataAndLabelOffset;
            details.TopRow = inset + offset;
            details.BottomRow = details.Height - inset - details.DataHeight;
            details.CentreRow = details.Height / 2 - (details.DataHeight - offset) / 2;
        }

        // Rectangular and semi-round screens have no curve to avoid, so keep the fixed margins.
        private static function layoutRectangular(details as PositionDetails, dc as Dc) as Void {
            var xOffset = 10;
            details.LeftColumn = details.Width / 3 - xOffset;
            details.RightColumn = 2 * details.Width / 3 + xOffset;
            details.CentreColumn = details.Width / 2;

            var topOffset = dc.getHeight() == 148 ? 25 : 40;
            details.DataAndLabelOffset = details.LabelHeight - topOffset / 10;
            details.TopRow = topOffset;
            details.BottomRow = details.Height - topOffset;
            details.CentreRow = details.Height / 2;
        }

        private static function needsSmallFont(dc as Dc) as Boolean {
            // reference: https://developer.garmin.com/connect-iq/user-experience-guide/appendices/
            // hacky way to get 735xt to use larger fonts than the fenix
            return dc.getFontHeight(Graphics.FONT_SMALL) > 19;
        }
    }
}
