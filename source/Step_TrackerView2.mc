import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Timer;

class Step_TrackerView2 extends WatchUi.View {

    var Roboto_medium;
    var Roboto_small;
    var start_icon;
    var stop_icon;
    var feedback_timer;
    var feedback_text = "";

    function initialize() {
        View.initialize();
        feedback_timer = new Timer.Timer();
    }

    function onLayout(dc) {
        start_icon = WatchUi.loadResource(Rez.Drawables.StartIcon);
        stop_icon = WatchUi.loadResource(Rez.Drawables.StopIcon);
        Roboto_medium = WatchUi.loadResource(Rez.Fonts.MediumFont);
        Roboto_small = WatchUi.loadResource(Rez.Fonts.SmallFont);
    }

    function onShow() {
        Application.getApp().setSelectedIndex(0);
        WatchUi.requestUpdate();
    }

    function showFeedback(text) {
        feedback_text = text;
        feedback_timer.start(method(:onTimerFired), 1500, false);
        WatchUi.requestUpdate();
    }

    function onTimerFired() {
        feedback_text = "";
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var center_x = dc.getWidth() / 2;
        var center_y = dc.getHeight() / 2;

        var manual_override = Application.getApp().getManualOverride();
        var selected_index = Application.getApp().getSelectedIndex();

        dc.setPenWidth(6);

        if (!feedback_text.equals("")) {
            dc.setPenWidth(6);

            if (manual_override) { dc.setColor(0xAA0000, Graphics.COLOR_TRANSPARENT); }
            else { dc.setColor(0x00AA00, Graphics.COLOR_TRANSPARENT); }

            dc.drawArc(
                center_x, 
                center_y, 
                190, 
                Graphics.ARC_CLOCKWISE, 
                0, 
                360
            );

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                center_x, 
                center_y, 
                Graphics.FONT_GLANCE, 
                feedback_text,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            
            drawPageDots(dc, 1, 3);
            return; 
        }

        if (manual_override) { dc.setColor(0xAA0000, Graphics.COLOR_TRANSPARENT); }
        else { dc.setColor(0x00AA00, Graphics.COLOR_TRANSPARENT); }

        dc.drawArc(center_x, center_y, 190, Graphics.ARC_CLOCKWISE, 0, 360);

        dc.drawBitmap(
            center_x - 130,
            center_y - 110,
            start_icon
        );

        if (selected_index == 0) { dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT); }
        else { dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT); }

        dc.drawText(
            center_x - 15,
            center_y - 60,
            Roboto_medium,
            "Start",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.drawBitmap(
            center_x - 125,
            center_y + 8,
            stop_icon
        );

        if (selected_index == 1) { dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT); }
        else { dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT); }
        
        dc.drawText(
            center_x - 15,
            center_y + 55,
            Roboto_medium,
            "Stop",
            Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER
        );

        drawPageDots(dc, 1, 3);
    }

    function drawPageDots(dc, current_page, total_pages) {
        var dot_radius = 5;
        var dot_spacing = 20;
        var total_width = (total_pages - 1) * dot_spacing;
        var start_x = (dc.getWidth() - total_width) / 2;
        var dot_y = dc.getHeight() - 35;

        for (var i = 0; i < total_pages; i++) {
            
            if (i == current_page) { dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); }
            else { dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT); }

            dc.fillCircle(start_x + (i * dot_spacing), dot_y, dot_radius);
        }
    }

    function onHide() {
        feedback_timer.stop();
    }
}