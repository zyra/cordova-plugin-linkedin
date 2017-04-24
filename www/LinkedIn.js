var exec = require('cordova/exec');

function callNativeMethod(name, args, success, error) {
    args = args || [];
    success = success || function(){};
    error = error || function(){};
    exec(success, error, 'LinkedIn', name, args);
}

module.exports = {

    login: function (scopes, promptToInstall, success, error) {
        callNativeMethod('login', [scopes,  promptToInstall], success, error);
    },

    logout: function () {
        callNativeMethod('logout');
    },

    getRequest: function (url, success, error) {
        callNativeMethod('getRequest', [url], success, error);
    },

    postRequest: function (url, body, success, error) {
        callNativeMethod('postRequest', [url, body], success, error);
    },

    openProfile: function (memberId, success, error) {
        callNativeMethod('openProfile', [memberId], success, error);
    },

    hasActiveSession: function (success, error) {
        callNativeMethod('hasActiveSession', null, success, error);
    },

    getActiveSession: function (success, error) {
        callNativeMethod('getActiveSession', null, success, error);
    }

};
