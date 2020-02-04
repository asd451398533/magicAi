package com.example.gengmei_app_face.util;

import android.annotation.SuppressLint;
import android.content.Context;
import android.util.DisplayMetrics;
import android.util.Size;
import android.util.TypedValue;
import android.view.WindowManager;

import com.example.gengmei_app_face.App;
import com.example.gengmei_app_face.R;

import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by TuXin on 2018/5/18 下午2:44.
 * <p>
 * Email : tuxin@pupupula.com
 */
public class DimensionUtils {
    public static final int KB = 1024;
    public static final int MB = 1024 * 1024;
    public static final int RECORD_PHOTO_MAX_SIZE = 4 * MB;

    public static int dp2Px(float dp) {
        final float scale = App.getInstance().getResources().getDisplayMetrics().density;
        return (int) (dp * scale + 0.5f);
    }


    public static int sp2Px(float sp) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, sp, App.getInstance().getResources().getDisplayMetrics());
    }

    public static float cm2Feet(float cm) {
        return Math.round((cm / 2.54F) * 100) / 100F;
    }


    public static float feetToCm(int feet, int second) {
        int feet2Inch = feet * 12;
        return (feet2Inch + second) * 2.54F;
    }

    public static float feetToCm(int[] feet) {
        return feetToCm(feet[0], feet[1]);
    }

    public static boolean twoFloatEqual(float a, float b) {
        return Math.abs(a - b) < 10e-6;
    }

    public static boolean twoDoubleEqual(double a, double b) {
        return Math.abs(a - b) < 10e-6;
    }

    @SuppressLint("NewApi")
    public static Size getOptimalCameraSize(Size[] sizes, boolean swappedDimension, int viewWidth) {
        boolean found = false;

        int index = 0;
        int largestArea = Integer.MIN_VALUE;
        // found the w/h is 3:4 size
        for (int i = 0; i < sizes.length; i++) {
            int realW = swappedDimension ? sizes[i].getHeight() : sizes[i].getWidth();
            int realH = swappedDimension ? sizes[i].getWidth() : sizes[i].getHeight();
            float ratio = (float) realW / realH;
            int area = realH * realW;
            if (realW >= viewWidth && twoFloatEqual(ratio, 0.75F)) {
                found = true;
                if (largestArea < area) {
                    index = i;
                    largestArea = area;
                }
            }
        }

        if (found) {
            return sizes[index];
        }

        index = 0;
        largestArea = Integer.MIN_VALUE;
        // if not found, found the w/h close and bigger than 3:4
        for (int i = 0; i < sizes.length; i++) {
            int realW = swappedDimension ? sizes[i].getHeight() : sizes[i].getWidth();
            int realH = swappedDimension ? sizes[i].getWidth() : sizes[i].getHeight();
            float ratio = (float) realW / realH;
            int area = realH * realW;
            if (realW >= viewWidth && ratio > 0.75) {
                if (largestArea < area) {
                    largestArea = area;
                    index = i;
                }
            }
        }
        return sizes[index];
    }

    public static List<Size> sortSizes(Size[] sizes) {
        List list = Arrays.asList(sizes);
        Collections.sort(list, new CompareSizesByArea());
        return list;
    }

    /**
     * Compares two {@code Size}s based on their areas.
     */
    @SuppressLint("NewApi")

    static class CompareSizesByArea implements Comparator<Size> {
        @Override
        public int compare(Size lhs, Size rhs) {
            // We cast here to ensure the multiplications won't overflow
            return Long.signum((long) lhs.getWidth() * lhs.getHeight() -
                    (long) rhs.getWidth() * rhs.getHeight());
        }

    }

    public static int getScreenWidth(Context context){
        DisplayMetrics displayMetrics = new DisplayMetrics();
        ((WindowManager) (context.getSystemService(Context.WINDOW_SERVICE))).getDefaultDisplay().getMetrics(displayMetrics);
        return displayMetrics.widthPixels;
    }
    public static int getScreenHeight(Context context){
        DisplayMetrics displayMetrics = new DisplayMetrics();
        ((WindowManager) (context.getSystemService(Context.WINDOW_SERVICE))).getDefaultDisplay().getMetrics(displayMetrics);
        return displayMetrics.heightPixels;
    }
}
