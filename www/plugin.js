var exec = require("cordova/exec");

var PLUGIN_NAME = "epos2";

/**
 * Wrapper for cordova exec() returning a promise
 * and considering the optional callback arguments
 *
 * @param {String} cmd Plugin command to execute
 * @param {Array} args Command arguments to send
 * @param {Array} callbackArgs List of arguments with callback functions (the last element is considered the errorCallback, the second-to-last the successCallback)
 * @return {Promise}
 */
function _exec(cmd, args, callbackArgs) {
	var _successCallback, _errorCallback;
	if (
		callbackArgs.length > 1 &&
		typeof callbackArgs[callbackArgs.length - 1] === "function"
	) {
		_errorCallback = callbackArgs[callbackArgs.length - 1];
	}
	if (
		callbackArgs.length > 0 &&
		typeof callbackArgs[callbackArgs.length - 2] === "function"
	) {
		_successCallback = callbackArgs[callbackArgs.length - 2];
	}

	return new Promise(function (resolve, reject) {
		// call cordova/exec
		exec(
			function (result) {
				if (_successCallback) {
					_successCallback(result);
				}
				resolve(result);
			},
			function (err) {
				if (_errorCallback) {
					_errorCallback(err);
				}
				reject(new Error(err));
			},
			PLUGIN_NAME,
			cmd,
			args
		);
	});
}

function execDiscoverCommand(successCallback, errorCallback) {
	exec(
		function (result) {
			if (typeof successCallback === "function") {
				successCallback(result);
			}
		},
		function (err) {
			if (typeof errorCallback === "function") {
				errorCallback(err);
			}
		},
		PLUGIN_NAME,
		"startDiscover",
		[]
	);
}

/**
 * Epson EPOS2 Cordova plugin interface
 *
 * This is the plugin interface exposed to cordova.epos2
 */
