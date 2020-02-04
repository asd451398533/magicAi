package com.example.gengmei_app_face;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Point;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.hardware.Camera;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.Toast;

import com.example.gengmei_app_face.camera.CameraView;
import com.example.gengmei_app_face.camera.size.AspectRatio;
import com.example.gengmei_app_face.util.DeviceUtils;
import com.example.gengmei_app_face.util.MyUtil;
import com.example.gengmei_app_face.util.StatusBarUtil;
import com.example.gengmei_app_face.view.CameraHideView;

import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import sensetime.senseme.com.effects.utils.FileUtils;
import zeusees.tracking.Face;
import zeusees.tracking.FaceTrackingManager;

import static com.example.gengmei_app_face.camera.CameraView.FACING_FRONT;
import static com.example.gengmei_app_face.constant.AppConstant.CAMERA_CODE;
import static com.example.gengmei_app_face.util.YUVUtil.rotateYUV420Degree180;


public class CameraActivity extends AppCompatActivity implements ActivityCompat.OnRequestPermissionsResultCallback, Camera.PreviewCallback {

    public static final String CAMERA_RESULT = "path";
    public static final String CAMERA_ORIAL = "orial";
    public static final String CAMERA_INDEX = "camera_index";
    public static final String CAMERA_RESULT_SCARE = "path_scare";
    private static final String TAG = "MainActivity";
    private CameraHideView hideView;
    private byte[] mPreviewBuffer = new byte[2332800 * 2];
    private FaceTrackingManager faceTrackingManager;
    int realScreenH, realScreenW;

    private static final int REQUEST_CAMERA_PERMISSION = 1;

    private static final int[] FLASH_OPTIONS = {
            CameraView.FLASH_AUTO,
            CameraView.FLASH_OFF,
            CameraView.FLASH_ON,
    };

    private static final int[] FLASH_ICONS = {
            R.drawable.ic_flash_auto,
            R.drawable.ic_flash_off,
            R.drawable.ic_flash_on,
    };

    private int mCurrentFlash;
    private CameraView mCameraView;
    private ImageView flash;
    private ImageView switchCamera;
    private volatile boolean isDecting = false, isDestory = false;
    private ExecutorService singleThreadExecutor = Executors.newSingleThreadExecutor();


