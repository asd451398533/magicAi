package com.example.gengmei_app_face.constant;

import android.os.Environment;

public class AppConstant {
    public static final int CAMERA_CODE = 10011;
    public static final int CAMERA_CODE_DEMO=10013;

    public static final int CAMERA_REQUEST_CODE=10012;

    public static final String CAMERA_RESULT = "path";

    public static final String predictorPath = Environment.getExternalStorageDirectory() + "/shape_predictor_5_face_landmarks.dat";

}
