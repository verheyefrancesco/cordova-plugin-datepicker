/**
 * Constructor
 */
function DatePicker() {
}

DatePicker.prototype.show = function(options, cb) {
  
	var defaults = {
        mode : 'date',
        date : -1,
        minDate: -1,
        maxDate: -1,
        minuteInterval:1,
        positiveButtonText: 'Set',
        negativeButtonText: 'Cancel',
        setDateTitle: 'Set date',
        setTimeTitle: 'Set time'
    };

	for (var key in defaults) {
		if (typeof options[key] !== "undefined") {
			defaults[key] = options[key];
		}
	}

	var callback = function(message) {
		var timestamp = Date.parse(message);
		if(isNaN(timestamp) === false) {
			cb(new Date(message));
		}
	};
  
	cordova.exec(callback, 
		null, 
		"DatePickerPlugin", 
		defaults.mode,
		[defaults]);
};

var datePicker = new DatePicker();
module.exports = datePicker;

// Make plugin work under window.plugins
if (!window.plugins) {
    window.plugins = {};
}
if (!window.plugins.datePicker) {
    window.plugins.datePicker = datePicker;
}