import Toybox.Lang;
import Toybox.Position;
using Toybox.Activity;
using Toybox.Application;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Timer;
using Toybox.ActivityRecording;

class Model
{
    hidden var _session as ActivityRecording.Session or Null = null;
    hidden var _lapTimer as Timer.Timer = new Timer.Timer();
    hidden var _lap as Number = 0;
    hidden var _lapSeconds as Number = 0;
    hidden var _isActive as Boolean = true;
    hidden var _startOfLapDistance as Numeric = 0;
    hidden var _activity as Number = SPORT_RUNNING;
    hidden var _offLapRecordingMode as Number = NoRecord;
    hidden var _isRunning as Boolean = false;
    hidden var _speedConversion as Numeric = 1;

    hidden var _lapCurrentData as data.ViewDataset = new data.ViewDataset();
    hidden var _overallData as data.ViewDataset = new data.ViewDataset();

    hidden var _views as Array<Number> = [Lap, Total];
    hidden var _currentViewIndex as Number = 0;

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

    // Sport values from the FIT sport enum. Activity.SPORT_* does not exist on API 3.0/3.1 devices and
    // ActivityRecording.SPORT_* is deprecated, so the values are defined here.
    enum {
        SPORT_GENERIC = 0,
        SPORT_RUNNING = 1,
        SPORT_CYCLING = 2,
        SPORT_SWIMMING = 5
    }

    hidden static var mAllSensorsByActivityType as Dictionary<Number, Array<Sensor.OnboardSensorType or Sensor.RemoteSensorType>> = {
        SPORT_RUNNING => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        SPORT_CYCLING => [Sensor.SENSOR_BIKESPEED, Sensor.SENSOR_BIKECADENCE, Sensor.SENSOR_BIKEPOWER, Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        SPORT_SWIMMING => [Sensor.SENSOR_TEMPERATURE],
        SPORT_GENERIC => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE]
    };

    function initialize() {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:positionCallback));

        var activity = Application.Storage.getValue("activity") as Number or Null;
        setActivity(activity != null ? activity : SPORT_RUNNING);
        _speedConversion = System.getDeviceSettings().paceUnits == System.UNIT_METRIC ? 1 : KmsToMiles;

        var offLapMode = Application.Storage.getValue("offLapRecordingMode") as Number or Null;
        setOffLapRecordingMode(offLapMode != null ? offLapMode : NoRecord);
    }

    function setActivity(activity as Number) as Void {
        _activity = activity;
        Sensor.setEnabledSensors(mAllSensorsByActivityType[_activity] as Array<Sensor.OnboardSensorType or Sensor.RemoteSensorType>);
        Application.Storage.setValue("activity", _activity);
    }

    function getActivity() as Number {
        return _activity;
    }

    function setOffLapRecordingMode(offLapMode as Number) as Void {
        _offLapRecordingMode = offLapMode;
        Application.Storage.setValue("offLapRecordingMode", _offLapRecordingMode);
    }

    function offLapRecordingMode() as Number {
        return _offLapRecordingMode;
    }

    function start() as Void {
        var session = _session;
        if (session == null) {
            session = ActivityRecording.createSession({:sport=>_activity as Activity.Sport, :name=>"Intervals"});
            _session = session;
            _lap = 1;
        }
        // force it back on because Garmin turns it off
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:positionCallback));
        session.start();
        _isRunning = true;
        // stop() halts the lap timer, so resuming (and a new active lap) must restart it
        restartLapTimer();
    }

    private function restartLapTimer() as Void {
        _lapTimer.stop();
        _lapTimer.start(method(:lapCallback), 1000, true);
    }

    // Garmin also turns location events off whenever the app goes inactive (e.g. screen off).
    // Re-assert them, unless GPS is deliberately off for a recovery lap.
    function enableGps() as Void {
        if (hasStarted() && !isActiveLap() && _offLapRecordingMode == RecordNoGps) {
            return;
        }
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:positionCallback));
    }

    function stop() as Void {
        _lapTimer.stop();
        var session = _session;
        if (session != null) {
            session.stop();
        }
        _isRunning = false;
    }

    function startLap() as Void {
        var session = _session;
        if (session == null) {
            return;
        }
        _lap++;
        _lapSeconds = 0;
        _isActive = !_isActive;
        _startOfLapDistance = getElapsedDistanceKm();
        _lapTimer.stop();
        if (isActiveLap()) {
            session.addLap();
            start();
        } else {
            if (_offLapRecordingMode == NoRecord) {
                session.stop();
            } else {
                session.addLap();
                if (_offLapRecordingMode == RecordNoGps) {
                    Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:positionCallback));
                }
            }
            // off lap seconds keep counting even when the session is stopped
            restartLapTimer();
        }
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
        var session = _session;
        if (session != null) {
            session.save();
        }
    }

    function discard() as Void {
        var session = _session;
        if (session != null) {
            session.discard();
        }
    }

    function getLapData() as data.ViewDataset {
        var data = _lapCurrentData;
        data.IsActive = isActiveLap();
        data.LapNumber = (getLap() + 1) / 2;
        data.ElapsedSeconds = _lapSeconds;
        data.Activity = _activity;
        data.IsRunning = isRunning();

        var info = Activity.getActivityInfo();
        // currentSpeed = metres / sec
        data.Speed = _speedConversion * 3.6 * safeGetNumber(info.currentSpeed);
        data.Pace = data.Speed == 0 ? 0 : 60 / data.Speed;
        data.HeartRate = safeGetNumber(info.currentHeartRate);
        // both distances are in km; convert to the user's unit after subtracting
        // (not sure how exactly it can go negative but it does)
        var distance = _speedConversion * (getElapsedDistanceKm() - _startOfLapDistance);
        // > 0 rather than >= 0 so that -0.0 is also replaced
        data.Distance = distance > 0 ? distance : 0;
        data.GpsAccuracy = info.currentLocationAccuracy;

        return data;
    }

    function getTotalData() as data.ViewDataset {
        var data = _overallData;
        data.IsActive = isActiveLap();
        data.LapNumber = (getLap() + 1) / 2;
        data.Activity = _activity;
        data.IsRunning = isRunning();

        var info = Activity.getActivityInfo();
        // averageSpeed = metres / sec
        data.Speed = _speedConversion * 3.6 * safeGetNumber(info.averageSpeed);
        data.Pace = data.Speed == 0 ? 0 : 60 / data.Speed;
        data.HeartRate = safeGetNumber(info.averageHeartRate);
        data.ElapsedSeconds = (safeGetNumber(info.elapsedTime) / 1000).toNumber();
        var distance = _speedConversion * getElapsedDistanceKm();
        data.Distance = distance > 0 ? distance : 0;
        data.GpsAccuracy = info.currentLocationAccuracy;

        return data;
    }

    private function getLap() as Number {
        return _lap;
    }

    function getCurrentView() as Number {
        return _views[_currentViewIndex];
    }

    function cycleView(offset as Number) as Void {
        _currentViewIndex = (_views.size() + _currentViewIndex + offset) % _views.size();
    }

    function lapCallback() as Void {
        _lapSeconds++;
    }

    private function getElapsedDistanceKm() as Numeric {
        return safeGetNumber(Activity.getActivityInfo().elapsedDistance) / 1000;
    }

    private function safeGetNumber(n as Numeric or Null) as Numeric {
        if (n == null) {
            return 0;
        }
        return n;
    }

    function positionCallback(info as Position.Info) as Void {
    }
}
