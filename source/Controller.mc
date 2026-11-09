import Toybox.Lang;
using Toybox.Timer;
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;

class Controller {
    hidden var _model as Model;
    hidden var _timer as Timer.Timer = new Timer.Timer();
    hidden var _isShowingLapSummaryView as Boolean = false;
    hidden var _isTonesOn as Boolean;
    hidden var _isVibrateOn as Boolean;

    function initialize() {
        _model = (Application.getApp() as IntervalApp).getModel();
        var settings = System.getDeviceSettings();
        _isVibrateOn = settings.vibrateOn;
        _isTonesOn = settings.tonesOn;
    }

    function setActivity(activity as Number) as Void {
        _model.setActivity(activity);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function setOffLapRecordingMode(mode as Number) as Void {
        _model.setOffLapRecordingMode(mode);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function offLapRecordingMode() as Number {
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
            var menu = new WatchUi.Menu2({:title=>text(Rez.Strings.menu_pause_title)});
            menu.addItem(new WatchUi.MenuItem(text(Rez.Strings.menu_label_1), null, :resume, {}));
            menu.addItem(new WatchUi.MenuItem(text(Rez.Strings.menu_label_2), null, :save, {}));
            menu.addItem(new WatchUi.MenuItem(text(Rez.Strings.menu_label_3), null, :discard, {}));
            WatchUi.pushView(menu, new delegate.RunningMenuDelegate(), WatchUi.SLIDE_UP);
        }
    }

    function onStartActivity() as Void {
        var menu = new WatchUi.Menu2({:title=>text(Rez.Strings.menu_start_title)});
        menu.addItem(new WatchUi.MenuItem(text(Rez.Strings.menu_start_start), null, :start, {}));
        menu.addItem(new WatchUi.MenuItem(text(Rez.Strings.menu_start_select), null, :select, {}));
        menu.addItem(new WatchUi.MenuItem(text(Rez.Strings.menu_start_mode), null, :mode, {}));
        WatchUi.pushView(menu, new delegate.StartMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function onSelectActivity() as Void {
        var activity = _model.getActivity();
        var menu = new WatchUi.Menu2({:title=>text(Rez.Strings.menu_activity_title)});
        menu.addItem(new WatchUi.ToggleMenuItem(text(Rez.Strings.menu_activity_run), null, Model.SPORT_RUNNING, activity == Model.SPORT_RUNNING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(text(Rez.Strings.menu_activity_bike), null, Model.SPORT_CYCLING, activity == Model.SPORT_CYCLING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(text(Rez.Strings.menu_activity_swim), null, Model.SPORT_SWIMMING, activity == Model.SPORT_SWIMMING, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(text(Rez.Strings.menu_activity_other), null, Model.SPORT_GENERIC, activity == Model.SPORT_GENERIC, {}));
        WatchUi.pushView(menu, new delegate.ActivityInputDelegate(), WatchUi.SLIDE_UP);
    }

    function onSelectMode() as Void {
        var mode = offLapRecordingMode();
        var menu = new WatchUi.Menu2({:title=>text(Rez.Strings.menu_mode_title)});
        menu.addItem(new WatchUi.ToggleMenuItem(text(Rez.Strings.menu_mode_norecord), null, Model.NoRecord, mode == Model.NoRecord, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(text(Rez.Strings.menu_mode_recordnogps), null, Model.RecordNoGps, mode == Model.RecordNoGps, {}));
        menu.addItem(new WatchUi.ToggleMenuItem(text(Rez.Strings.menu_mode_recordwithgps), null, Model.RecordWithGps, mode == Model.RecordWithGps, {}));
        WatchUi.pushView(menu, new delegate.ModeInputDelegate(), WatchUi.SLIDE_UP);
    }

    function isActiveLap() as Boolean {
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

    function performAttention(tone as Attention.Tone or Null) as Void {
        if (Attention has :playTone && _isTonesOn && tone != null) {
            Attention.playTone(tone);
        }
        if (Attention has :vibrate && _isVibrateOn) {
            Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
        }
    }

    private function text(id as ResourceId) as String {
        return WatchUi.loadResource(id) as String;
    }
}
