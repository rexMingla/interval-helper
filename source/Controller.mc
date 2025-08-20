using Toybox.Timer;
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;
import Toybox.Lang;

class Controller {
    hidden var _model as Model;
    hidden var _timer as Timer.Timer;
    hidden var _isShowingLapSummaryView as Boolean = false;
    hidden var _isTonesOn as Boolean = false;
    hidden var _isVibrateOn as Boolean = false;
    hidden var _hasCheckboxFeature as Boolean = false;

    function initialize() {
        _timer = new Timer.Timer();
        _model = Application.getApp().getModel();
        var settings = System.getDeviceSettings();
        _isVibrateOn = settings.vibrateOn;
        _isTonesOn = settings.tonesOn;
        _hasCheckboxFeature = WatchUi has :Menu2;
    }

    function setActivity(activity as Toybox.Activity) as Void {
        _model.setActivity(activity);
        if (_hasCheckboxFeature) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

    function setOffLapRecordingMode(mode as RecordingMode) as Void {
        _model.setOffLapRecordingMode(mode);
        if (_hasCheckboxFeature) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

    function offLapRecordingMode() as RecordingMode {
        return _model.offLapRecordingMode();
    }

    function start() as Void {
        performAttention(Attention has :TONE_START ? Attention.TONE_START : null);
        _model.start();
    }

    function stop() as Void {
        performAttention(Attention has :TONE_STOP ? Attention.TONE_STOP : null);
        _model.stop();
    }

    function save() as Void {
        performAttention(Attention has :TONE_KEY ? Attention.TONE_KEY : null);
        _model.save();
        // Give the system some time to finish the recording. Push up a progress bar
        // and start a _timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Saving...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        _timer.stop();
        _timer.start(method(:onExit), 3000, false);
    }

    function discard() as Void {
        performAttention(Attention has :TONE_KEY ? Attention.TONE_KEY : null);
        _model.discard();
        // Give the system some time to discard the recording. Push up a progress bar
        // and start a _timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Discarding...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        _timer.stop();
        _timer.start(method(:onExit), 3000, false);
    }

    // Handle the start/stop button
    function onStartStop() as Void {
        if (!hasStarted()) {
            onStartActivity();
        } else if (!isRunning()) {
            start();
        } else {
            stop();
            WatchUi.pushView(new Rez.Menus.RunningMenu(), new delegate.RunningMenuDelegate(), WatchUi.SLIDE_UP);
        }
    }

    function onStartActivity() as Void {
        WatchUi.pushView(new Rez.Menus.StartMenu(), new delegate.StartMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function onSelectActivity() as Void {
        var activity = _model.getActivity();
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_activity_title)});
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_run), null, Activity.SPORT_RUNNING, activity == Activity.SPORT_RUNNING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_bike), null, Activity.SPORT_CYCLING, activity == Activity.SPORT_CYCLING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_swim), null, Activity.SPORT_SWIMMING, activity == Activity.SPORT_SWIMMING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_other), null, Activity.SPORT_GENERIC, activity == Activity.SPORT_GENERIC, {}));
        WatchUi.pushView(menu, new delegate.ActivityInputDelegate(), WatchUi.SLIDE_UP);
    }

    function onSelectMode() as Void {
        var mode = offLapRecordingMode();
        if (_hasCheckboxFeature) {
            var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_mode_title)});
            menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_mode_norecord), null, Model.NoRecord, mode == Model.NoRecord, {}));
            menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_mode_recordnogps), null, Model.RecordNoGps, mode == Model.RecordNoGps, {}));
            menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_mode_recordwithgps), null, Model.RecordWithGps, mode == Model.RecordWithGps, {}));
            WatchUi.pushView(menu, new delegate.ModeInputDelegate(), WatchUi.SLIDE_UP);
        } else {
            var menu = new WatchUi.Menu();
            menu.setTitle(WatchUi.loadResource(Rez.Strings.menu_mode_title));
            menu.addItem(mode == Model.NoRecord
                ? WatchUi.loadResource(Rez.Strings.menu_mode_norecord_selected)
                : WatchUi.loadResource(Rez.Strings.menu_mode_norecord), Model.NoRecord);
            menu.addItem(mode == Model.RecordNoGps
                ? WatchUi.loadResource(Rez.Strings.menu_mode_recordnogps_selected)
                : WatchUi.loadResource(Rez.Strings.menu_mode_recordnogps), Model.RecordNoGps);
            menu.addItem(mode == Model.RecordWithGps
                ? WatchUi.loadResource(Rez.Strings.menu_mode_recordwithgps_selected)
                : WatchUi.loadResource(Rez.Strings.menu_mode_recordwithgps), Model.RecordWithGps);
            WatchUi.pushView(menu, new delegate.OldModeInputDelegate(), WatchUi.SLIDE_UP);
        }
    }

    function isActiveLap() as Void {
        return _model.isActiveLap();
    }

    function isRunning() as Boolean {
        return _model.isRunning();
    }

    function hasStarted() as Boolean {
        return _model.hasStarted();
    }

    function onLap() as Void {
        performAttention(Attention has :TONE_LAP ? Attention.TONE_LAP : null);
        var data = _model.getLapData().clone();
        _model.startLap();

        _timer.stop();
        if (_isShowingLapSummaryView) {
            WatchUi.switchToView(new view.LapSummaryView(data), new delegate.LapSummaryDelegate(), WatchUi.SLIDE_UP);
        } else {
            WatchUi.pushView(new view.LapSummaryView(data), new delegate.LapSummaryDelegate(), WatchUi.SLIDE_UP);
        }
        _isShowingLapSummaryView = true;
        _timer.start(method(:hideLapSummaryView), 5000, false);
    }

    function hideLapSummaryView() as Void {
        if (_isShowingLapSummaryView) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _isShowingLapSummaryView = false;
        }
    }

    function onExit() as Void {
        System.exit();
    }

    function cycleView(offset as Number) as Void {
        _model.cycleView(offset);
        WatchUi.requestUpdate();
    }

    function performAttention(tone as Attention) as Void {
        if (Attention has :playTone && _isTonesOn && tone != null) {
            Attention.playTone(tone);
        }
        if (Attention has :vibrate && _isVibrateOn) {
            Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
        }
    }
 }