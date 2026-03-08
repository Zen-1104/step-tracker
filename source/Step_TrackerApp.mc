import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class Step_TrackerApp extends Application.AppBase {
    var goal_steps = 10000;
    var manual_override = false;
    var selected_index = 0;
    var confirmed = false;

    var w1_start = -1; var w1_end = -1;
    var w2_start = -1; var w2_end = -1;
    var w3_start = -1; var w3_end = -1;

    var paused_steps = 0;
    var pause_start_steps = 0;
    var is_in_exclusion = false;
    var last_day = -1;

    function initialize() { AppBase.initialize(); }

    function onStart(state as Dictionary?) as Void {
        var stored = Application.Storage.getValue("goal_steps");
        var storedOverride = Application.Storage.getValue("manual_override");
        var storedPausedSteps = Application.Storage.getValue("paused_steps");
        var storedPauseStart = Application.Storage.getValue("pause_start_steps");
        var storedInExclusion = Application.Storage.getValue("is_in_exclusion");
        var storedLastDay = Application.Storage.getValue("last_day");

        if (stored == null) { goal_steps = 10000; }
        else { goal_steps = stored; }

        if (storedOverride != null) { manual_override = storedOverride; }
        if (storedPausedSteps != null) { paused_steps = storedPausedSteps; }
        if (storedPauseStart != null) { pause_start_steps = storedPauseStart; }
        if (storedInExclusion != null) { is_in_exclusion = storedInExclusion; }
        if (storedLastDay != null) { last_day = storedLastDay; }

        try {
            var w1s = Application.Properties.getValue("window1_start");
            var w1e = Application.Properties.getValue("window1_end");

            var w2s = Application.Properties.getValue("window2_start");
            var w2e = Application.Properties.getValue("window2_end");

            var w3s = Application.Properties.getValue("window3_start");
            var w3e = Application.Properties.getValue("window3_end");

            w1_start = (w1s != null) ? w1s : -1;
            w1_end = (w1e != null) ? w1e : -1;

            w2_start = (w2s != null) ? w2s : -1;
            w2_end = (w2e != null) ? w2e : -1;

            w3_start = (w3s != null) ? w3s : -1;
            w3_end = (w3e != null) ? w3e : -1;
            
        } catch (e instanceof Toybox.Lang.Exception) {
            // keep defaults
        }
    }

    function onStop(state as Dictionary?) as Void {
        Application.Storage.setValue("goal_steps", goal_steps);
        Application.Storage.setValue("manual_override", manual_override);
        Application.Storage.setValue("paused_steps", paused_steps);
        Application.Storage.setValue("pause_start_steps", pause_start_steps);
        Application.Storage.setValue("is_in_exclusion", is_in_exclusion);
        Application.Storage.setValue("last_day", last_day);
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        return [ new Step_TrackerView(), new Step_TrackerDelegate(0) ];
    }

    function getGoalSteps() { return goal_steps; }
    function setGoalSteps(value) {
        goal_steps = value;
        Application.Storage.setValue("goal_steps", value);
    }

    function getManualOverride() { return manual_override; }
    function setManualOverride(value) {
        manual_override = value;
        Application.Storage.setValue("manual_override", value);
    }

    function getPausedSteps() { return paused_steps; }
    function setPausedSteps(value) {
        paused_steps = value;
        Application.Storage.setValue("paused_steps", value);
    }

    function getPauseStartSteps() { return pause_start_steps; }
    function setPauseStartSteps(value) {
        pause_start_steps = value;
        Application.Storage.setValue("pause_start_steps", value);
    }

    function getIsInExclusion() { return is_in_exclusion; }
    function setIsInExclusion(value) {
        is_in_exclusion = value;
        Application.Storage.setValue("is_in_exclusion", value);
    }

    function getLastDay() { return last_day; }
    function setLastDay(value) {
        last_day = value;
        Application.Storage.setValue("last_day", value);
    }

    function toMinutes(hhmm) {
        if (hhmm == -1) { return -1; }
        var h = hhmm / 100;
        var m = hhmm % 100;
        return h * 60 + m;
    }

    function isInAnyWindow(hour, min) {
        var current = hour * 60 + min;
        if (w1_start != -1 && w1_end != -1) {
            if (current >= toMinutes(w1_start) && current < toMinutes(w1_end)) { return true; }
        }
        if (w2_start != -1 && w2_end != -1) {
            if (current >= toMinutes(w2_start) && current < toMinutes(w2_end)) { return true; }
        }
        if (w3_start != -1 && w3_end != -1) {
            if (current >= toMinutes(w3_start) && current < toMinutes(w3_end)) { return true; }
        }
        return false;
    }

    function isTimeWindowSet() {
        if (w1_start != -1 && w1_end != -1) { return true; }
        if (w2_start != -1 && w2_end != -1) { return true; }
        if (w3_start != -1 && w3_end != -1) { return true; }
        return false;
    }

    function getSelectedIndex() { return selected_index; }
    function setSelectedIndex(value) { selected_index = value; }
    function getConfirmed() { return confirmed; }
    function setConfirmed(value) { confirmed = value; }
}

function getApp() as Step_TrackerApp {
    return Application.getApp() as Step_TrackerApp;
}