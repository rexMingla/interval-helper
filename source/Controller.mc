using Toybox.Timer;
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
    hidden var _hasCheckboxFeature;

    function initialize() {
        _timer = new Timer.Timer();
        _model = Application.getApp().getModel();
        var settings = System.getDeviceSettings();
        _isVibrateOn = settings.vibrateOn;
        _isTonesOn = settings.tonesOn;
        _hasCheckboxFeature = hasCheckboxFeature();
    }

    function setActivity(activity) {
        _model.setActivity(activity);
        if (_hasCheckboxFeature) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

    function setOffLapRecordingMode(mode) {
        _model.setOffLapRecordingMode(mode);
        if (_hasCheckboxFeature) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
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
            WatchUi.pushView(new Rez.Menus.RunningMenu(), new delegate.RunningMenuDelegate(), WatchUi.SLIDE_UP);
        }
    }

    function onStartActivity() {
        WatchUi.pushView(new Rez.Menus.StartMenu(), new delegate.StartMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function onSelectActivity() {
        var activity = _model.getActivity();
        if (_hasCheckboxFeature) {
            var menu = new WatchUi.CheckboxMenu({:title=>WatchUi.loadResource(Rez.Strings.menu_activity_title)});
            menu.addItem(new WatchUi.CheckboxMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_run), null, ActivityRecording.SPORT_RUNNING, activity == ActivityRecording.SPORT_RUNNING, {}));
            menu.addItem(new WatchUi.CheckboxMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_bike), null, ActivityRecording.SPORT_CYCLING, activity == ActivityRecording.SPORT_CYCLING, {}));
            menu.addItem(new WatchUi.CheckboxMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_swim), null, ActivityRecording.SPORT_SWIMMING, activity == ActivityRecording.SPORT_SWIMMING, {}));
            menu.addItem(new WatchUi.CheckboxMenuItem(WatchUi.loadResource(Rez.Strings.menu_activity_other), null, ActivityRecording.SPORT_GENERIC, activity == ActivityRecording.SPORT_GENERIC, {}));
            WatchUi.pushView(menu, new delegate.ActivityInputDelegate(), WatchUi.SLIDE_UP);
        } else {
            var menu = new WatchUi.Menu();
            menu.setTitle(WatchUi.loadResource(Rez.Strings.menu_activity_title));
            menu.addItem(activity == ActivityRecording.SPORT_RUNNING
                ? WatchUi.loadResource(Rez.Strings.menu_activity_run_selected)
                : WatchUi.loadResource(Rez.Strings.menu_activity_run), ActivityRecording.SPORT_RUNNING);
            menu.addItem(activity == ActivityRecording.SPORT_CYCLING
                ? WatchUi.loadResource(Rez.Strings.menu_activity_bike_selected)
                : WatchUi.loadResource(Rez.Strings.menu_activity_bike), ActivityRecording.SPORT_CYCLING);
            menu.addItem(activity == ActivityRecording.SPORT_SWIMMING
                ? WatchUi.loadResource(Rez.Strings.menu_activity_swim_selected)
                : WatchUi.loadResource(Rez.Strings.menu_activity_swim), ActivityRecording.SPORT_SWIMMING);
            menu.addItem(activity == ActivityRecording.SPORT_GENERIC
                ? WatchUi.loadResource(Rez.Strings.menu_activity_other_selected)
                : WatchUi.loadResource(Rez.Strings.menu_activity_other), ActivityRecording.SPORT_GENERIC);
            WatchUi.pushView(menu, new delegate.OldActivityInputDelegate(), WatchUi.SLIDE_UP);
        }
    }

    function onSelectMode() {
        var mode = offLapRecordingMode();
        if (_hasCheckboxFeature) {
            var menu = new WatchUi.CheckboxMenu({:title=>WatchUi.loadResource(Rez.Strings.menu_mode_title)});
            menu.addItem(new WatchUi.CheckboxMenuItem(WatchUi.loadResource(Rez.Strings.menu_mode_norecord), null, Model.NoRecord, mode == Model.NoRecord, {}));
            menu.addItem(new WatchUi.CheckboxMenuItem(WatchUi.loadResource(Rez.Strings.menu_mode_recordnogps), null, Model.RecordNoGps, mode == Model.RecordNoGps, {}));
            menu.addItem(new WatchUi.CheckboxMenuItem(WatchUi.loadResource(Rez.Strings.menu_mode_recordwithgps), null, Model.RecordWithGps, mode == Model.RecordWithGps, {}));
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

    private function hasCheckboxFeature() {
        var mySettings = System.getDeviceSettings();
        var version = mySettings.monkeyVersion;
        return version[0] >= 3;
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