var epos2 = {
	/**
	 * Set language for printer
	 *
	 * @param {String} lang
	 * @param {String} textLang
	 * @return {Promise}
	 */
	setLang: function (lang, textLang) {
		var args = [];
		if (lang && typeof lang === "string") {
			args.push(lang);
		}
		if (textLang && typeof textLang === "string") {
			args.push(textLang);
		}
		return _exec("setLang", args, arguments);
	},

	/**
	 * Start device discovery
	 *
	 * This will trigger the successCallback function for every
	 * device detected to be available for printing. The device info
	 * is provided as single argument to the callback function.
	 *
	 * @param {Function} successCallback
	 * @param {Function} [errorCallback]
	 * @return {Promise} resolves when the first device is detected or rejects if operation times out
	 */
	startDiscover: function (successCallback, errorCallback) {
		execDiscoverCommand(successCallback, errorCallback);
	},

	/**
	 * Stop running device discovery
	 *
	 * @param {Function} [successCallback]
	 * @param {Function} [errorCallback]
	 * @return {Promise}
	 */
	stopDiscover: function (successCallback, errorCallback) {
		return _exec("stopDiscover", [], arguments);
	},

	/**
	 * Attempt to connect the given printing device
	 *
	 * Only if the promise resolves, the printer connection has been established
	 * and the plugin is ready to sent print commands. If connection fails, the
	 * promise rejects and printing is not possible.
	 *
	 * @param {Object|String} device Device information as retrieved from discovery
	 *          or string with device address ('BT:xx:xx:xx:xx:xx' or 'TCP:xx.xx.xx.xx')
	 * @param {String}   printerModel The printer series/model (e.g. 'TM-T88VI') as listed by `getSupportedModels()`
	 * @param {Function} [successCallback]
	 * @param {Function} [errorCallback]
	 * @return {Promise}
	 */
	connectPrinter: function (device, printerModel) {
		var args = [];
		if (typeof device === "object" && device.target) {
			args.push(device.target);
		} else {
			args.push(device);
		}
		if (printerModel && typeof printerModel === "string") {
			args.push(printerModel);
		}
		return _exec("connectPrinter", args, arguments);
	},

	/**
	 * Disconnect a previously connected printer
	 *
	 * @param {Function} [successCallback]
	 * @param {Function} [errorCallback]
	 * @return {Promise}
	 */
	disconnectPrinter: function (successCallback, errorCallback) {
		return _exec("disconnectPrinter", [], arguments);
	},

	/**
	 * Send a print job to the connected printer
	 *
	 * This command is limited to print text and implicitly sends some additional
	 * line feeds an a "cut" command after the given text data to complete the job.
	 *
	 * @param {Array} data List of strings to be printed as text. Use '\n' to feed paper for one line.
	 * @param {Function} [successCallback]
	 * @param {Function} [errorCallback]
	 * @return {Promise} resolving on success, rejecting on error
	 * @deprecated Use dedicated methods like `printText()` or `printImage()`
	 */
	print: function (data, successCallback, errorCallback) {
		return _exec("printText", [data, 0, 1, 0], [])
			.then(function () {
				return _exec("sendData", [], []);
			})
			.then(function (result) {
				if (typeof successCallback === "function") {
					successCallback(result);
				}
			})
			.catch(function (err) {
				if (typeof errorCallback === "function") {
					errorCallback(err);
				}
				throw err;
			});
	},

	/**
	 * Send Line data to the connected printer
	 *
	 * Set `terminate` to True in order to complete the print job.
	 *
	 * @param {Number} Specifies the start position to draw a horizontal ruled line (in dots). 0 to 65535 
	 * @param {Number} Specifies the end position to draw a horizontal ruled line (in dots). 0 to 65535
	 * @param {Number} Specifies the ruled line type.
	 * @param {Boolean} [terminate=false] Send additional line feeds an a "cut" command to complete the print
	 * @param {Function} [successCallback]
	 * @param {Function} [errorCallback]
	 * @return {Promise} resolving on success, rejecting on error
	 */
	printLine: function (
		startx,
		endx,
		linestyle,
		terminate,
		successCallback,
		errorCallback
	) {
		return _exec("printLine", [startx || 0, endx || 100, linestyle || 0], arguments)
			.then(function (result) {
				return terminate ? _exec("sendData", [], []) : result;
			})
			.then(function (result) {
				if (typeof successCallback === "function") {
					successCallback(result);
				}
			})
			.catch(function (err) {
				if (typeof errorCallback === "function") {
					errorCallback(err);
				}
				throw err;
			});
	},

	/**
	 * Get status information about the connected printer
	 *
	 * Status object will be returned as the single argument to the `successCallback` function if provided.
	 *
	 * @param {Function} [successCallback]
	 * @param {Function} [errorCallback]
	 * @return {Promise} resolving with the printer status information
	 */
	getPrinterStatus: function (successCallback, errorCallback) {
		return _exec("getPrinterStatus", [], arguments);
	},

	/**
	 * List the device models supported by the driver
	 *
	 * Will be returned as the single argument to the `successCallback` function if provided.
	 *
	 * @param {Function} [successCallback]
	 * @param {Function} [errorCallback]
	 * @return {Promise} resolving with the list of model names
	 */
	getSupportedModels: function (successCallback, errorCallback) {
		return _exec("getSupportedModels", [], arguments);
	},

	// *******************************************************************************************

	addTextAlign(align) {
		return _exec("addTextAlign", [align || 0], arguments);
	},

	addLineSpace(space) {
		return _exec("addLineSpace", [space || 0], arguments);
	},

	addText(text) {
		return _exec("addText", [text || ""], arguments);
	},

	async addInvertedText(text) {
		await this.addTextStyle(1);
		await this.addText(text);
		await this.addTextStyle(0);
	},

	addTextFont(font) {
		return _exec("addTextFont", [font || 0], arguments);
	},

	addTextSize(width, height) {
		return _exec("addTextSize", [width || 1, height || 1], arguments);
	},

	addTextStyle(reverse, ul, em, color) {
		return _exec("addTextStyle", [reverse || 0, ul || 0, em || 0, color || 0], arguments);
	},

	addFeedLine(line) {
		return _exec("addFeedLine", [line || 1], arguments);
	},

	addFeedPosition(position) {
		return _exec("addFeedPosition", [position || 0], arguments);
	},

	addHLine(x1, x2, style) {
		return _exec("addHLine", [x1 || 0, x2 || 100, style || 0], arguments);
	},

	addSymbol(symbol, type, level, width, height, size) {
		return _exec("addSymbol", [symbol || "", type || 0, level || 0, width || 0, height || 0, size || 0], arguments);
	},

	addPageBegin() {
		return _exec("addPageBegin", [], arguments);
	},

	addPageEnd() {
		return _exec("addPageEnd", [], arguments);
	},

	addPageArea(x, y, width, height) {
		return _exec("addPageArea", [x || 0, y || 0, width || 100, height || 100], arguments);
	},

	addPageDirection(direction) {
		return _exec("addPageDirection", [direction || 0], arguments);
	},

	addPagePosition(x, y) {
		return _exec("addPagePosition", [x || 0, y || 0], arguments);
	},

	addPageLine(x1, y1, x2, y2, style) {
		return _exec("addPageLine", [x1 || 0, y1 || 0, x2 || 100, y2 || 100, style || 0], arguments);
	},

	addPageRectangle(x1, y1, x2, y2, style, width) {
		return _exec("addPageRectangle", [x1 || 0, y1 || 0, x2 || 100, y2 || 100, style || 0, width || 0], arguments);
	},

	addCut(type) {
		return _exec("addCut", [type || 0], arguments);
	},

	addPulse(drawer, time) {
		return _exec("addPulse", [drawer || 0, time || 0], arguments);
	},

	sendData() {
		return _exec("sendData", [], arguments);
	}
};

module.exports = epos2;
