package com.zyramedia.cordova.linkedin;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.telecom.Call;
import android.util.Log;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.PluginResult;

import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.linkedin.platform.*;
import com.linkedin.platform.errors.LIApiError;
import com.linkedin.platform.errors.LIAuthError;
import com.linkedin.platform.errors.LIDeepLinkError;
import com.linkedin.platform.listeners.ApiListener;
import com.linkedin.platform.listeners.ApiResponse;
import com.linkedin.platform.listeners.AuthListener;
import com.linkedin.platform.listeners.DeepLinkListener;
import com.linkedin.platform.utils.Scope;
import com.linkedin.platform.utils.Scope.LIPermission;

import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.List;

public class LinkedIn extends CordovaPlugin {

    private final String TAG = "--  CordovaLinkedIn  --";

    private LISessionManager liSessionManager;
    private Activity activity;
    private Context context;
    private APIHelper apiHelper;

    private final String API_PATH = "https://api.linkedin.com/v1/";

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        activity = cordova.getActivity();
        context = activity.getApplicationContext();
        apiHelper = APIHelper.getInstance(context);
        liSessionManager = LISessionManager.getInstance(context);
    }

    @Override
    public boolean execute(final String action, JSONArray args, CallbackContext callbackContext) throws JSONException {

        // make sure we have a registered callback
        cordova.setActivityResultCallback(this);

        if (action.equals("login")) {
            init(args, callbackContext);
        } else if(action.equals("logout")) {
            logout();
        } else if(action.equals("openProfile")) {
            openProfile(args, callbackContext);
        } else if(action.equals("getRequest")) {
            getRequest(args, callbackContext);
        } else if(action.equals("postRequest")) {
            postRequest(args, callbackContext);
        } else if(action.equals("hasActiveSession")) {
            hasActiveSession(callbackContext);
        } else if(action.equals("getActiveSession")) {
            getActiveSession(callbackContext);
        } else {
            return false;
        }
        return true;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        liSessionManager.onActivityResult(activity, requestCode, resultCode, intent);
    }

    private void logout() {
        liSessionManager.clearSession();
    }

    private Scope processScopes(final JSONArray scopesAsJson) {
        List<String> scopes = new ArrayList<String>();
        try {
            if (scopesAsJson != null) {
                int len = scopesAsJson.length();
                for (int i = 0; i < len; i++) {
                    scopes.add(scopesAsJson.getString(i));
                }
            }
        } catch (JSONException e) {
            Log.d(TAG, e.getMessage());
        }
        LIPermission[] permissions = new LIPermission[scopes.size()];
        int nextIndex = 0;
        for(String scope: scopes) {
            permissions[nextIndex] = new LIPermission(scope, "");
            nextIndex++;
        }
        Scope scope = null;
        Method m;
        try {
            m = Scope.class.getDeclaredMethod("build", LIPermission[].class);
            scope = (Scope) m.invoke(null, new Object[] {permissions});
        } catch (Exception e) {
            e.printStackTrace();
        }
        return scope;
    }

    private void init(final JSONArray args, final CallbackContext callbackContext) {
        try {
            liSessionManager.init(activity, processScopes(args.getJSONArray(0)), new AuthListener() {
                @Override
                public void onAuthSuccess() {
                    callbackContext.success();
                }

                @Override
                public void onAuthError(LIAuthError liAuthError) {
                    callbackContext.error(liAuthError.toString());
                }
            }, args.getBoolean(1));
        } catch (JSONException e) {
            Log.e(TAG, e.getMessage());
            callbackContext.error(e.getMessage());
        }
    }

    private void openProfile(final JSONArray args, final CallbackContext callbackContext) {
        try {
            final String memberId = args.getString(0);
            final DeepLinkHelper deepLinkHelper = DeepLinkHelper.getInstance();
            deepLinkHelper.openOtherProfile(activity, memberId, new DeepLinkListener() {
                @Override
                public void onDeepLinkSuccess() {
                    callbackContext.success();
                }

                @Override
                public void onDeepLinkError(LIDeepLinkError liDeepLinkError) {
                    callbackContext.error(liDeepLinkError.toString());
                }
            });
        } catch (JSONException e) {
            callbackContext.error(e.getMessage());
        }
    }

    private ApiListener getApiListener(final CallbackContext callbackContext) {
        return new ApiListener() {
            @Override
            public void onApiSuccess(ApiResponse apiResponse) {
                try {
                    callbackContext.success(apiResponse.getResponseDataAsJson());
                } catch (Exception e) {
                    callbackContext.success(apiResponse.getResponseDataAsString());
                }
            }

            @Override
            public void onApiError(LIApiError liApiError) {
                if (liApiError.getApiErrorResponse() != null) {
                    callbackContext.error(liApiError.getApiErrorResponse().getMessage());
                } else {
                    liApiError.getMessage();
                }
            }
        };
    }

    private void getRequest(final JSONArray args, CallbackContext callbackContext) {
        try {
            final String url = args.getString(0);
            apiHelper.getRequest(context, API_PATH + url, this.getApiListener(callbackContext));
        } catch (JSONException e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void postRequest(final JSONArray args, CallbackContext callbackContext) {
        try {
            final String url = args.getString(0);
            final JSONObject body = args.getJSONObject(1);
            apiHelper.postRequest(context, API_PATH + url, body, this.getApiListener(callbackContext));
        } catch (JSONException e) {
            callbackContext.error(e.getMessage());
        }
    }

    private void hasActiveSession(CallbackContext callbackContext) {
        try {
            LISession session = liSessionManager.getSession();
			callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, session.isValid()));
        } catch (Exception e) {
            //Should never happen
            callbackContext.error(e.getMessage());
        }
    }

    private void getActiveSession(CallbackContext callbackContext) {
        try {
            LISession session = liSessionManager.getSession();
            AccessToken accessToken = session.getAccessToken();

            if (session.isValid()) {
                JSONObject res = new JSONObject();
                res.put("accessToken", accessToken.getValue());
                res.put("expiresOn", accessToken.getExpiresOn());
                callbackContext.success(res);
            } else {
                // send nothing
                callbackContext.success("");
            }
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, session.isValid()));
        } catch (Exception e) {
            callbackContext.error(e.getMessage());
        }
    }

}
