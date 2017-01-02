var exec = require('cordova/exec');

module.exports = {

    initWithAccessToken: function(accessToken, success, error) {
        exec(success, error, "LinkedIn", "initWithAccessToken", [accessToken]);
    },

    init: function(success, error) {
        exec(success, error, "LinkedIn", "init", []);
    }

};