    private View.OnClickListener mOnClickListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            int id = v.getId();
            if (id == R.id.takePic) {
                if (mCameraView != null) {
                    mCameraView.takePicture();
                }
            } else if (id == R.id.finish) {
                setResult(CAMERA_CODE, null);
                finish();
            } else if (id == R.id.flash) {
                if (mCameraView != null) {
                    mCurrentFlash = (mCurrentFlash + 1) % FLASH_OPTIONS.length;
                    flash.setImageResource(FLASH_ICONS[mCurrentFlash]);
                    mCameraView.setFlash(FLASH_OPTIONS[mCurrentFlash]);
                }
            } else if (id == R.id.switchCamera) {
                if (mCameraView != null) {
                    int facing = mCameraView.getFacing();
                    mCameraView.setFacing(facing == FACING_FRONT ?
                            CameraView.FACING_BACK : FACING_FRONT);
                    mCameraView.post(new Runnable() {
                        @Override
                        public void run() {
                            faceTrackingManager.reset();
                            mCameraView.mImpl.mCamera.addCallbackBuffer(mPreviewBuffer);
                            mCameraView.mImpl.mCamera.setPreviewCallbackWithBuffer(CameraActivity.this);
                        }
                    });
                }
            }
        }
    };

    public static void setTransparent(Activity activity) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            return;
        }
        transparentStatusBar(activity);
        setRootView(activity);
    }

    @TargetApi(Build.VERSION_CODES.KITKAT)
    private static void transparentStatusBar(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            //需要设置这个flag contentView才能延伸到状态栏
            activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            //状态栏覆盖在contentView上面，设置透明使contentView的背景透出来
            activity.getWindow().setStatusBarColor(Color.TRANSPARENT);
        } else {
            //让contentView延伸到状态栏并且设置状态栏颜色透明
            activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    /**
     * 设置根布局参数
     */
    private static void setRootView(Activity activity) {
        ViewGroup parent = (ViewGroup) activity.findViewById(android.R.id.content);
        for (int i = 0, count = parent.getChildCount(); i < count; i++) {
            View childView = parent.getChildAt(i);
            if (childView instanceof ViewGroup) {
                childView.setFitsSystemWindows(true);
                ((ViewGroup) childView).setClipToPadding(true);
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(R.style.AppTheme);
//        setTransparent(this);
        super.onCreate(savedInstanceState);
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getRealMetrics(dm);
        realScreenH = dm.heightPixels;
        realScreenW = dm.widthPixels;
//        nv21ToBitmap = new NV21ToBitmap(App.getInstance());
        setContentView(R.layout.camera_main);
        faceTrackingManager = FaceTrackingManager.getInstance();
        faceTrackingManager.init(getApplicationContext());
        for (int i = 0; i < 106; i++) {
            pointList.add(new Point(0, 0));
        }
        initView();
    }

    private void initView() {
        StatusBarUtil.transparencyBar(this);

        hideView = findViewById(R.id.hideView);
        mCameraView = findViewById(R.id.camera);
        mCameraView.setFacing(FACING_FRONT);
        mCameraView.mImpl.setWidthAndHeight(realScreenW, realScreenH);

        if (mCameraView != null) {
            mCameraView.addCallback(mCallback);
        }
        mCameraView.setAutoFocus(true);
        ImageView fab = findViewById(R.id.takePic);
        if (fab != null) {
            fab.setOnClickListener(mOnClickListener);
        }
        findViewById(R.id.finish).setOnClickListener(mOnClickListener);
        flash = findViewById(R.id.flash);
        flash.setOnClickListener(mOnClickListener);
        switchCamera = findViewById(R.id.switchCamera);
        switchCamera.setOnClickListener(mOnClickListener);
        findViewById(R.id.hideView).bringToFront();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                == PackageManager.PERMISSION_GRANTED) {
            mCameraView.start();
            mCameraView.postDelayed(new Runnable() {
                @Override
                public void run() {
                    mCameraView.setAspectRatio(getAspectRatio(mCameraView));
                    mCameraView.mImpl.mCamera.addCallbackBuffer(mPreviewBuffer);
                    mCameraView.mImpl.mCamera.setPreviewCallbackWithBuffer(CameraActivity.this);
                }
            }, 200);
        } else if (ActivityCompat.shouldShowRequestPermissionRationale(this,
                Manifest.permission.CAMERA)) {
            Toast.makeText(this, "请给予权限", Toast.LENGTH_LONG).show();
        } else {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE},
                    REQUEST_CAMERA_PERMISSION);
        }
    }

    @Override
    protected void onPause() {
        mCameraView.stop();
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        isDestory = true;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions,
                                           int[] grantResults) {
        switch (requestCode) {
            case REQUEST_CAMERA_PERMISSION:
                if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                    Toast.makeText(this, "请给予权限",
                            Toast.LENGTH_SHORT).show();
                }
                break;
        }
    }


    private CameraView.Callback mCallback
            = new CameraView.Callback() {

        @Override
        public void onCameraOpened(CameraView cameraView) {
            try {
                mCameraView.setAspectRatio(getAspectRatio(mCameraView));
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onCameraClosed(CameraView cameraView) {
            Log.d(TAG, "onCameraClosed");
        }

        @Override
        public void onPictureTaken(CameraView cameraView, final byte[] data, Camera camera) {
            Log.d(TAG, "onPictureTaken " + data.length);
            Toast.makeText(cameraView.getContext(), "拍照处理中", Toast.LENGTH_SHORT)
                    .show();
            new Thread(new Runnable() {
                @Override
                public void run() {
                    long time = System.currentTimeMillis();
                    File file1 = new File(Environment.getExternalStorageDirectory() + "/gengmei/");
                    if (!file1.exists()) {
                        file1.mkdirs();
                    }
                    File file = new File(Environment.getExternalStorageDirectory() + "/gengmei/",
                            System.currentTimeMillis() + "temp.jpg");
                    Bitmap nbmp2 = null;
                    Bitmap bm = BitmapFactory.decodeByteArray(data, 0,
                            data.length);
                    if (mCameraView.getFacing() != FACING_FRONT) {
                        nbmp2 = bm;
                    } else {
                        Matrix matrix = new Matrix();
                        if (bm.getWidth() > bm.getHeight()) {
                            matrix.postRotate(-90);
                        }
                        matrix.postScale(-1, 1);
                        nbmp2 = Bitmap.createBitmap(bm, 0, 0, bm.getWidth(), bm.getHeight(), matrix, true);
                    }
                    BufferedOutputStream bos = null;
                    try {
                        bos = new BufferedOutputStream(
                                new FileOutputStream(file));
                        nbmp2.compress(Bitmap.CompressFormat.JPEG, 100, bos);
                        bos.flush();
                    } catch (FileNotFoundException e) {
                        e.printStackTrace();
                    } catch (IOException e) {
                        e.printStackTrace();
                    } finally {
                        try {
                            bos.close();
                        } catch (IOException e) {
                            e.printStackTrace();
                        }
                    }
                    if (file.exists()) {
                        Uri uri = Uri.fromFile(file);
                        Intent intent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
                        intent.setData(uri);
                        sendBroadcast(intent);
                    }
                    String scarePath = MyUtil.Companion.scareImg(file.getAbsolutePath(), 200f, FileUtils.getOutputMediaFile().getAbsolutePath(), 75, 0);
                    Log.e("lsy", "  pic Time " + (System.currentTimeMillis() - time));
                    Intent intent = new Intent();
                    intent.putExtra(CAMERA_RESULT, file.getAbsolutePath());
                    intent.putExtra(CAMERA_RESULT_SCARE, scarePath);
                    setResult(CAMERA_CODE, intent);
                    finish();
                }
            }).start();
        }
    };


    private void takePic(byte[] bytes, Camera.Size previewSize) {

        YuvImage yuvimage = new YuvImage(
                bytes,
                ImageFormat.NV21,
                previewSize.width,
                previewSize.height,
                null);
        final ByteArrayOutputStream baos = new ByteArrayOutputStream();
        yuvimage.compressToJpeg(new Rect(0, 0, previewSize.width, previewSize.height), 100, baos);// 80--JPG图片的质量[0-100],100最高
        byte[] rawImage = baos.toByteArray();
        BitmapFactory.Options options = new BitmapFactory.Options();
        options.inPreferredConfig = Bitmap.Config.ARGB_8888;
        final Bitmap bitmap = BitmapFactory.decodeByteArray(rawImage, 0, rawImage.length, options);


        Log.e("lsy", "   !!!!!-1111111  ");

        File file1 = new File(Environment.getExternalStorageDirectory() + "/gengmei/");
        if (!file1.exists()) {
            file1.mkdirs();
        }
        final File file = new File(Environment.getExternalStorageDirectory() + "/gengmei/",
                "picture.jpg");

        Log.e("lsy", "   !!!!!00000  ");
        BufferedOutputStream bos = null;
        try {
            bos = new BufferedOutputStream(
                    new FileOutputStream(file));
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, bos);
            bos.flush();
        } catch (FileNotFoundException e) {
            Log.e("lsy", " " + e.getMessage());
            e.printStackTrace();
        } catch (IOException e) {
            Log.e("lsy", " " + e.getMessage());
            e.printStackTrace();
        } finally {
            try {
                bos.close();
            } catch (IOException e) {
                Log.e("lsy", " " + e.getMessage());
                e.printStackTrace();
            }
        }
        String scarePath = MyUtil.Companion.scareImg(file.getAbsolutePath(), 200f, FileUtils.getOutputMediaFile().getAbsolutePath(), 75, 0);
        Log.e("lsy", "   SCARRREEWQEWE +" + scarePath);
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                mCameraView.setPreViewNull();
                Intent intent = new Intent();
                intent.putExtra(CAMERA_RESULT, file.getAbsolutePath());
                intent.putExtra(CAMERA_RESULT_SCARE, scarePath);
                setResult(CAMERA_CODE, intent);
                finish();
            }
        });
    }

    private AspectRatio getAspectRatio(CameraView cameraView) {
        float ratio = (realScreenH) * 1f / realScreenW;
        Set<AspectRatio> supportedAspectRatios = cameraView.getSupportedAspectRatios();
        Iterator<AspectRatio> iterator = supportedAspectRatios.iterator();
        float minDiff = 0f;
        AspectRatio finalRatio = null;
        while (iterator.hasNext()) {
            AspectRatio next = iterator.next();
            float diff = next.getX() * 1f / next.getY() - ratio;
            if (diff == 0f) {
                return next;
            }
            if (minDiff == 0f) {
                minDiff = diff;
                finalRatio = next;
                continue;
            }
            if (Math.abs(diff) < Math.abs(minDiff)) {
                minDiff = diff;
                finalRatio = next;
            }
        }
        Log.e("lsyy", " " + finalRatio.getX() + "   " + finalRatio.getY());
        return finalRatio;
    }

    private Camera.Size previewSize;
    private List<Point> pointList = new ArrayList<>(106);

    @Override
    public void onPreviewFrame(final byte[] bytes, final Camera camera) {
        if (!isDecting && !isDestory) {
            isDecting = true;
            singleThreadExecutor.execute(new Runnable() {
                @Override
                public void run() {
                    try {
                        long time1 = System.currentTimeMillis();
                        if (previewSize == null) {
                            previewSize = camera.getParameters().getPreviewSize();
                        }
                        byte[] data;
                        final boolean isFont = mCameraView.getFacing() == FACING_FRONT;
                        if (!isFont) {
                            data = rotateYUV420Degree180(bytes, previewSize.height, previewSize.width);
                        } else {
                            data = bytes;
                        }
                        final List<Face> faceActions = faceTrackingManager.detect(data, previewSize.width, previewSize.height);
                        final float scareX = ((float) mCameraView.getWidth()) / ((float) previewSize.height);
                        final float scareY = ((float) mCameraView.getHeight()) / ((float) previewSize.width);
                        Log.e("lsy", " 1111 TIME!!  " + (System.currentTimeMillis() - time1));
                        if (faceActions != null && faceActions.size() == 1 && faceActions.get(0).landmarks.length == 212) {
                            for (int i = 0; i < 106; i++) {
//                                int x1 = previewSize.height - faceActions.get(0).landmarks[2 * i];
                                int x1;
                                int y1 = faceActions.get(0).landmarks[2 * i + 1];
                                if (isFont) {
                                    x1 = faceActions.get(0).landmarks[2 * i];
                                    pointList.get(i).x = (int) (x1 * scareY);
                                    pointList.get(i).y = (int) (y1 * scareY);
                                } else {
                                    x1 = faceActions.get(0).landmarks[2 * i];
                                    pointList.get(i).x = (int) (previewSize.height * scareY) - (int) (x1 * scareY);
                                    pointList.get(i).y = (int) (y1 * scareY);
                                }

                            }
                        }
                        Log.e("lsy", "  TIME!!  " + (System.currentTimeMillis() - time1));
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                Log.e("lsy", " face !!  " + faceActions);
                                hideView.setData(faceActions, pointList, scareX, scareY, previewSize.height, isFont);
                                isDecting = false;
                                camera.addCallbackBuffer(mPreviewBuffer);
                            }
                        });

//
//                        IGengmeiSdk.getInstance().
//
//                                preview_face_detection(bytes, previewSize.width,
//                                previewSize.height, hideView.getWidth(), hideView.getHeight(),
//                                480.f, mCameraView.getFacing() == FACING_FRONT,
//                                new IGengmeiDetectListener() {
//                                    @Override
//                                    public void onSuccess(List<Face> list) {
//                                        runOnUiThread(new Runnable() {
//                                            @Override
//                                            public void run() {
//                                                hideView.setData(list);
////                                        ((ImageView) findViewById(R.id.test)).setImageBitmap(bitmap1);
//                                                isDecting = false;
//                                                camera.addCallbackBuffer(mPreviewBuffer);
//                                                if (list!=null){
//                                                    Log.e("lsy"," size "+list.size());
//                                                }
//                                                Log.e("lsy", "  use Time : " + (System.currentTimeMillis() - time1));
//                                            }
//                                        });
//                                    }
//
//                                    @Override
//                                    public void onFail(String s) {
//                                        isDecting = false;
//                                        Log.e("lsy", "  " + s);
//                                        camera.addCallbackBuffer(mPreviewBuffer);
//                                    }
//                                });
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });
        }
    }
}
