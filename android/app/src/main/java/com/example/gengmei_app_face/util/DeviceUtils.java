package com.example.gengmei_app_face.util;


import android.app.Activity;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.PowerManager;
import android.provider.Settings;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.view.inputmethod.InputMethodManager;

import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.util.UUID;

/**
 * 设备相关信息
 */
public class DeviceUtils {

    public static String DEVICE_RELEASE_VERSION = Build.VERSION.RELEASE; // 获取版本号

    public static String DEVICE_MODEL = Build.MODEL;            // 获取手机型号

    public static String DEVICE_ID;

    public static String MAC_ADDRESS;

    public static String GM_UUID;

    private static final String ANDROID_ID_PREFIX = "androidid_";

    private static WeakReference<Context> mContextRef;

    public static void init(Context context) {
        mContextRef = new WeakReference<>(context.getApplicationContext());
        TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
        String deviceId = tm.getDeviceId();
        if (TextUtils.isEmpty(deviceId)) {
            String androidId = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
            DeviceUtils.DEVICE_ID = ANDROID_ID_PREFIX + androidId;
        } else {
            DeviceUtils.DEVICE_ID = deviceId;
        }
        initUUID();
        WifiManager wifi = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        DeviceUtils.MAC_ADDRESS = wifi.getConnectionInfo().getMacAddress();
    }

    public static int getWidth() {
        if (mContextRef == null) {
            return 0;
        }
        return mContextRef.get().getResources().getDisplayMetrics().widthPixels;
    }

    public static int getHeight() {
        if (mContextRef == null) {
            return 0;
        }
        return mContextRef.get().getResources().getDisplayMetrics().heightPixels;
    }

    public static int getStateHeight() {
        if (null == mContextRef) {
            return 0;
        }
        Class<?> c = null;
        Object obj = null;
        Field field = null;
        int x = 0, statusBarHeight = 0;
        try {
            c = Class.forName("com.android.internal.R$dimen");
            obj = c.newInstance();
            field = c.getField("status_bar_height");
            x = Integer.parseInt(field.get(obj).toString());
            statusBarHeight = mContextRef.get().getResources().getDimensionPixelSize(x);
        } catch (Exception e1) {
            e1.printStackTrace();
        }
        return statusBarHeight;
    }

    /**
     * 获取状态栏高度
     *
     * @return
     */
    public static int getStatusBarHeight() {
        int result = 0;
        if (null != mContextRef) {
            int resourceId = mContextRef.get().getResources().getIdentifier("status_bar_height", "dimen", "android");
            if (resourceId > 0) {
                result = mContextRef.get().getResources().getDimensionPixelSize(resourceId);
            }
        }
        return result;
    }

    /**
     * 点亮屏幕
     *
     * @param timeout The timeout after which to release the wake lock, in milliseconds
     */
    public static void weekUpScreen(long timeout) {
        if (null == mContextRef) {
            return;
        }
        try {
            PowerManager pm = (PowerManager) mContextRef.get().getSystemService(Context.POWER_SERVICE);
            PowerManager.WakeLock wl = pm.newWakeLock(PowerManager.FULL_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP, "gengmei");
            wl.acquire(timeout);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 复制剪切板
     *
     * @param text
     * @return
     */
    public static boolean copyClipboard(String text) {
        if (null == mContextRef) {
            return false;
        }
        try {
            if (Build.VERSION.SDK_INT < 11) {
                android.text.ClipboardManager clipboardManager = (android.text.ClipboardManager) mContextRef.get().getSystemService(Context.CLIPBOARD_SERVICE);
                clipboardManager.setText(text);
            } else {
                ClipboardManager clipboardManager = (ClipboardManager) mContextRef.get().getSystemService(Context.CLIPBOARD_SERVICE);
                clipboardManager.setPrimaryClip(ClipData.newPlainText(null, text));
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 隐藏软键盘
     */
    public static void hideSoftInputFromWindow(Activity activity) {
        InputMethodManager inputMethodManager = ((InputMethodManager) activity.getSystemService(activity.INPUT_METHOD_SERVICE));
        if (inputMethodManager != null && activity.getCurrentFocus() != null && activity.getCurrentFocus().getWindowToken() != null) {
            inputMethodManager.hideSoftInputFromWindow(activity.getCurrentFocus().getWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
        }
    }

    /**
     * 初始化GMUUID
     */
    private static void initUUID() {
        if (null == mContextRef || null == mContextRef.get()) {
            return;
        }
        SharedPreferences sp = mContextRef.get().getSharedPreferences("gm_device", Context.MODE_PRIVATE);
        String uuid = sp.getString("uuid", "");
        if (TextUtils.isEmpty(uuid)) {
            uuid = UUID.randomUUID().toString();
            GM_UUID = uuid;
            SharedPreferences.Editor edit = sp.edit();
            edit.putString("uuid", uuid);
            edit.apply();
        } else {
            GM_UUID = uuid;
        }
    }
}