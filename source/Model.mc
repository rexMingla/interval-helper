using Toybox.Activity;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Attention;
using Toybox.Timer;
using Toybox.FitContributor;
using Toybox.ActivityRecording;
using Toybox.Sensor;
import Toybox.Lang;

enum ViewType {
    Lap,
    Total
}

enum RecordingMode {
    NoRecord,
    RecordNoGps,
    RecordWithGps
}

class Model
{
    hidden var _timer as Timer.Timer or Null;
    hidden var _session as ActivityRecording.Session or Null;
    hidden var _lapTimer as Timer.Timer or Null;
    hidden var _lap as Number;
    hidden var _lapSeconds as Number;
    hidden var _isActive as Boolean;
    hidden var _startOfLapDistance as Number;
    hidden var _activity as Activity or Null;
    hidden var _offLapRecordingMode as RecordingMode or Null;
    hidden var _isRunning as Boolean = false;
    hidden var _speedConversion as Double;

    hidden var _lapCurrentData as data.ViewDataset;
    hidden var _overallData as data.ViewDataset;

    hidden var _views as Array<ViewType> = [Lap, Total] as Array<ViewType>;
    hidden var _currentViewIndex as Number;

    hidden const KmsToMiles as Float = 0.621371;

    hidden static var mAllSensorsByActivityType as Dictionary<Activity.Sport, Array<Sensor.SensorType>> = {
        Activity.SPORT_RUNNING => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        Activity.SPORT_CYCLING => [Sensor.SENSOR_BIKESPEED, Sensor.SENSOR_BIKECADENCE, Sensor.SENSOR_BIKEPOWER, Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        Activity.SPORT_SWIMMING => [Sensor.SENSOR_TEMPERATURE],
        Activity.SPORT_GENERIC => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE]
    } as Dictionary<Activity.Sport, Array<Sensor.SensorType>>;

    function initialize() {
        _lap = 0;
        _isActive = true;
        _lapSeconds = 0;
        _startOfLapDistance = 0;
        _currentViewIndex = 0;
        _activity = null;
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:positionCallback));

        var activity = Application.getApp().getProperty("activity");
        setActivity(activity != null ? activity as Activity : ActivityRecording.SPORT_RUNNING);
        _lapCurrentData = new data.ViewDataset();
        _overallData = new data.ViewDataset();
        _speedConversion = System.getDeviceSettings().paceUnits == System.UNIT_METRIC ? 1 : KmsToMiles;
        _isRunning = false;

        var offLapMode = Application.getApp().getProperty("offLapRecordingMode");
        offLapMode = offLapMode != null ? offLapMode : NoRecord;
        setOffLapRecordingMode(offLapMode);
    }

    function setActivity(activity as Activity) as Void {
        _activity = activity;
        Sensor.setEnabledSensors(mAllSensorsByActivityType[_activity]);
        Application.getApp().setProperty("activity", _activity);
    }

    function getActivity() as Activity {
        return _activity;
    }

    function setOffLapRecordingMode(offLapMode as RecordingMode) as Void {
        _offLapRecordingMode = offLapMode;
        Application.getApp().setProperty("offLapRecordingMode", _offLapRecordingMode);
    }

    function offLapRecordingMode() as Boolean {
        return _offLapRecordingMode;
    }

    function start() as Void {
        if (!hasStarted()) {
            _session = ActivityRecording.createSession({:sport=>_activity, :name=>"Intervals"});
            _lap = 1;
            _lapTimer = new Timer.Timer();
            _lapTimer.start(method(:lapCallback), 1000, true);
        }
        // force it back on because Garmin turns it off
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:positionCallback));
        _session.start();
        _isRunning = true;
    }

    function stop() as Void {
        _lapTimer.stop();
        _session.stop();
        _isRunning = false;
    }

    function startLap() as Void {
        _lap++;
        _lapSeconds = 0;
        _isActive = !_isActive;
        var info = Activity.getActivityInfo();
        _startOfLapDistance = safeGetNumber(info.elapsedDistance) / 1000;
        _lapTimer.stop();
        if (isActiveLap()) {
            _session.addLap();
            start();
        } else {
           if (_offLapRecordingMode == NoRecord) {
                _session.stop();
           } else {
                _session.addLap();
                if (_offLapRecordingMode == RecordNoGps) {
                    Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:positionCallback));
                }
           }
        }
        _lapTimer.start(method(:lapCallback), 1000, true);
    }

    function hasStarted() as Boolean {
        return _lap > 0;
    }

    function isActiveLap() as Boolean {
        return _isActive;
    }

    function isRunning() as Boolean {
        return _isRunning;
    }

    function save() as Void {
        _session.save();
    }

    function discard() as Void {
        _session.discard();
    }

    function getLapData() as data.ViewDataset {
        var info = Activity.getActivityInfo();
        _lapCurrentData.IsActive = isActiveLap();
        _lapCurrentData.LapNumber = (getLap() + 1) / 2;
        // currentSpeed = metres / sec
        _lapCurrentData.Speed = _speedConversion * 3.6 * safeGetNumber(info.currentSpeed);
        _lapCurrentData.Pace = _lapCurrentData.Speed == 0 ? 0 : 60 / _lapCurrentData.Speed;
        _lapCurrentData.HeartRate = safeGetNumber(info.currentHeartRate);
        _lapCurrentData.ElapsedSeconds = _lapSeconds;
        // not sure how exactly this can happen but it does
        var distance = _speedConversion * (safeGetNumber(info.elapsedDistance) / 1000) - _startOfLapDistance;
        _lapCurrentData.Distance = distance >= 0 ? distance : 0;
        _lapCurrentData.GpsAccuracy = info.currentLocationAccuracy;
        _lapCurrentData.Activity = _activity;
        _lapCurrentData.IsRunning = isRunning();

        return _lapCurrentData;
    }

    function getTotalData() as data.ViewDataset {
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

    private function getLap() as Number {
        return _lap;
    }

    function getCurrentView() as ViewType {
        return _views[_currentViewIndex];
    }

    function cycleView(offset) as ViewType {
        _currentViewIndex = (_views.size() + _currentViewIndex + offset) % _views.size();
    }

    function lapCallback() as Void {
        _lapSeconds++;
    }

    private function safeGetNumber(n as Double) as Double {
        return n == null ? 0 : n;
    }

    function positionCallback(info) as Void {
    }
}