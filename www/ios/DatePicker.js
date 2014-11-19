/**
  Phonegap DatePicker Plugin
  https://github.com/sectore/phonegap3-ios-datepicker-plugin
  
  Copyright (c) Greg Allen 2011
  Additional refactoring by Sam de Freyssinet
  
  Rewrite by Jens Krause (www.websector.de)

  MIT Licensed
*/

var exec = require('cordova/exec');
/**
 * Constructor
 */
function DatePicker() {
    this._callback;
}

/**
 * show - true to show the ad, false to hide the ad
 */
DatePicker.prototype.show = function(options, cb) {
    var padDate = function(date) {
      if (date.length == 1) {
        return ("0" + date);
      }
      return date;
    };

    var defaults = {
        mode : 'date',
        date : -1,
        minDate: -1,
        maxDate: -1,
        minuteInterval:1,
        positiveButtonText: 'Set',
        negativeButtonText: 'Cancel',
        setDateTitle: 'Set date',
        setTimeTitle: 'Set time',
        x: '0',
        y: '0',
    };

    for (var key in defaults) {
        if (typeof options[key] !== "undefined")
            defaults[key] = options[key];
    }
    this._callback = cb;

    exec(null, 
      null, 
      "DatePicker", 
      "show",
      [defaults]
    );
};

DatePicker.prototype._dateSelected = function(date) {
    var d = new Date(parseFloat(date) * 1000);
    if (this._callback)
        this._callback(d);
}

DatePicker.prototype._dateSelectionCanceled = function() {
    if (this._callback)
        this._callback();
}



var datePicker = new DatePicker();
module.exports = datePicker;

// Make plugin work under window.plugins
if (!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.datePicker) {
    window.plugins.datePicker = datePicker;
}
