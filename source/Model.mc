using Toybox.Activity;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Attention;
using Toybox.FitContributor;
using Toybox.ActivityRecording;

class Model
{
    hidden var mTimer;
    hidden var mSession;
    hidden var mLapTimer;
    hidden var mLap;
    hidden var mLapSeconds;
    hidden var mStartOfLapDistanceInKms;
    hidden var mActivity;
    hidden var mIsRunning;

    hidden var mGpsAccuracy;
    hidden var mLapCurrentData;
    hidden var mOverallData;

    enum {
       Lap,
       Total
    }

    hidden var mViews = [Lap, Total];
    hidden var mCurrentViewIndex;

    hidden static var mAllSensorsByActivityType = {
        ActivityRecording.SPORT_RUNNING => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_CYCLING => [Sensor.SENSOR_BIKESPEED, Sensor.SENSOR_BIKECADENCE, Sensor.SENSOR_BIKEPOWER, Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_SWIMMING => [Sensor.SENSOR_TEMPERATURE],
        ActivityRecording.SPORT_GENERIC => [Sensor.SENSOR_HEARTRATE, Sensor.SENSOR_FOOTPOD, Sensor.SENSOR_TEMPERATURE]
    };

    function initialize() {
        mLap = 0;
        mLapSeconds = 0;
        mStartOfLapDistanceInKms = 0;
        mCurrentViewIndex = 0;
        mActivity = null;
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:positionCallback));
        setActivity(ActivityRecording.SPORT_RUNNING);
        mLapCurrentData = new data.ViewDataset();
        mOverallData = new data.ViewDataset();
        mGpsAccuracy = null;
    }

    function setActivity(activity) {
        mActivity = activity;
        Sensor.setEnabledSensors(mAllSensorsByActivityType[mActivity]);
    }

    function start() {
        if (!hasStarted()) {
            mSession = ActivityRecording.createSession({:sport=>mActivity, :name=>"Intervals"});
            mLap = 1;
            mLapTimer = new Timer.Timer();
            mLapTimer.start(method(:lapCallback), 1000, true);
        }
        mSession.start();
        mIsRunning = true;
    }

    function stop() {
        mLapTimer.stop();
        mSession.stop();
        mIsRunning = false;
    }

    function resume() {
        mSession.start();
        mLapTimer.start(method(:lapCallback), 1000, true);
        mIsRunning = true;
    }

    // creates a lap. if it is an odd lap the sensor data is turned off
    function startLap() {
        mLap++;
        mLapSeconds = 0;
        mLapTimer.stop();
        mSession.addLap();
        if (isActiveLap()) {
            Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:positionCallback));
        } else {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:positionCallback));
        }
        var info = Activity.getActivityInfo();
        mStartOfLapDistanceInKms = safeGetNumber(info.elapsedDistance) / 1000;
        mLapTimer.start(method(:lapCallback), 1000, true);
    }

    function hasStarted() {
        return mLap > 0;
    }

    function isActiveLap() {
        return (mLap % 2) == 1;
    }

    function isRunning() {
        return mIsRunning;
    }

    function save() {
        mSession.save();
    }

    function discard() {
        mSession.discard();
    }

    function getLapData() {
        var info = Activity.getActivityInfo();
        mLapCurrentData.IsActive = isActiveLap();
        mLapCurrentData.LapNumber = (getLap() + 1) / 2;
        // currentSpeed = metres / sec
        mLapCurrentData.SpeedInKmsPerHour = 360 * safeGetNumber(info.currentSpeed) / 1000;
        mLapCurrentData.PaceInMinsPerKm = mLapCurrentData.SpeedInKmsPerHour == 0 ? 0 : 60 / mLapCurrentData.SpeedInKmsPerHour;
        mLapCurrentData.HeartRate = safeGetNumber(info.currentHeartRate);
        mLapCurrentData.ElapsedSeconds = mLapSeconds;
        mLapCurrentData.DistanceInKms = (safeGetNumber(info.elapsedDistance) / 1000) - mStartOfLapDistanceInKms;
        mLapCurrentData.GpsAccuracy = info.currentLocationAccuracy;
        mLapCurrentData.Activity = mActivity;

        return mLapCurrentData;
    }

    function getTotalData() {
        var info = Activity.getActivityInfo();
        mOverallData.IsActive = isActiveLap();
        mOverallData.LapNumber = (getLap() + 1) / 2;
        // currentSpeed = metres / sec
        mOverallData.SpeedInKmsPerHour = 360 * safeGetNumber(info.averageSpeed) / 1000;
        mOverallData.PaceInMinsPerKm = mLapCurrentData.SpeedInKmsPerHour == 0 ? 0 : 60 / mLapCurrentData.SpeedInKmsPerHour;
        mOverallData.HeartRate = safeGetNumber(info.averageHeartRate);
        mOverallData.ElapsedSeconds = safeGetNumber(info.elapsedTime) / 1000;
        mOverallData.DistanceInKms = safeGetNumber(info.elapsedDistance) / 1000;
        mOverallData.GpsAccuracy = info.currentLocationAccuracy;
        mOverallData.Activity = mActivity;

        return mOverallData;
    }

    private function getLap() {
        return mLap;
    }

    function getCurrentView() {
        return mViews[mCurrentViewIndex];
    }

    function cycleView(offset) {
        mCurrentViewIndex = (mViews.size() + mCurrentViewIndex + offset) % mViews.size();
    }

    private function lapCallback() {
        mLapSeconds++;
    }

    private function safeGetNumber(n) {
        return n == null ? 0 : n;
    }

    private function positionCallback(info) {
    }
}