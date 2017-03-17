var exec = require('cordova/exec');

module.exports = {

    login: function (scopes, promptToInstall, success, error) {
        exec(success, error, "LinkedIn", "login", [scopes, promptToInstall]);
    },

    logout: function () {
        exec(null, null, "LinkedIn", "logout", []);
    },

    getRequest: function (url, success, error) {
        exec(success, error, "LinkedIn", "getRequest", [url]);
    },

    postRequest: function (url, body, success, error) {
        exec(success, error, "LinkedIn", "postRequest", [url, body]);
    },

    openProfile: function (memberId, success, error) {
        exec(success, error, "LinkedIn", "openProfile", [memberId]);
    },

    hasActiveSession: function (success, error) {
        exec(success, error, "LinkedIn", "hasActiveSession", []);
    }

};
