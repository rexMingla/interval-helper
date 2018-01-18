using Toybox.Timer;
using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Attention;

class Controller {
    private var mModel;
    private var mTimer;
    private var mIsShowingLapSummaryView;
    private var mIsSilent;

    function initialize() {
        mTimer = new Timer.Timer();
        mModel = Application.getApp().model;
        mIsSilent = false; // TODO: move to config
    }

    function setActivity(activity) {
        mModel.setActivity(activity);
    }

    function start() {
        performAttention(Attention.TONE_START);
        mModel.start();
    }

    function resume() {
        performAttention(Attention.TONE_START);
        mModel.resume();
    }

    function stop() {
        performAttention(Attention.TONE_STOP);
        mModel.stop();
    }

    function save() {
        performAttention(Attention.TONE_KEY);
        mModel.save();
        // Give the system some time to finish the recording. Push up a progress bar
        // and start a timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Saving...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        mTimer.stop();
        mTimer.start(method(:onExit), 3000, false);
    }

    function discard() {
        performAttention(Attention.TONE_KEY);
        mModel.discard();
        // Give the system some time to discard the recording. Push up a progress bar
        // and start a timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Discarding...", null), new delegate.ProgressDelegate(), WatchUi.SLIDE_DOWN);
        mTimer.stop();
        mTimer.start(method(:onExit), 3000, false);
    }

    // Handle the start/stop button
    function onStartStop() {
        if (!hasStarted()) {
            onStartActivity();
        } else if (!isRunning()) {
            resume();
        } else {
            stop();
            WatchUi.pushView(new Rez.Menus.RunningMenu(), new delegate.RunningMenuDelegate(), WatchUi.SLIDE_UP);
        }
    }

    function onStartActivity() {
        WatchUi.pushView(new Rez.Menus.StartMenu(), new delegate.StartMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function onSelectActivity() {
        WatchUi.pushView(new Rez.Menus.ActivityMenu(), new delegate.ActivityMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function isActiveLap() {
        return mModel.isActiveLap();
    }

    function isRunning() {
        return mModel.isRunning();
    }

    function hasStarted() {
        return mModel.hasStarted();
    }

    function onLap() {
        performAttention(Attention.TONE_LAP);
        var data = mModel.getLapData().clone();
        mModel.startLap();

        mTimer.stop();
        if (mIsShowingLapSummaryView) {
            WatchUi.switchToView(new view.LapSummaryView(data), new delegate.LapSummaryDelegate(), WatchUi.SLIDE_UP);
        } else {
            WatchUi.pushView(new view.LapSummaryView(data), new delegate.LapSummaryDelegate(), WatchUi.SLIDE_UP);
        }
        mIsShowingLapSummaryView = true;
        mTimer.start(method(:hideLapSummaryView), 5000, false);
    }

    function hideLapSummaryView() {
        if (mIsShowingLapSummaryView) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            mIsShowingLapSummaryView = false;
        }
    }

    function onExit() {
        System.exit();
    }

    function cycleView(offset) {
        mModel.cycleView(offset);
    }

    function performAttention(tone) {
        if (mIsSilent) {
            return;
        }
        if (Attention has :playTone) {
            Attention.playTone(tone);
        }
        if (Attention has :vibrate) {
            Attention.vibrate([new Attention.VibeProfile(50, 1000)]);
        }
    }
 }