import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;

class Step_TrackerDelegate extends WatchUi.BehaviorDelegate {

    var current_page;

    function initialize(page) {
        BehaviorDelegate.initialize();
        current_page = page;
    }

    function onSwipe(SwipeEvent) {
        var direction = SwipeEvent.getDirection();

        if (direction == WatchUi.SWIPE_LEFT) {
            if (current_page == 0) {
                WatchUi.pushView(new Step_TrackerView2(), new Step_TrackerDelegate(1), WatchUi.SLIDE_LEFT);
            } else if (current_page == 1) {
                WatchUi.pushView(new Step_TrackerView3(), new Step_TrackerDelegate(2), WatchUi.SLIDE_LEFT);
            }
        } else if (direction == WatchUi.SWIPE_RIGHT) {
            if (current_page > 0) {
                WatchUi.popView(WatchUi.SLIDE_RIGHT);
            }
        }

        return true;
    }

    function onNextPage() {
        if (current_page == 1) {
            Application.getApp().setSelectedIndex(1);
        } else if (current_page == 2) {
            var current = Application.getApp().getGoalSteps();
            Application.getApp().setGoalSteps(current + 1000);
            var view = WatchUi.getCurrentView()[0] as Step_TrackerView3;
            if (view != null) { view.showHintArc(); }
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onPreviousPage() {
        if (current_page == 1) {
            Application.getApp().setSelectedIndex(0);
        } else if (current_page == 2) {
            var current = Application.getApp().getGoalSteps();
            if (current >= 2000) {
                Application.getApp().setGoalSteps(current - 1000);
            }
            var view = WatchUi.getCurrentView()[0] as Step_TrackerView3;
            if (view != null) { view.showHintArc(); }
        }
        WatchUi.requestUpdate();
        return true;
    }

    function onSelect() {
        if (current_page == 1) {
            var selected = Application.getApp().getSelectedIndex();
            var view = WatchUi.getCurrentView()[0] as Step_TrackerView2;

            if (view != null) {
                if (selected == 0) {
                    Application.getApp().setManualOverride(false);
                    view.showFeedback("Tracking Started");
                } else {
                    Application.getApp().setManualOverride(true);
                    view.showFeedback("Tracking Stopped");
                }
            }
            WatchUi.requestUpdate();
        } else if (current_page == 2) {
            var view = WatchUi.getCurrentView()[0] as Step_TrackerView3;
            if (view != null) { view.onConfirmed(); }
        }
        return true;
    }
}