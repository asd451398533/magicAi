// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
package com.bytedance.labcv.demo.ai;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Configuration;
import android.graphics.Bitmap;
import android.opengl.GLSurfaceView;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.SparseArray;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.bytedance.labcv.demo.base.BaseActivity;
import com.bytedance.labcv.demo.contract.presenter.EffectPresenter;
import com.bytedance.labcv.demo.core.BaseEffectHelper;
import com.bytedance.labcv.demo.core.video.VideoEffectHelper;
import com.bytedance.labcv.demo.model.CaptureResult;
import com.bytedance.labcv.demo.model.ComposerNode;
import com.bytedance.labcv.demo.utils.BitmapUtils;
import com.bytedance.labcv.demo.utils.Config;
import com.bytedance.labcv.demo.utils.LogUtils;
import com.bytedance.labcv.demo.utils.OrientationSensor;
import com.bytedance.labcv.demo.utils.ToastUtils;
import com.example.gengmei_app_face.R;

import java.io.File;
import java.lang.ref.WeakReference;

import static android.opengl.GLSurfaceView.RENDERMODE_WHEN_DIRTY;
import static com.bytedance.labcv.demo.contract.StickerContract.TYPE_ANIMOJI;
import static com.bytedance.labcv.demo.contract.StickerContract.TYPE_ARSCAN;
import static com.bytedance.labcv.demo.contract.StickerContract.TYPE_STICKER;

public abstract class BaseEffectActivity extends BaseActivity<EffectPresenter> implements View.OnClickListener, VideoEffectHelper.OnEffectListener, GLSurfaceView.Renderer {
    // 标志面板类型，分别是 识别、特效、贴纸
    // Logo panel type, respectively is identification, special effects, stickers
    public static final String TAG_EFFECT = "effect";
    public static final String TAG_STICKER = "sticker";
    public static final String TAG_ANIMOJI = "animoji";
    public static final String TAG_ARSCAN = "arscan";
    private static final int UPDATE_INFO = 1;
    // 拍照失败
    protected static final int CAPTURE_FAIL = 9;
    // 拍照成功
    protected static final int CAPTURE_SUCCESS = 10;
    protected static final int CAPTURE_FINISH = 11;

    private static final int UPDATE_INFO_INTERVAL = 1000;
    protected static final int REQUEST_CODE_CHOOSE = 10;
    public static final int ANIMATOR_DURATION = 400;

    protected Context mContext;
    protected BaseEffectHelper mBaseEffectHelper;

    protected TextView mFpsTextView;
    protected Button mBtTakePic;
    protected ImageView mImgChoose;
    protected ImageView mImgSwitchCamera;
    protected ImageView mImgLogo;


    private View rootView;
    protected GLSurfaceView mSurfaceView;

    protected volatile boolean mIsPaused = false;

    protected boolean mFirstEnter = true;
    private String mSavedStickerPath;
    private String mSavedAnimojiPath;
    private String mSavedArscanPath;

    protected InnerHandler mHandler = null;

    abstract void onCreateImpl();

    abstract void onPauseImpl();

    abstract void onResumeImpl();

    abstract void onDestroyImpl();


    abstract int getFrameRateImpl();

