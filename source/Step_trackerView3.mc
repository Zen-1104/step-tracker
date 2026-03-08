import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Application;
import Toybox.Timer;

class Step_TrackerView3 extends WatchUi.View {

    var Roboto_small;
    var Roboto_medium;
    var Roboto_large;
    var Check_icon;
    var confirmed;
    var show_hint = false;
    var confirm_timer;

    function initialize() {
        View.initialize();
        confirm_timer = new Timer.Timer();
    }

    function onLayout(dc) {
        Roboto_small = WatchUi.loadResource(Rez.Fonts.SmallFont);
        Roboto_medium = WatchUi.loadResource(Rez.Fonts.MediumFont);
        Roboto_large = WatchUi.loadResource(Rez.Fonts.LargeFont);
        Check_icon = WatchUi.loadResource(Rez.Drawables.CheckIcon);
    }

    function onShow() {
        confirmed = false;
        show_hint = false;
        WatchUi.requestUpdate();
    }

    function showHintArc() {
        show_hint = true;
        WatchUi.requestUpdate();
    }

    function onConfirmed() {
        confirmed = true;
        confirm_timer.start(method(:onConfirmTimerFired), 2000, false);
        WatchUi.requestUpdate();
    }

    function onConfirmTimerFired() {
        confirmed = false;
        WatchUi.popView(WatchUi.SLIDE_RIGHT);
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var center_x = dc.getWidth() / 2;
        var center_y = dc.getHeight() / 2;

        var goal_steps = Application.getApp().getGoalSteps();

        if (show_hint) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(6);
            dc.drawArc(
                center_x,
                center_y,
                190,
                Graphics.ARC_COUNTER_CLOCKWISE,
                17,
                45
            );
        }

        if (confirmed) {
            dc.setPenWidth(6);
            dc.drawBitmap(
                center_x - 75,
                center_y - 110,
                Check_icon
            );

            dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                center_x, 
                center_y + 60, 
                Roboto_small, 
                "Goal Saved",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );

            drawPageDots(dc, 2, 3);  // Goal setting Screen
            return;
        }

        drawPageDots(dc, 2, 3);

         dc.setColor(0x888888, Graphics.COLOR_TRANSPARENT);
         dc.drawText(
            center_x, 
            center_y - 120, 
            Roboto_small, 
            "Set New Goal",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            center_x,
            215,
            Roboto_large,
            goal_steps.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER  
        );

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        drawUpArrow(dc, center_x, center_y - 60, 15);

        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        drawDownArrow(dc, center_x, center_y + 115, 15);
    }

    function drawUpArrow(dc, x, y, size) {
        dc.drawLine(x, y, x - size, y + size);  // left side
        dc.drawLine(x, y, x + size, y + size);  // right side
    }

    function drawDownArrow(dc, x, y, size) {
        dc.drawLine(x, y, x - size, y - size);  
        dc.drawLine(x, y, x + size, y - size);  
    }

    function drawPageDots(dc, current_page, total_pages) {
        var dot_radius = 5;
        var dot_spacing = 20;
        var total_width = (total_pages - 1) * dot_spacing;
        var start_x = (dc.getWidth() - total_width) / 2;
        var dot_y = dc.getHeight() - 35;

        for (var i = 0; i < total_pages; i++) {
            if (i == current_page) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            } else {
                dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            }
            dc.fillCircle(start_x + (i * dot_spacing), dot_y, dot_radius);
        }
    }

    function onHide() {
        confirm_timer.stop();
        confirmed = false;
        show_hint = false;
    }
}