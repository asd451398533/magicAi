package com.example.gengmei_app_face;

import android.app.Application;


import androidx.multidex.MultiDex;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterMain;
import zeusees.tracking.FaceTrackingManager;

public class App extends Application {

    private static App INSTANCE;

    public static App getInstance() {
        return INSTANCE;
    }

    @Override
    public void onCreate() {
        INSTANCE = this;
        super.onCreate();
        MultiDex.install(this);
        FlutterMain.startInitialization(this);
    }
}
