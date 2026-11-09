import Toybox.Lang;
using Toybox.Timer;
using Toybox.ActivityRecording;
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;

class Controller {
    hidden var _model;
    hidden var _timer;
    hidden var _isShowingLapSummaryView;
    hidden var _isTonesOn;
    hidden var _isVibrateOn;

    function initialize() {
        _timer = new Timer.Timer();
        _model = Application.getApp().getModel();
        var settings = System.getDeviceSettings();
        _isVibrateOn = settings.vibrateOn;
        _isTonesOn = settings.tonesOn;
    }

    function setActivity(activity) {
        _model.setActivity(activity);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function setOffLapRecordingMode(mode) {
        _model.setOffLapRecordingMode(mode);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function offLapRecordingMode() {
        return _model.offLapRecordingMode();
    }

    function start() {
        performAttention(Attention has :TONE_START ? Attention.TONE_START : null);
        _model.start();
    }

    function stop() {
        performAttention(Attention has :TONE_STOP ? Attention.TONE_STOP : null);
        _model.stop();
    }

    function save() {
        performAttention(Attention has :TONE_KEY ? Attention.TONE_KEY : null);
        _model.save();
        // Give the system some time to finish the recording. Push up a progress bar
        // and start a _timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Saving...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        _timer.stop();
        _timer.start(method(:onExit), 3000, false);
    }

    function discard() {
        performAttention(Attention has :TONE_KEY ? Attention.TONE_KEY : null);
        _model.discard();
        // Give the system some time to discard the recording. Push up a progress bar
        // and start a _timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Discarding...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        _timer.stop();
        _timer.start(method(:onExit), 3000, false);
    }

    // Handle the start/stop button
    function onStartStop() {
        if (!hasStarted()) {
            onStartActivity();
        } else if (!isRunning()) {
            start();
        } else {
            stop();
            var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_pause_title)});
            menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_label_1), null, :resume, {}));
            menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_label_2), null, :save, {}));
            menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_label_3), null, :discard, {}));
            WatchUi.pushView(menu, new delegate.RunningMenuDelegate(), WatchUi.SLIDE_UP);
        }
    }

    function onStartActivity() {
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_start_title)});
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_start_start), null, :start, {}));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_start_select), null, :select, {}));
        menu.addItem(new WatchUi.MenuItem(WatchUi.loadResource(Rez.Strings.menu_start_mode), null, :mode, {}));
        WatchUi.pushView(menu, new delegate.StartMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function onSelectActivity() {
        var activity = _model.getActivity();
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_activity_title)});
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_run), null, ActivityRecording.SPORT_RUNNING, activity == ActivityRecording.SPORT_RUNNING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_bike), null, ActivityRecording.SPORT_CYCLING, activity == ActivityRecording.SPORT_CYCLING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_swim), null, ActivityRecording.SPORT_SWIMMING, activity == ActivityRecording.SPORT_SWIMMING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_other), null, ActivityRecording.SPORT_GENERIC, activity == ActivityRecording.SPORT_GENERIC, {}));
        WatchUi.pushView(menu, new delegate.ActivityInputDelegate(), WatchUi.SLIDE_UP);
    }

    function onSelectMode() {
        var mode = offLapRecordingMode();
        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(Rez.Strings.menu_mode_title)});
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_mode_norecord), null, Model.NoRecord, mode == Model.NoRecord, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_mode_recordnogps), null, Model.RecordNoGps, mode == Model.RecordNoGps, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_mode_recordwithgps), null, Model.RecordWithGps, mode == Model.RecordWithGps, {}));
        WatchUi.pushView(menu, new delegate.ModeInputDelegate(), WatchUi.SLIDE_UP);
    }

    function isActiveLap() {
        return _model.isActiveLap();
    }

    function isRunning() {
        return _model.isRunning();
    }

    function hasStarted() {
        return _model.hasStarted();
    }

    function onLap() {
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

    function hideLapSummaryView() {
        if (_isShowingLapSummaryView) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _isShowingLapSummaryView = false;
        }
    }

    function onExit() {
        System.exit();
    }

    function cycleView(offset) {
        _model.cycleView(offset);
        WatchUi.requestUpdate();
    }

    function performAttention(tone) {
        if (Attention has :playTone && _isTonesOn && tone != null) {
            Attention.playTone(tone);
        }
        if (Attention has :vibrate && _isVibrateOn) {
            Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
        }
    }
 }