using Toybox.Application as App;
using Toybox.WatchUi as Ui;
import Toybox.Lang;

class IntervalApp extends App.AppBase {

    private var _model as Model;
    private var _controller as Controller;

    function initialize() {
        AppBase.initialize();
        _model = new $.Model();
        _controller = new $.Controller();
    }

    function onStart(state as Dictionary) {
    }

    function onStop(state as Dictionary) {
    }

    function getInitialView() as Void {
        return [ new view.MainView(), new delegate.MainDelegate() ];
    }

    function getController() as Controller {
        return _controller;
    }

    function getModel() as Model {
        return _model;
    }
}