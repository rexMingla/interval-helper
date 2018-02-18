using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class IntervalApp extends App.AppBase {

    private var _model;
    private var _controller;

    function initialize() {
        AppBase.initialize();
        _model = new $.Model();
        _controller = new $.Controller();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new view.MainView(), new delegate.MainDelegate() ];
    }

    function getController() {
        return _controller;
    }

    function getModel() {
        return _model;
    }
}