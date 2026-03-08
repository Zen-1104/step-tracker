import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.ActivityMonitor;
import Toybox.Time.Gregorian;
import Toybox.Time;
import Toybox.Application;
using Toybox.Math;

class Step_TrackerView extends WatchUi.View {

    var step_icon;
    var Roboto_large;
    var Roboto_medium;
    var Roboto_small;

    function initialize() {
        View.initialize();
    }

    function onLayout(dc) {
        step_icon = WatchUi.loadResource(Rez.Drawables.StepIcon);
        Roboto_large = WatchUi.loadResource(Rez.Fonts.LargeFont);
        Roboto_medium = WatchUi.loadResource(Rez.Fonts.MediumFont);
        Roboto_small = WatchUi.loadResource(Rez.Fonts.SmallFont);
    }

    function onShow() {
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var start_angle = 210;
        var center_x = dc.getWidth() / 2;
        var center_y = dc.getHeight() / 2;

        if (!Application.getApp().isTimeWindowSet()) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(
                center_x, center_y, Graphics.FONT_GLANCE,
                "Set Time Window in \nGarmin Settings",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            drawPageDots(dc, 0, 3);
            return;
        }

        var now = Time.now();
        var info = Gregorian.info(now, Time.FORMAT_SHORT);
        var stepInfo = ActivityMonitor.getInfo();

        var daily_steps = stepInfo.steps;
        if (daily_steps == null) { daily_steps = 0; }

        var goal_steps = Application.getApp().getGoalSteps();
        var manual_override = Application.getApp().getManualOverride();
        var paused_steps = Application.getApp().getPausedSteps();
        var pause_start_steps = Application.getApp().getPauseStartSteps();
        var is_in_exclusion = Application.getApp().getIsInExclusion();
        var last_day = Application.getApp().getLastDay();

        // midnight reset
        if (last_day != -1 && info.day != last_day) {
            Application.getApp().setPausedSteps(0);
            Application.getApp().setPauseStartSteps(0);
            Application.getApp().setIsInExclusion(false);
            Application.getApp().setManualOverride(false);
            paused_steps = 0;
            pause_start_steps = 0;
            is_in_exclusion = false;
            manual_override = false;
        }
        Application.getApp().setLastDay(info.day);

        var in_exclusion = Application.getApp().isInAnyWindow(info.hour, info.min);

        if (!manual_override) {
            if (in_exclusion && !is_in_exclusion) {
                Application.getApp().setPauseStartSteps(daily_steps);
                Application.getApp().setIsInExclusion(true);
                pause_start_steps = daily_steps;
                is_in_exclusion = true;

            } else if (!in_exclusion && is_in_exclusion) {
                var steps_during_exclusion = daily_steps - pause_start_steps;
                if (steps_during_exclusion < 0) { steps_during_exclusion = 0; }
                Application.getApp().setPausedSteps(paused_steps + steps_during_exclusion);
                Application.getApp().setIsInExclusion(false);
                paused_steps = paused_steps + steps_during_exclusion;
                is_in_exclusion = false;
            }
        }

        // calculate display steps
        var window_steps = daily_steps - paused_steps;
        if (is_in_exclusion) {
            // freeze display during exclusion
            window_steps = pause_start_steps - paused_steps;
        }
        if (window_steps < 0) { window_steps = 0; }

        System.println("hour: " + info.hour + " min: " + info.min + " inExclusion: " + Application.getApp().getIsInExclusion() + " inWindow: " + Application.getApp().isInAnyWindow(info.hour, info.min));


        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawArc(center_x, center_y, 190, Graphics.ARC_CLOCKWISE, start_angle, 330);

        var progress_degree = 0;
        if (goal_steps > 0) { progress_degree = (window_steps / goal_steps.toFloat()) * 240; }
        if (progress_degree > 240) { progress_degree = 240; }

        var current_angle = start_angle - progress_degree;

        if (progress_degree > 0) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(8);
            dc.drawArc(center_x, center_y, 190, Graphics.ARC_CLOCKWISE, start_angle, current_angle);

            var start_rad = Math.toRadians(start_angle);
            var end_rad = Math.toRadians(current_angle);
            var start_x = center_x + 190 * Math.cos(start_rad);
            var start_y = center_y - 190 * Math.sin(start_rad);
            var end_x = center_x + 190 * Math.cos(end_rad);
            var end_y = center_y - 190 * Math.sin(end_rad);
            dc.fillCircle(start_x, start_y, 4);
            dc.fillCircle(end_x, end_y, 4);
        }

        dc.drawBitmap(center_x - 35, 45, step_icon);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(center_x, 170, Roboto_large, window_steps.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(center_x, 250, Roboto_small, goal_steps.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        drawPageDots(dc, 0, 3);

        if (manual_override) {
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(8);
            dc.drawArc(center_x, center_y, 190, Graphics.ARC_CLOCKWISE, start_angle, current_angle);
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(center_x, 290, Roboto_medium, "Paused",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        if (in_exclusion && !manual_override) {
            dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
            dc.drawText(center_x, 290, Roboto_small, "Excluded",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
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
    }
}