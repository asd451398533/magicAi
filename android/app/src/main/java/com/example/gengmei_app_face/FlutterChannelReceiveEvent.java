package com.example.gengmei_app_face;

import android.text.TextUtils;

import io.flutter.Log;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

class FlutterChannelReceiveEvent {

    private MethodCall call;
    private MethodChannel.Result result;

    public FlutterChannelReceiveEvent(MethodCall call, MethodChannel.Result result) {
        this.call = call;
        this.result = result;
    }

    public void onCameraReturnPath(String stringExtra) {
        Log.e("lsy", "  " + stringExtra);
        if (TextUtils.isEmpty(stringExtra)) {
            result.error("not select", "", "");
        } else {
            result.success(stringExtra);
        }
    }

    public void error(String s, String s1, String i) {
        result.error(s, s1, i);
    }


    public void faceAiSuccess(String generateUrl) {
        result.success(generateUrl);
    }

    public void success(String obj) {
        result.success(obj);
    }

    public void success(Boolean obj) {
        result.success(obj);
    }
}
