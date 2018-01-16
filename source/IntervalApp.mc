using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class IntervalApp extends App.AppBase {

    var model;
    var controller;

    function initialize() {
        AppBase.initialize();
        model = new $.Model();
        controller = new $.Controller();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new view.MainView(), new delegate.MainDelegate() ];
    }
}