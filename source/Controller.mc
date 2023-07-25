using Toybox.Timer;
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;

class Controller {
    hidden var _model;
    hidden var _timer;
    hidden var _heartbeatTimer as Timer.Timer;
    hidden var _isShowingLapSummaryView;
    hidden var _isTonesOn;
    hidden var _isVibrateOn;
    hidden var _hasCheckboxFeature;
    
    hidden var _isAutoLapDisabled = false;
    hidden var _currentLapEndSeconds = null;
    hidden var _currentLapEndMetres = null;

    function initialize() {
        _timer = new Timer.Timer();
        _heartbeatTimer = new Timer.Timer();

        _model = Application.getApp().getModel();
        var settings = System.getDeviceSettings();
        _isVibrateOn = settings.vibrateOn;
        _isTonesOn = settings.tonesOn;
        _hasCheckboxFeature = WatchUi has :Menu2;
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

    function setLapEnd(lapEnd as data.LapEnd) {
        if (lapEnd.LapType == Model.LapOn) {
            _model.setOnLapEnd(lapEnd);
        } else {
            _model.setOffLapEnd(lapEnd);
        }
    }

    function offLapRecordingMode() {
        return _model.offLapRecordingMode();
    }

    function onLapEnd() as data.LapEnd {
        return _model.onLapEnd();
    }

    function offLapEnd() as data.LapEnd {
        return _model.offLapEnd();
    }

    function start() {
        performAttention(Attention has :TONE_START ? Attention.TONE_START : null);
        _model.start();
        setupAutoLap();
    }

    function stop() {
        performAttention(Attention has :TONE_STOP ? Attention.TONE_STOP : null);
        _model.stop();
        setupAutoLap();
        _heartbeatTimer.stop();
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

    function onSelectLapEnd(lapType) {
        var isLapOn = lapType == Model.LapOn;
        var lapEnd = isLapOn ? onLapEnd() : offLapEnd();

        var menu = new WatchUi.Menu2({:title=>WatchUi.loadResource(isLapOn ? Rez.Strings.menu_lap_on_trigger_title : Rez.Strings.menu_lap_off_trigger_title), });
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_lap_trigger_user), null, Model.LapButtonPress, lapEnd.Trigger == Model.LapButtonPress, {}));
        var timePreview = lapEnd.Trigger == Model.TimeElapsed ? lapEnd.Units : "Set min:sec";
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_lap_trigger_time), timePreview, Model.TimeElapsed, lapEnd.Trigger == Model.TimeElapsed, {}));
        var distPreview = lapEnd.Trigger == Model.DistanceElapsed ? lapEnd.Units : "Set mi or km";
        menu.addItem(new WatchUi.ToggleMenuItem(WatchUi.loadResource(Rez.Strings.menu_lap_trigger_distance), distPreview, Model.DistanceElapsed, lapEnd.Trigger == Model.DistanceElapsed, {}));
        WatchUi.pushView(menu, new delegate.LapMenuInputDelegate(lapEnd), WatchUi.SLIDE_UP);
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

        _currentLapEndSeconds = null;
        _currentLapEndMetres = null;
        setupAutoLap();
    }

    function hideLapSummaryView() {
        if (_isShowingLapSummaryView) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            _isShowingLapSummaryView = false;
        }
    }

    private function setupAutoLap() {
        var lapEnd = _model.isActiveLap() ? onLapEnd() : offLapEnd();
                
        if (lapEnd.Trigger == Model.TimeElapsed) {
            _currentLapEndSeconds = data.TimeDto.fromString(lapEnd.Units).toSeconds();
        }
        if (lapEnd.Trigger == Model.DistanceElapsed) {
            _currentLapEndMetres = data.DistanceDto.fromString(lapEnd.Units).toMetres();
        }

        _heartbeatTimer.start(method(:onTick), 1000, true);
    }

    function onTick() {
        var sample = _model.tickSeconds();
        
        if (_isAutoLapDisabled) {
            return;
        }

        if (_currentLapEndSeconds != null && sample.Seconds >= _currentLapEndSeconds) {
            onLap();
            return;
        }

        if (_currentLapEndMetres != null && sample.Metres >= _currentLapEndMetres) {
            onLap();
            return;
        }
    }

    function turnOffAutoLap() {
        _isAutoLapDisabled = true;
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