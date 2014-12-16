
var exec = require('cordova/exec');
/**
 * Constructor
 */
function DatePickerPlugin() {
    this._callback;
}

DatePickerPlugin.prototype.show = function(options, cb) {
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
        y: '0'
    };

    for (var key in defaults) {
        if (typeof options[key] !== "undefined"){
          defaults[key] = options[key];
        }
    }

    this._callback = cb;

    exec(null, 
      null, 
      "DatePickerPlugin", 
      "show",
      [defaults]);
};

DatePickerPlugin.prototype._dateSelected = function(date) {
    var d = new Date(parseFloat(date) * 1000);
    if (this._callback){
      this._callback(d);
    }
};

DatePickerPlugin.prototype._dateSelectionCanceled = function() {
    if (this._callback){
      this._callback();
    }
};

var datePickerPlugin = new DatePickerPlugin();
module.exports = datePickerPlugin;

// Make plugin work under window.plugins
if (!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.datePickerPlugin) {
    window.plugins.datePickerPlugin = datePickerPlugin;
}
