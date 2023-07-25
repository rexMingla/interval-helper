using Toybox.Activity;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Attention;
using Toybox.Timer;
using Toybox.FitContributor;
using Toybox.ActivityRecording;

class Model
{
    hidden var _session;
    hidden var _lap;
    hidden var _lapSeconds;
    hidden var _lapMetres;
    hidden var _isActive;
    hidden var _startOfLapDistanceKilometres;
    hidden var _activity;
    hidden var _offLapRecordingMode;
    hidden var _offLapEnd;
    hidden var _onLapEnd;
    hidden var _isRunning;
    hidden var _speedConversion;

    hidden var _lapCurrentData;
    hidden var _overallData;

    hidden var _views = [Lap, Total];
    hidden var _currentViewIndex;

    hidden const KmsToMiles = 0.621371;

    enum {
       Lap,
       Total
    }

    enum {
        NoRecord,
        RecordNoGps,
        RecordWithGps
    }

    enum {
        LapButtonPress,        
        TimeElapsed,
        DistanceElapsed
    }
    
    enum {
        LapOn,
        LapOff
    }

    hidden static var mAllSensorsByActivityType = {
        ActivityRecording.SPORT_RUNNING => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_CYCLING => [Sensor.SENSOR_BIKESPEED, Sensor.SENSOR_BIKECADENCE, Sensor.SENSOR_BIKEPOWER, Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_SWIMMING => [Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_GENERIC => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE]
    };

    function initialize() {
        _lap = 0;
        _isActive = true;
        _lapSeconds = 0;
        _lapMetres = 0;
        _startOfLapDistanceKilometres = 0;
        _currentViewIndex = 0;
        _activity = null;
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:positionCallback));

        var activity = Application.getApp().getProperty("activity");
        setActivity(activity != null ? activity : ActivityRecording.SPORT_RUNNING);
        _lapCurrentData = new data.ViewDataset();
        _overallData = new data.ViewDataset();
        _speedConversion = System.getDeviceSettings().paceUnits == System.UNIT_METRIC ? 1 : KmsToMiles;
        _isRunning = false;

        {
            var mode = Application.getApp().getProperty("offLapRecordingMode");
            mode = mode != null ? mode : NoRecord;
            setOffLapRecordingMode(mode);
        }
        
        {
            var trigger = Application.getApp().getProperty("offLapEndTrigger");
            var units = Application.getApp().getProperty("offLapEndUnits");
            setOffLapEnd(new data.LapEnd(Model.LapOff, trigger, units));
        }

