package com.zyramedia.cordova.linkedin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.linkedin.*;

/**
 * This class echoes a string called from JavaScript.
 */
public class LinkedIn extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("init")) {
            this.init(args, callbackContext);
        } else if(action.equals("initWithAccessToken")) {
            this.initWithAccessToken(args, callbackContext);
        } else {
            return false;
        }
        return true;
    }

    private void init(JSONArray args, CallbackContext callbackContext) {

    }

    private void initWithAccessToken(JSONArray args, CallbackContext callbackContext) {

    }
}