    abstract void onEffectInitializedImpl();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        LogUtils.d("onCreate "+getLocalClassName());
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        OrientationSensor.start(this);
        setContentView(R.layout.test_main);
        initViews();
        setPresenter(new EffectPresenter());
        onCreateImpl();
    }

    private void initViews() {
        mSurfaceView = findViewById(R.id.gl_surface);
        mSurfaceView.setEGLContextClientVersion(2);
        mSurfaceView.setRenderer(this);
        mSurfaceView.setRenderMode(RENDERMODE_WHEN_DIRTY);

        mBtTakePic = findViewById(R.id.btn_take_pic);
        mBtTakePic.setOnClickListener(this);
        mImgSwitchCamera = findViewById(R.id.iv_change_camera);
        mImgSwitchCamera.setOnClickListener(this);

        rootView = findViewById(R.id.main);
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (null == mSurfaceView)return;
        mSurfaceView.onPause();
        // 关闭相机 释放纹理
        onPauseImpl();
        mHandler.removeCallbacksAndMessages(null);
    }


    @Override
    protected void onDestroy() {
        OrientationSensor.stop();
        super.onDestroy();
        mSurfaceView = null;
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (null == mSurfaceView)return;
        mSurfaceView.onResume();
        onResumeImpl();
        mHandler.sendEmptyMessageDelayed(UPDATE_INFO, UPDATE_INFO_INTERVAL);
    }

   volatile boolean mIsCapturing = false;
    protected void takePic(final boolean finish) {
        if (null != mSurfaceView && !mIsCapturing) {
            mSurfaceView.queueEvent(new Runnable() {
                @Override
                public void run() {
                    if (null == mBaseEffectHelper) return;
                    if (mHandler == null) return;
                    if (mIsCapturing)return;
                    mIsCapturing = true;
                    LogUtils.d("takePic invoked");
                    final CaptureResult captureResult = mBaseEffectHelper.capture();
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (null == captureResult || captureResult.getWidth() == 0 || captureResult.getHeight() == 0 || null == captureResult.getByteBuffer()) {
                                mHandler.sendEmptyMessage(CAPTURE_FAIL);
                            } else {
                                LogUtils.d("takePic return success");
                                Message msg = mHandler.obtainMessage(CAPTURE_SUCCESS, captureResult);
                                if (finish){
                                    msg.arg1 = CAPTURE_FINISH;
                                }
                                mHandler.sendMessage(msg);
                            }
                        }
                    });

                }
            });
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        finish();
    }

    protected static class InnerHandler extends Handler {
        private final WeakReference<BaseEffectActivity> mActivity;

        public InnerHandler(BaseEffectActivity activity) {
            mActivity = new WeakReference<>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            BaseEffectActivity activity = mActivity.get();
            if (activity != null) {
                switch (msg.what) {
                    case UPDATE_INFO:
                        sendEmptyMessageDelayed(UPDATE_INFO, UPDATE_INFO_INTERVAL);
                        break;
                    case CAPTURE_SUCCESS:
                        CaptureResult captureResult = (CaptureResult) msg.obj;
                        boolean finish = msg.arg1 == CAPTURE_FINISH;
                        SavePicTask task = new SavePicTask(mActivity.get(), finish);
                        task.execute(captureResult);
                        break;
                }
            }
        }

    }

    static class SavePicTask extends AsyncTask<CaptureResult, Void, String> {
        private WeakReference<Context> mContext;
        private boolean mFinishFlag;

        public SavePicTask(Context context, Boolean finish) {
            mContext = new WeakReference<>(context);
            mFinishFlag = finish;
        }

        @Override
        protected String doInBackground(CaptureResult... captureResults) {
            LogUtils.d("SavePicTask doInBackground enter");
            if (captureResults.length == 0) return "captureResult arrayLength is 0";
            Bitmap bitmap = Bitmap.createBitmap(captureResults[0].getWidth(), captureResults[0].getHeight(), Bitmap.Config.ARGB_8888);
            bitmap.copyPixelsFromBuffer(captureResults[0].getByteBuffer().position(0));
            File file = BitmapUtils.saveToLocal(bitmap);
            LogUtils.d("SavePicTask doInBackground finish");

            if (file.exists()) {
                return file.getAbsolutePath();
            } else {
                return "";
            }
        }

        @Override
        protected void onPostExecute(String path) {
            super.onPostExecute(path);
            if (TextUtils.isEmpty(path)) {
                ToastUtils.show("图片保存失败");
                return;
            }
            if (mContext.get() == null) {
                try {
                    new File(path).delete();
                } catch (Exception ignored) {
                }
                ToastUtils.show("图片保存失败");
            }
            try {
                ContentValues values = new ContentValues();
                values.put(MediaStore.Images.Media.DATA, path);
                values.put(MediaStore.Images.Media.MIME_TYPE, "image/*");
                mContext.get().getContentResolver().insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values);
            } catch (Exception e) {
                e.printStackTrace();
            }
            ToastUtils.show("保存成功，路径：" + path);
            if (mFinishFlag){
                ((BaseEffectActivity)mContext.get()).finish();
            }
        }
    }

    @Override
    public void onEffectInitialized() {
        if (!mFirstEnter) {
            return;
        }
        mFirstEnter = false;
        runOnUiThread(new Runnable() {
            @Override
            public void run() {

                final SparseArray<ComposerNode> mComposerNodeMap = new SparseArray<>();
                mPresenter.generateDefaultBeautyNodes(mComposerNodeMap);
                if (mSurfaceView != null) {
                    mSurfaceView.queueEvent(new Runnable() {
                        @Override
                        public void run() {
                            mBaseEffectHelper.setComposeNodes(mPresenter.generateComposerNodes(mComposerNodeMap));
                            for (int i = 0; i < mComposerNodeMap.size(); i++) {
                                ComposerNode node = mComposerNodeMap.valueAt(i);
                                if (mPresenter.hasIntensity(node.getId())) {
                                    mBaseEffectHelper.updateComposeNode(node, true);
                                }
                            }

                        }
                    });
                }
                onEffectInitializedImpl();


            }
        });


    }

    /**
     * 定义一个回调接口，用于当用户选择其中一个面板时，
     * 关闭其他面板的回调，此接口由各 Fragment 实现，
     * 在 onClose() 方法中要完成各 Fragment 中 UI 的初始化，
     * 即关闭用户已经开启的开关
     * <p>
     * Define a callback interface for when a user selects one of the panels，
     * close the callback of the other panel, which is implemented by each Fragment
     * In the onClose() method, initialize the UI of each Fragment:
     * turn off the switch that the user has already turned on
     */
    public interface OnCloseListener {
        void onClose();
    }

    public interface ICheckAvailableCallback {
        boolean checkAvailable(int id);
    }
}