        {
            var trigger = Application.getApp().getProperty("onLapEndTrigger");
            var units = Application.getApp().getProperty("onLapEndUnits");
            setOnLapEnd(new data.LapEnd(Model.LapOn, trigger, units));
        }
    }

    function setActivity(activity) {
        _activity = activity;
        Sensor.setEnabledSensors(mAllSensorsByActivityType[_activity]);
        Application.getApp().setProperty("activity", _activity);
    }

    function getActivity() {
        return _activity;
    }

    function setOffLapRecordingMode(mode) {
        _offLapRecordingMode = mode;
        Application.getApp().setProperty("offLapRecordingMode", _offLapRecordingMode);
    }

    function setOffLapEnd(lapEnd as data.LapEnd) {
        _offLapEnd = lapEnd;
        Application.getApp().setProperty("offLapEndTrigger", _offLapEnd.Trigger);
        Application.getApp().setProperty("offLapEndUnits", _offLapEnd.Units);
    }

    function setOnLapEnd(lapEnd as data.LapEnd) {
        _onLapEnd = lapEnd;
        Application.getApp().setProperty("onLapEndTrigger", _onLapEnd.Trigger);
        Application.getApp().setProperty("onLapEndUnits", _onLapEnd.Units);
    }

    function offLapRecordingMode() {
        return _offLapRecordingMode;
    }

    function offLapEnd()  as data.LapEnd {
        return _offLapEnd;
    }

    function onLapEnd()  as data.LapEnd {
        return _onLapEnd;
    }

    function start() {
        if (!hasStarted()) {
            _session = ActivityRecording.createSession({:sport=>_activity, :name=>"Intervals"});
            _lap = 1;
        }
        // force it back on because Garmin turns it off
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:positionCallback));
        _session.start();
        _isRunning = true;
    }

    function TickSeconds() {

    }

    function stop() {
        _session.stop();
        _isRunning = false;
    }

    function startLap() {
        _lap++;
        _lapSeconds = 0;
        _lapMetres = 0;
        _isActive = !_isActive;
        var info = Activity.getActivityInfo();
        _startOfLapDistanceKilometres = safeGetNumber(info.elapsedDistance) / 1000;
        if (isActiveLap()) {
            _session.addLap();
            start();
            return;
        }

        if (_offLapRecordingMode == NoRecord) {
            _session.stop();
            return;
        }

        _session.addLap();
        if (_offLapRecordingMode == RecordNoGps) {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:positionCallback));
        }
    }

    function hasStarted() {
        return _lap > 0;
    }

    function isActiveLap() {
        return _isActive;
    }

    function isRunning() {
        return _isRunning;
    }

    function save() {
        _session.save();
    }

    function discard() {
        _session.discard();
    }

    function getLapData() {
        var info = Activity.getActivityInfo();
        _lapCurrentData.IsActive = isActiveLap();
        _lapCurrentData.LapNumber = (getLap() + 1) / 2;
        // currentSpeed = metres / sec
        _lapCurrentData.Speed = _speedConversion * 3.6 * safeGetNumber(info.currentSpeed);
        _lapCurrentData.Pace = _lapCurrentData.Speed == 0 ? 0 : 60 / _lapCurrentData.Speed;
        _lapCurrentData.HeartRate = safeGetNumber(info.currentHeartRate);
        _lapCurrentData.ElapsedSeconds = _lapSeconds;
        // not sure how exactly this can happen but it does
        var metres = safeGetNumber(info.elapsedDistance);
        _lapMetres = metres - _startOfLapDistanceKilometres * 1000;

        var distance = _speedConversion * (metres / 1000 - _startOfLapDistanceKilometres);
        _lapCurrentData.Distance = distance >= 0 ? distance : 0;
        _lapCurrentData.GpsAccuracy = info.currentLocationAccuracy;
        _lapCurrentData.Activity = _activity;
        _lapCurrentData.IsRunning = isRunning();

        return _lapCurrentData;
    }

    function getTotalData() {
        var info = Activity.getActivityInfo();
        _overallData.IsActive = isActiveLap();
        _overallData.LapNumber = (getLap() + 1) / 2;
        // currentSpeed = metres / sec
        _overallData.Speed = _speedConversion * 3.6 * safeGetNumber(info.averageSpeed);
        _overallData.Pace = _lapCurrentData.Speed == 0 ? 0 : 60 / _lapCurrentData.Speed;
        _overallData.HeartRate = safeGetNumber(info.averageHeartRate);
        _overallData.ElapsedSeconds = safeGetNumber(info.elapsedTime) / 1000;
        _overallData.Distance = _speedConversion * safeGetNumber(info.elapsedDistance) / 1000;
        _overallData.GpsAccuracy = info.currentLocationAccuracy;
        _overallData.Activity = _activity;
        _overallData.IsRunning = isRunning();

        return _overallData;
    }

    private function getLap() {
        return _lap;
    }

    function getCurrentView() {
        return _views[_currentViewIndex];
    }

    function cycleView(offset) {
        _currentViewIndex = (_views.size() + _currentViewIndex + offset) % _views.size();
    }

    function tickSeconds() as data.LapSample {
        _lapSeconds += 1;
        return new data.LapSample(_lapSeconds, _lapMetres);
    }

    private function safeGetNumber(n) {
        return n == null ? 0 : n;
    }

    function positionCallback(info) {
    }

    function getAutoLapSummary() {
        return Lang.format("$1$, $2$", [_onLapEnd.toDisplay(), _offLapEnd.toDisplay()]);
    }
}