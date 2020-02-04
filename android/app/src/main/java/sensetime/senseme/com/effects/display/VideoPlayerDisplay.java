package sensetime.senseme.com.effects.display;

import android.content.Context;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.hardware.SensorEvent;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.opengl.EGL14;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLSurfaceView.Renderer;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.util.Log;
import android.view.Surface;

import com.sensetime.stmobile.STBeautifyNative;
import com.sensetime.stmobile.STBeautyParamsType;
import com.sensetime.stmobile.STCommon;
import com.sensetime.stmobile.STFilterParamsType;
import com.sensetime.stmobile.STHumanActionParamsType;
import com.sensetime.stmobile.STMobileFaceAttributeNative;
import com.sensetime.stmobile.STMobileHumanActionNative;
import com.sensetime.stmobile.STMobileObjectTrackNative;
import com.sensetime.stmobile.STMobileStickerNative;
import com.sensetime.stmobile.STMobileStreamFilterNative;
import com.sensetime.stmobile.STRotateType;
import com.sensetime.stmobile.model.STFaceAttribute;
import com.sensetime.stmobile.model.STHumanAction;
import com.sensetime.stmobile.model.STMobile106;
import com.sensetime.stmobile.model.STRect;
import com.sensetime.stmobile.model.STStickerInputParams;
import com.sensetime.stmobile.sticker_module_types.STCustomEvent;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.Timer;
import java.util.TimerTask;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import sensetime.senseme.com.effects.CameraActivity;
import sensetime.senseme.com.effects.VideoPlayerActivity;
import sensetime.senseme.com.effects.encoder.MediaVideoEncoder;
import sensetime.senseme.com.effects.glutils.GlUtil;
import sensetime.senseme.com.effects.glutils.OpenGLUtils;
import sensetime.senseme.com.effects.glutils.STUtils;
import sensetime.senseme.com.effects.glutils.TextureRotationUtil;
import sensetime.senseme.com.effects.utils.Accelerometer;
import sensetime.senseme.com.effects.utils.Constants;
import sensetime.senseme.com.effects.utils.FileUtils;
import sensetime.senseme.com.effects.utils.LogUtils;

/**
 * VideoPlayerDisplay is used for video player
 */

/**
 * 渲染结果显示的Render, 用户最终看到的结果在这个类中得到并显示.
 * 请重点关注onSurfaceCreated,onSurfaceChanged,onDrawFrame
 * 四个接口, 基本上所有的处理逻辑都是围绕这四个接口展开
 */
public class VideoPlayerDisplay extends BaseDisplay implements Renderer {

    private String TAG = "VideoPlayerDisplay";
    private boolean DEBUG = false;

    protected int mTextureId = OpenGLUtils.NO_TEXTURE;

    private int mImageWidth;
    private int mImageHeight;
    private String rotation;
    private GLSurfaceView mGlSurfaceView;
    private int mSurfaceWidth;
    private int mSurfaceHeight;

    private Context mContext;

    private String mCurrentSticker;
    private String mCurrentFilterStyle;
    private float mCurrentFilterStrength = 0.65f;//阈值为[0,1]
    private float mFilterStrength = 0.65f;
    private String mFilterStyle;

    private STGLRender mGLRender;
    private STMobileStickerNative mStStickerNative = new STMobileStickerNative();
    private STBeautifyNative mStBeautifyNative = new STBeautifyNative();
    private STMobileHumanActionNative mSTHumanActionNative = new STMobileHumanActionNative();
    private STHumanAction mHumanActionBeautyOutput = new STHumanAction();
    private STMobileStreamFilterNative mSTMobileStreamFilterNative = new STMobileStreamFilterNative();
    private STMobileFaceAttributeNative mSTFaceAttributeNative = new STMobileFaceAttributeNative();
    private STMobileObjectTrackNative mSTMobileObjectTrackNative = new STMobileObjectTrackNative();

    private ByteBuffer mRGBABuffer;
    private int[] mBeautifyTextureId;
    private int[] mTextureOutId;
    private int[] mFilterTextureOutId;

    private long mStartTime;
    private boolean mShowOriginal = false;
    private boolean mNeedBeautify = false;
    private boolean mNeedSticker = false;
    private boolean mNeedFilter = false;
    private boolean mNeedSave = false;
    private boolean mNeedObject = false;
    private FloatBuffer mTextureBuffer;
    private float[] mBeautifyParams = {0.36f, 0.74f, 0.02f, 0.13f, 0.11f, 0.1f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f};
    private Handler mHandler;
    private String mFaceAttribute;
    private boolean mIsPaused = false;
    private long mDetectConfig = 0;
    private boolean mIsCreateHumanActionHandleSucceeded = false;
    private Object mHumanActionHandleLock = new Object();

    private boolean mNeedShowRect = true;
    private int mScreenIndexRectWidth = 0;

    private Rect mTargetRect = new Rect();
    private Rect mIndexRect = new Rect();
    private boolean mNeedSetObjectTarget = false;
    private boolean mIsObjectTracking = false;

    private int mHumanActionCreateConfig = STMobileHumanActionNative.ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO;
    private long mRotateCost = 0;
    private long mObjectCost = 0;
    private long mFaceAttributeCost = 0;
    private int mFrameCount = 0;

    //for test fps
    private float mFps;
    private int mCount = 0;
    private long mCurrentTime = 0;
    private boolean mIsFirstCount = true;
    private int mFrameCost = 0;

    private MediaVideoEncoder mVideoEncoder;
    private final float[] mStMatrix = new float[16];
    private int[] mVideoEncoderTexture;
    private boolean mNeedResetEglContext = false;

    private static final int MESSAGE_ADD_SUB_MODEL = 1001;
    private static final int MESSAGE_REMOVE_SUB_MODEL = 1002;
    private HandlerThread mSubModelsManagerThread;
    private Handler mSubModelsManagerHandler;

    private long mHandAction = 0;
    private long mBodyAction = 0;
    private boolean[] mFaceExpressionResult;

    private SurfaceTexture mVideoTexture;
    private MediaPlayer mMediaPlayer;
    private String mVideoPath = null;
    private boolean mNeedPause = true;
    private Timer mTimer = new Timer();
    private TimerTask mTimerTask;
    private MediaMetadataRetriever retr;
    private boolean mIsFirstPlaying = true;

    private int mCustomEvent = 0;
    private SensorEvent mSensorEvent;

    public VideoPlayerDisplay(Context context, GLSurfaceView glSurfaceView, String videoPath) {
        mGlSurfaceView = glSurfaceView;
        mContext = context;
        mVideoPath = videoPath;
        glSurfaceView.setEGLContextClientVersion(2);
        glSurfaceView.setRenderer(this);
        glSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);

        mTextureBuffer = ByteBuffer.allocateDirect(TextureRotationUtil.TEXTURE_NO_ROTATION.length * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer();

        mTextureBuffer.put(TextureRotationUtil.TEXTURE_NO_ROTATION).position(0);
        mGLRender = new STGLRender();

        //是否为debug模式
        DEBUG = CameraActivity.DEBUG;

        //初始化非OpengGL相关的句柄，包括人脸检测及人脸属性
        initHumanAction(); //因为人脸模型加载较慢，建议异步调用
        initObjectTrack();

        if(DEBUG){
            initFaceAttribute();
        }

        mSubModelsManagerThread = new HandlerThread("SubModelManagerThread");
        mSubModelsManagerThread.start();
        mSubModelsManagerHandler = new Handler(mSubModelsManagerThread.getLooper()) {
            @Override
            public void handleMessage(Message msg) {
                if(!mIsPaused && mIsCreateHumanActionHandleSucceeded){
                    switch (msg.what){
                        case MESSAGE_ADD_SUB_MODEL:
                            String modelName = (String) msg.obj;
                            if(modelName != null){
                                addSubModel(modelName);
                            }
                            break;

                        case MESSAGE_REMOVE_SUB_MODEL:
                            int config = (int) msg.obj;
                            if(config != 0){
                                removeSubModel(config);
                            }
                            break;

                        default:
                            break;
                    }
                }
            }
        };
    }

    private void addSubModel(final String modelName){
        synchronized (mHumanActionHandleLock) {
            int result = mSTHumanActionNative.addSubModelFromAssetFile(modelName, mContext.getAssets());
            LogUtils.i(TAG, "add sub model result: %d", result);

            if(result == 0){
                if(modelName.equals(FileUtils.MODEL_NAME_BODY_FOURTEEN)){
                    mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_BODY_KEYPOINTS;
                    mSTHumanActionNative.setParam(STHumanActionParamsType.ST_HUMAN_ACTION_PARAM_BODY_LIMIT, 3.0f);
                }else if(modelName.equals(FileUtils.MODEL_NAME_FACE_EXTRA)){
                    mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_DETECT_EXTRA_FACE_POINTS;
                }else if(modelName.equals(FileUtils.MODEL_NAME_EYEBALL_CONTOUR)){
                    mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_DETECT_EYEBALL_CONTOUR |
                            STMobileHumanActionNative.ST_MOBILE_DETECT_EYEBALL_CENTER;
                }else if(modelName.equals(FileUtils.MODEL_NAME_HAND)){
                    mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_HAND_DETECT_FULL;
                }
            }
        }
    }

    private void removeSubModel(final int config){
        synchronized (mHumanActionHandleLock) {
            int result = mSTHumanActionNative.removeSubModelByConfig(config);
            LogUtils.i(TAG, "remove sub model result: %d", result);

            if(config == STMobileHumanActionNative.ST_MOBILE_ENABLE_BODY_KEYPOINTS){
                mDetectConfig &= ~STMobileHumanActionNative.ST_MOBILE_BODY_KEYPOINTS;
            }else if(config == STMobileHumanActionNative.ST_MOBILE_ENABLE_FACE_EXTRA_DETECT){
                mDetectConfig &= ~STMobileHumanActionNative.ST_MOBILE_DETECT_EXTRA_FACE_POINTS;
            }else if(config == STMobileHumanActionNative.ST_MOBILE_ENABLE_EYEBALL_CONTOUR_DETECT){
                mDetectConfig &= ~(STMobileHumanActionNative.ST_MOBILE_DETECT_EYEBALL_CONTOUR |
                        STMobileHumanActionNative.ST_MOBILE_DETECT_EYEBALL_CENTER);
            }else if(config == STMobileHumanActionNative.ST_MOBILE_ENABLE_HAND_DETECT){
                mDetectConfig &= ~STMobileHumanActionNative.ST_MOBILE_HAND_DETECT_FULL;
            }
        }
    }

    public void enableBeautify(boolean needBeautify) {
        mNeedBeautify = needBeautify;
        setHumanActionDetectConfig(mNeedBeautify, mStStickerNative.getTriggerAction());
        mNeedResetEglContext = true;
    }

    public void enableSticker(boolean needSticker){
        mNeedSticker = needSticker;
        //reset humanAction config
        if(!needSticker){
            setHumanActionDetectConfig(mNeedBeautify, mStStickerNative.getTriggerAction());
        }

        mNeedResetEglContext = true;
    }

    public void enableFilter(boolean needFilter){
        mNeedFilter = needFilter;
        mNeedResetEglContext = true;
    }

    public String getFaceAttributeString() {
        return mFaceAttribute;
    }

    public void setSaveImage() {
        mNeedSave = true;
    }

    public void setHandler(Handler handler) {
        mHandler = handler;
    }

    /**
     * 工作在opengl线程, 当前Renderer关联的view创建的时候调用
     *
     * @param gl
     * @param config
     */
    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        LogUtils.i(TAG, "onSurfaceCreated");
        if (mIsPaused == true) {
            return ;
        }
        GLES20.glEnable(GL10.GL_DITHER);
        GLES20.glClearColor(0, 0, 0, 0);
        GLES20.glEnable(GL10.GL_DEPTH_TEST);

        setUpVideo();

        //初始化GL相关的句柄，包括美颜，贴纸，滤镜
        initBeauty();
        initSticker();
        initFilter();
    }

    public void prepareVideoAndStart() {
        mMediaPlayer = new MediaPlayer();
        mMediaPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                mp.start();
                Message msg = mHandler.obtainMessage(VideoPlayerActivity.MSG_MEDIA_PREPARE_PLAY);
                msg.arg1 = mMediaPlayer.getDuration();
                mHandler.sendMessage(msg);
            }
        });
        Surface surface = new Surface(mVideoTexture);
        mMediaPlayer.setSurface(surface);
        surface.release();
        try {
            mMediaPlayer.reset();
            mMediaPlayer.setDataSource(mVideoPath);
            mMediaPlayer.prepareAsync();
        } catch (IOException e) {
            e.printStackTrace();
        }

        mMediaPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                if(mNeedPause){
                    return ;
                }
                // 在播放完毕被回调
                if(mMediaPlayer != null){
                    mMediaPlayer.seekTo(0);
                }
                if(mTimerTask != null){
                    if(mMediaPlayer != null && !mMediaPlayer.isPlaying()){
                        int position = mMediaPlayer.getCurrentPosition();
                        Message msg = mHandler.obtainMessage(VideoPlayerActivity.MSG_MEDIA_PROGRESS_UPDTAE);
                        msg.arg1 = position;
                        mHandler.sendMessage(msg);
                    }
                    mTimerTask.cancel();
                }
                if(mIsFirstPlaying){
                    Message msg = mHandler.obtainMessage(VideoPlayerActivity.MSG_STOP_RECORDING);
                    mHandler.sendMessage(msg);
                    mIsFirstPlaying = false;
                    StartPlayVideo();
                }else{
                    StartPlayVideo();
                }

            }
        });
    }

    private void confirmWidthAndHeight(String rotation){
        switch (Integer.valueOf(rotation)){
            case 0:
                mImageHeight = Integer.parseInt(retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)); // 视频高度
                mImageWidth = Integer.parseInt(retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)); // 视频宽度
                mGLRender.adjustVideoTextureBuffer(180, true, false);
                break;
            case 90:
                mImageWidth = Integer.parseInt(retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)); // 视频高度
                mImageHeight = Integer.parseInt(retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)); // 视频宽度
                mGLRender.adjustVideoTextureBuffer(90, true,false);
                break;
            case 180:
                mImageHeight = Integer.parseInt(retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)); // 视频高度
                mImageWidth = Integer.parseInt(retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)); // 视频宽度
                mGLRender.adjustVideoTextureBuffer(0, true,false);
                break;
            case 270:
                mImageWidth = Integer.parseInt(retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT)); // 视频高度
                mImageHeight = Integer.parseInt(retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH)); // 视频宽度
                mGLRender.adjustVideoTextureBuffer(270, true,false);
                break;
            default:
                break;
        }
    }

    private void initFaceAttribute() {
        int result = mSTFaceAttributeNative.createInstanceFromAssetFile(FileUtils.MODEL_NAME_FACE_ATTRIBUTE, mContext.getAssets());
        LogUtils.i(TAG, "the result for createInstance for faceAttribute is %d", result);
    }

    private void initHumanAction() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                synchronized (mHumanActionHandleLock) {
                    //从asset资源文件夹读取model到内存，再使用底层st_mobile_human_action_create_from_buffer接口创建handle
                    int result = mSTHumanActionNative.createInstanceFromAssetFile(FileUtils.getActionModelName(), mHumanActionCreateConfig, mContext.getAssets());
                    LogUtils.i(TAG, "the result for createInstance for human_action is %d", result);

                    if (result == 0) {
                        result = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_HAND, mContext.getAssets());
                        LogUtils.i(TAG, "add hand model result: %d", result);
                        result = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_SEGMENT, mContext.getAssets());
                        LogUtils.i(TAG, "add figure segment model result: %d", result);

                        mIsCreateHumanActionHandleSucceeded = true;
                        mSTHumanActionNative.setParam(STHumanActionParamsType.ST_HUMAN_ACTION_PARAM_BACKGROUND_BLUR_STRENGTH, 0.35f);

                        result = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_EYEBALL_CONTOUR, mContext.getAssets());
                        LogUtils.i(TAG, "add eyeball contour model result: %d", result);

                        int ret = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_AVATAR_HELP, mContext.getAssets());
                        LogUtils.i(TAG, "add avatar help model result: %d", ret);

//                        ret = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_TONGUE, mContext.getAssets());
//                        LogUtils.i(TAG,"add tongue model result: %d", ret );

                    }
                }
            }
        }).start();
    }

    private void initSticker() {
        int result = mStStickerNative.createInstance(mContext);

        if(mNeedSticker){
            mStStickerNative.changeSticker(mCurrentSticker);
        }

        setHumanActionDetectConfig(mNeedBeautify, mStStickerNative.getTriggerAction());
        LogUtils.i(TAG, "the result for createInstance for human_action is %d", result);

        //从资源文件加载Avatar模型
        mStStickerNative.loadAvatarModelFromAssetFile(FileUtils.MODEL_NAME_AVATAR_CORE, mContext.getAssets());
    }

    private void initBeauty() {
        // 初始化beautify,preview的宽高
        int result = mStBeautifyNative.createInstance();
        LogUtils.i(TAG, "the result is for initBeautify " + result);
        if (result == 0) {
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_REDDEN_STRENGTH, mBeautifyParams[0]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_SMOOTH_STRENGTH, mBeautifyParams[1]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_WHITEN_STRENGTH, mBeautifyParams[2]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_ENLARGE_EYE_RATIO, mBeautifyParams[3]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_SHRINK_FACE_RATIO, mBeautifyParams[4]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_SHRINK_JAW_RATIO, mBeautifyParams[5]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_CONSTRACT_STRENGTH, mBeautifyParams[6]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_SATURATION_STRENGTH, mBeautifyParams[7]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_DEHIGHLIGHT_STRENGTH, mBeautifyParams[8]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_NARROW_FACE_STRENGTH, mBeautifyParams[9]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_ROUND_EYE_RATIO, mBeautifyParams[26]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, mBeautifyParams[10]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, mBeautifyParams[11]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, mBeautifyParams[12]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, mBeautifyParams[13]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, mBeautifyParams[14]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, mBeautifyParams[15]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, mBeautifyParams[16]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, mBeautifyParams[17]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, mBeautifyParams[18]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, mBeautifyParams[19]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_PROFILE_RHINOPLASTY_RATIO, mBeautifyParams[20]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_BRIGHT_EYE_RATIO, mBeautifyParams[21]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, mBeautifyParams[22]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, mBeautifyParams[23]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_WHITE_TEETH_RATIO, mBeautifyParams[24]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, mBeautifyParams[25]);
            mStBeautifyNative.setParam(STBeautyParamsType.ST_BEAUTIFY_SMOOTH_MODE, 0f);
        }
    }

    /**
     * human action detect的配置选项,根据Sticker的TriggerAction和是否需要美颜配置
     *
     * @param needFaceDetect  是否需要开启face detect
     * @param config  sticker的TriggerAction
     */
    private void setHumanActionDetectConfig(boolean needFaceDetect, long config){
        if(!mNeedSticker || mCurrentSticker == null){
            config = 0;
        }

        if(needFaceDetect){
            mDetectConfig = config | STMobileHumanActionNative.ST_MOBILE_FACE_DETECT;
        }else{
            mDetectConfig = config;
        }
    }

    private void initFilter(){
        mSTMobileStreamFilterNative.createInstance();

        mSTMobileStreamFilterNative.setStyle(mCurrentFilterStyle);

        mCurrentFilterStrength = mFilterStrength;
        mSTMobileStreamFilterNative.setParam(STFilterParamsType.ST_FILTER_STRENGTH, mCurrentFilterStrength);
    }

    private void initObjectTrack(){
        int result = mSTMobileObjectTrackNative.createInstance();
    }

    private void faceAttributeDetect(byte[] data, STHumanAction humanAction){
        if (humanAction != null && data != null && data.length == mImageHeight * mImageWidth * 4) {
            STMobile106[] arrayFaces = null;
            arrayFaces = humanAction.getMobileFaces();

            if (arrayFaces != null && arrayFaces.length != 0) { // face attribute
                STFaceAttribute[] arrayFaceAttribute = new STFaceAttribute[arrayFaces.length];
                long attributeCostTime = System.currentTimeMillis();
                int result = mSTFaceAttributeNative.detect(data, STCommon.ST_PIX_FMT_RGBA8888, mImageWidth, mImageHeight, arrayFaces, arrayFaceAttribute);
                LogUtils.i(TAG, "attribute cost time: %d", System.currentTimeMillis() - attributeCostTime);
                mFaceAttributeCost = System.currentTimeMillis() - attributeCostTime;
                if (result == 0) {
                    if (arrayFaceAttribute[0].attribute_count > 0) {
                        mFaceAttribute = STFaceAttribute.getFaceAttributeString(arrayFaceAttribute[0]);
                    } else {
                        mFaceAttribute = "null";
                    }
                }
            } else {
                mFaceAttribute = null;
                mFaceAttributeCost = 0;
            }
        }
    }

    public void setBeautyParam(int index, float value) {
        if(mBeautifyParams[index] != value){
            mStBeautifyNative.setParam(Constants.beautyTypes[index], value);
            mBeautifyParams[index] = value;
        }
    }

    public float[] getBeautyParams(){
        float[] values = new float[6];
        for(int i = 0; i< mBeautifyParams.length; i++){
            values[i] = mBeautifyParams[i];
        }

        return values;
    }

    public void setShowOriginal(boolean isShow)
    {
        mShowOriginal = isShow;
    }

    /**
     * 工作在opengl线程, 当前Renderer关联的view尺寸改变的时候调用
     *
     * @param gl
     * @param width
     * @param height
     */
    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height) {
        LogUtils.i(TAG, "onSurfaceChanged");
        if (mIsPaused == true) {
            return ;
        }
        adjustViewPort(width, height);

        mGLRender.init(mImageWidth, mImageHeight);
        mStartTime = System.currentTimeMillis();
    }

    /**
     * 根据显示区域大小调整一些参数信息
     *
     * @param width
     * @param height
     */
    private void adjustViewPort(int width, int height) {
        mSurfaceHeight = height;
        mSurfaceWidth = width;
        GLES20.glViewport(0, 0, mSurfaceWidth, mSurfaceHeight);
        mGLRender.calculateVertexBuffer(mSurfaceWidth, mSurfaceHeight, mImageWidth, mImageHeight);
    }

    /**
     * 工作在opengl线程, 具体渲染的工作函数
     *
     * @param gl
     */
    @Override
    public void onDrawFrame(GL10 gl) {
        LogUtils.i(TAG, "onDrawFrame");
        if (mRGBABuffer == null) {
            mRGBABuffer = ByteBuffer.allocate(mImageHeight * mImageWidth * 4);
        }

        if (mBeautifyTextureId == null) {
            mBeautifyTextureId = new int[1];
            GlUtil.initEffectTexture(mImageWidth, mImageHeight, mBeautifyTextureId, GLES20.GL_TEXTURE_2D);
        }

        if (mTextureOutId == null) {
            mTextureOutId = new int[1];
            GlUtil.initEffectTexture(mImageWidth, mImageHeight, mTextureOutId, GLES20.GL_TEXTURE_2D);
        }

        if (mVideoEncoderTexture == null) {
            mVideoEncoderTexture = new int[1];
        }

        if(mVideoTexture != null && !mIsPaused){
            mVideoTexture.updateTexImage();
        }else{
            return;
        }

        mStartTime = System.currentTimeMillis();
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);
        mRGBABuffer.rewind();

        long preProcessCostTime = System.currentTimeMillis();
        int textureId = mGLRender.preProcess(mTextureId, mRGBABuffer);
        int originalTextureId = textureId;
        LogUtils.i(TAG, "preprocess cost time: %d", System.currentTimeMillis() - preProcessCostTime);

        int result = -1;

        if(!mShowOriginal){

            if(mNeedObject) {
                if (mNeedSetObjectTarget) {
                    long startTimeSetTarget = System.currentTimeMillis();

                    STRect inputRect = new STRect(mTargetRect.left, mTargetRect.top, mTargetRect.right, mTargetRect.bottom);

                    mSTMobileObjectTrackNative.setTarget(mRGBABuffer.array(), STCommon.ST_PIX_FMT_RGBA8888, mImageWidth, mImageHeight, inputRect);
                    LogUtils.i(TAG, "setTarget cost time: %d", System.currentTimeMillis() - startTimeSetTarget);
                    mNeedSetObjectTarget = false;
                    mIsObjectTracking = true;
                }

                Rect rect = new Rect(0, 0, 0, 0);

                if (mIsObjectTracking) {
                    long startTimeObjectTrack = System.currentTimeMillis();
                    float[] score = new float[1];
                    STRect outputRect = mSTMobileObjectTrackNative.objectTrack(mRGBABuffer.array(), STCommon.ST_PIX_FMT_RGBA8888, mImageWidth, mImageHeight,score);
                    LogUtils.i(TAG, "objectTrack cost time: %d", System.currentTimeMillis() - startTimeObjectTrack);
                    mObjectCost = System.currentTimeMillis() - startTimeObjectTrack;

                    if(outputRect != null && score != null && score.length >0){
                        rect = STUtils.adjustToScreenRectMin(outputRect.getRect(), mSurfaceWidth, mSurfaceHeight, mImageWidth, mImageHeight);
                    }

                    Message msg = mHandler.obtainMessage(CameraActivity.MSG_DRAW_OBJECT_IMAGE);
                    msg.obj = rect;
                    mHandler.sendMessage(msg);
                    mIndexRect = rect;
                }else{
                    if (mNeedShowRect) {
                        Message msg = mHandler.obtainMessage(CameraActivity.MSG_DRAW_OBJECT_IMAGE_AND_RECT);
                        msg.obj = mIndexRect;
                        mHandler.sendMessage(msg);
                    } else {
                        Message msg = mHandler.obtainMessage(CameraActivity.MSG_DRAW_OBJECT_IMAGE);
                        msg.obj = rect;
                        mHandler.sendMessage(msg);
                        mIndexRect = rect;
                    }
                }
            }else{
                mObjectCost = 0;

                if(!mNeedObject || !(mNeedBeautify || mNeedSticker)){
                    Message msg = mHandler.obtainMessage(CameraActivity.MSG_CLEAR_OBJECT);
                    mHandler.sendMessage(msg);
                }
            }

            if((mNeedBeautify || mNeedSticker) && mIsCreateHumanActionHandleSucceeded) {

                long startHumanAction = System.currentTimeMillis();
                STHumanAction humanAction = mSTHumanActionNative.humanActionDetect(mRGBABuffer.array(), STCommon.ST_PIX_FMT_RGBA8888,
                        mDetectConfig, getCurrentOrientation(), mImageWidth, mImageHeight);
                LogUtils.i(TAG, "human action cost time: %d", System.currentTimeMillis() - startHumanAction);

                if(DEBUG){
                    if(humanAction != null && humanAction.faceCount > 0){
                        long expressionStartTime = System.currentTimeMillis();
                        mFaceExpressionResult = mSTHumanActionNative.getExpression(humanAction, getCurrentOrientation(), false);
                        LogUtils.i(TAG, "face expression cost time: %d", System.currentTimeMillis() - expressionStartTime);

                        Message msg = mHandler.obtainMessage(CameraActivity.MSG_UPDATE_FACE_EXPRESSION_INFO);
                        mHandler.sendMessage(msg);
                    }else {
                        mFaceExpressionResult = null;
                    }
                }

                /**
                 * DEBUG模式，测试使用
                 */
                if(DEBUG){
                    /**
                     * DEBUG模式下，打印segment和handAction结果，测试使用
                     */
                    if(humanAction != null){
                        if(humanAction.getImage() != null){
                            LogUtils.i(TAG, "human action background result: %d", 1);
                        }else{
                            LogUtils.i(TAG, "human action background result: %d", 0);
                        }

                        if(humanAction.hands != null && humanAction.hands.length > 0){
                            mHandAction = humanAction.hands[0].handAction;

                            Message msg = mHandler.obtainMessage(CameraActivity.MSG_UPDATE_HAND_ACTION_INFO);
                            mHandler.sendMessage(msg);
                        }else {
                            mHandAction = 0;
                            Message msg = mHandler.obtainMessage(CameraActivity.MSG_RESET_HAND_ACTION_INFO);
                            mHandler.sendMessage(msg);
                        }
                    }

                    /**
                     * DEBUG模式下，每20帧计算一次人脸属性值，需要先加载人脸属性model和创建句柄，测试使用
                     */
                    if(mFrameCount <= 20){
                        mFrameCount++;
                    }else{
                        mFrameCount = 0;
                        faceAttributeDetect(mRGBABuffer.array(), humanAction);//do face attribute
                    }

                    /**
                     * DEBUG模式下，将240、眼球轮廓和中心点、肢体关键点使用opengl绘制到屏幕，测试使用
                     */
                    if(humanAction != null){
                        if(humanAction.faceCount > 0){
                            for(int i = 0; i < humanAction.faceCount; i++){
                                float[] points = STUtils.getExtraPoints(humanAction, i, mImageWidth, mImageHeight);
                                if(points != null && points.length > 0){
                                    mGLRender.onDrawPoints(textureId, points);
                                }
                            }
                        }

                        if(humanAction.bodyCount > 0){
                            for(int i = 0; i < humanAction.bodyCount; i++){
                                float[] points = STUtils.getBodyKeyPoints(humanAction, i, mImageWidth, mImageHeight);
                                if(points != null && points.length > 0){
                                    mGLRender.onDrawPoints(textureId, points);
                                }
                            }

                            //print body[0] action
                            mBodyAction = humanAction.bodys[0].bodyAction;
                            LogUtils.i(TAG, "human action body count: %d", humanAction.bodyCount);
                            LogUtils.i(TAG, "human action body[0] action: %d", humanAction.bodys[0].bodyAction);

                            Message msg = mHandler.obtainMessage(CameraActivity.MSG_UPDATE_BODY_ACTION_INFO);
                            mHandler.sendMessage(msg);
                        }else {
                            mBodyAction = 0;
                        }

                        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
                    }
                }

                int orientation = getCurrentOrientation();

                //美颜
                if (mNeedBeautify) {// do beautify
                    long beautyStartTime = System.currentTimeMillis();
                    result = mStBeautifyNative.processTexture(textureId, mImageWidth, mImageHeight, orientation, humanAction, mBeautifyTextureId[0], mHumanActionBeautyOutput);
                    long beautyEndTime = System.currentTimeMillis();
                    LogUtils.i(TAG, "beautify cost time: %d", beautyEndTime-beautyStartTime);
                    if (result == 0) {
                        textureId = mBeautifyTextureId[0];
                        humanAction = mHumanActionBeautyOutput;
                        LogUtils.i(TAG, "replace enlarge eye and shrink face action");
                    }
                }

                //调用贴纸API绘制贴纸
                if(mNeedSticker){
                    /**
                     * 1.在切换贴纸时，调用STMobileStickerNative的changeSticker函数，传入贴纸路径(参考setShowSticker函数的使用)
                     * 2.切换贴纸后，使用STMobileStickerNative的getTriggerAction函数获取当前贴纸支持的手势和前后背景等信息，返回值为int类型
                     * 3.根据getTriggerAction函数返回值，重新配置humanActionDetect函数的config参数，使detect更高效
                     *
                     * 例：只检测人脸信息和当前贴纸支持的手势等信息时，使用如下配置：
                     * mDetectConfig = mSTMobileStickerNative.getTriggerAction()|STMobileHumanActionNative.ST_MOBILE_FACE_DETECT;
                    */

                    int event = mCustomEvent;

                    STStickerInputParams inputParams = null;
                    if(mSensorEvent != null && mSensorEvent.values != null && mSensorEvent.values.length > 3){
                        inputParams = new STStickerInputParams(mSensorEvent.values, false, mCustomEvent);
                    }

                    boolean needOutputBuffer = false; //如果需要输出buffer推流或其他，设置该开关为true
                    long stickerStartTime = System.currentTimeMillis();
                    if (!needOutputBuffer) {
                        result = mStStickerNative.processTexture(textureId, humanAction, orientation, STRotateType.ST_CLOCKWISE_ROTATE_0, mImageWidth, mImageHeight,
                                false, inputParams, mTextureOutId[0]);
                    } else {  //如果需要输出buffer用作推流等
                        byte[] imageOut = new byte[mImageWidth * mImageHeight * 4];
                        result = mStStickerNative.processTextureAndOutputBuffer(textureId, humanAction, orientation, STRotateType.ST_CLOCKWISE_ROTATE_0, mImageWidth,
                                mImageHeight, false, inputParams, mTextureOutId[0], STCommon.ST_PIX_FMT_RGBA8888, imageOut);
                    }

                    if(event == mCustomEvent){
                        mCustomEvent = 0;
                    }

                    LogUtils.i(TAG, "processTexture result: %d", result);
                    LogUtils.i(TAG, "sticker cost time: %d", System.currentTimeMillis() - stickerStartTime);

                    if (result == 0) {
                        textureId = mTextureOutId[0];
                    }
                }
            }

            if(mCurrentFilterStyle != mFilterStyle){
                mCurrentFilterStyle = mFilterStyle;
                mSTMobileStreamFilterNative.setStyle(mCurrentFilterStyle);
            }
            if(mCurrentFilterStrength != mFilterStrength){
                mCurrentFilterStrength = mFilterStrength;
                mSTMobileStreamFilterNative.setParam(STFilterParamsType.ST_FILTER_STRENGTH, mCurrentFilterStrength);
            }

            if(mFilterTextureOutId == null){
                mFilterTextureOutId = new int[1];
                GlUtil.initEffectTexture(mImageWidth, mImageHeight, mFilterTextureOutId, GLES20.GL_TEXTURE_2D);
            }

            //滤镜
            if(mNeedFilter){
                long filterStartTime = System.currentTimeMillis();
                int ret = mSTMobileStreamFilterNative.processTexture(textureId, mImageWidth, mImageHeight, mFilterTextureOutId[0]);
                LogUtils.i(TAG, "filter cost time: %d", System.currentTimeMillis() - filterStartTime);
                if(ret == 0){
                    textureId = mFilterTextureOutId[0];
                }
            }

            LogUtils.i(TAG, "frame cost time total: %d", System.currentTimeMillis() - mStartTime + mRotateCost + mObjectCost + mFaceAttributeCost/20);
        }


        if(mNeedSave) {
            savePicture(textureId);
            mNeedSave = false;
        }

        //video capturing
        if(mVideoEncoder != null){
            GLES20.glFinish();
        }

        mVideoEncoderTexture[0] = textureId;
        processStMatrix(mStMatrix);
//        mVideoTexture.getTransformMatrix(mStMatrix);

        synchronized (this) {
            if (mVideoEncoder != null) {
                if(mNeedResetEglContext){
                    mVideoEncoder.setEglContext(EGL14.eglGetCurrentContext(), mVideoEncoderTexture[0]);
                    mNeedResetEglContext = false;
                }
                mVideoEncoder.frameAvailableSoon(mStMatrix);
            }
        }

        mFrameCost = (int)(System.currentTimeMillis() - mStartTime + mRotateCost + mObjectCost + mFaceAttributeCost/20);

        long timer  = System.currentTimeMillis();
        mCount++;
        if(mIsFirstCount){
            mCurrentTime = timer;
            mIsFirstCount = false;
        }else{
            int cost = (int)(timer - mCurrentTime);
            if(cost >= 1000){
                mCurrentTime = timer;
                mFps = (((float)mCount *1000)/cost);
                mCount = 0;
            }
        }

        LogUtils.i(TAG, "render fps: %f", mFps);

        GLES20.glViewport(0, 0, mSurfaceWidth, mSurfaceHeight);

        if(mShowOriginal){
            mGLRender.onDrawFrame(originalTextureId);
        }else{
            mGLRender.onDrawFrame(textureId);
        }
    }

    private void savePicture(int textureId) {
        ByteBuffer mTmpBuffer = ByteBuffer.allocate(mImageHeight * mImageWidth * 4);
        mGLRender.saveTextureToFrameBuffer(textureId, mTmpBuffer);

        mTmpBuffer.position(0);
        Message msg = Message.obtain(mHandler);
        msg.what = CameraActivity.MSG_SAVING_IMG;
        msg.obj = mTmpBuffer;
        Bundle bundle = new Bundle();
        bundle.putInt("imageWidth", mImageWidth);
        bundle.putInt("imageHeight", mImageHeight);
        msg.setData(bundle);
        msg.sendToTarget();
    }

    private int getCurrentOrientation() {
        int dir = Accelerometer.getDirection();
        int orientation = dir - 1;
        if (orientation < 0) {
            orientation = dir ^ 3;
        }

        return orientation;
    }

    private SurfaceTexture.OnFrameAvailableListener mOnFrameAvailableListener = new SurfaceTexture.OnFrameAvailableListener() {

        @Override
        public void onFrameAvailable(SurfaceTexture surfaceTexture) {
            mGlSurfaceView.requestRender();
            if(mNeedPause){
                mMediaPlayer.pause();
            }
        }
    };

    /**
     * camera设备startPreview
     */
    private void setUpVideo() {
        // 初始化Camera设备预览需要的显示区域(mSurfaceTexture)
        if (mTextureId == OpenGLUtils.NO_TEXTURE) {
            mTextureId = OpenGLUtils.getExternalOESTextureID();

            mVideoTexture = new SurfaceTexture(mTextureId);
            mVideoTexture.setOnFrameAvailableListener(mOnFrameAvailableListener);
        }

        try{
            retr = new MediaMetadataRetriever();
            retr.setDataSource(mVideoPath);
        }catch (Exception e){
            Log.e(TAG, "setUpVideo: " + e.getMessage() );

            return;
        }

        rotation = retr.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_ROTATION); // 视频旋转方向
        confirmWidthAndHeight(rotation);
        //开始播放
        prepareVideoAndStart();
    }

    public void setShowSticker(String sticker) {
        mCurrentSticker = sticker;
        mStStickerNative.changeSticker(mCurrentSticker);
        setHumanActionDetectConfig(mNeedBeautify, mStStickerNative.getTriggerAction());
    }

    public void setFilterStyle(String modelPath) {
        mFilterStyle = modelPath;
    }

    public void setFilterStrength(float strength){
        mFilterStrength = strength;
    }

    public long getStickerTriggerAction(){
        return mStStickerNative.getTriggerAction();
    }

    public void onResume() {
        LogUtils.i(TAG, "onResume");
        mIsPaused = false;
        mNeedPause = true;

        mGLRender = new STGLRender();
        mGlSurfaceView.onResume();
        mGlSurfaceView.forceLayout();
        mGlSurfaceView.requestRender();
    }

    public void onPause() {
        LogUtils.i(TAG, "onPause");
        mIsPaused = true;

        if(mMediaPlayer != null){
            mMediaPlayer.pause();
        }

        mGlSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                mSTHumanActionNative.reset();

                mStBeautifyNative.destroyBeautify();
                mStStickerNative.destroyInstance();
                mSTMobileStreamFilterNative.destroyInstance();
                mRGBABuffer = null;
                deleteTextures();
                mGLRender.destroyFrameBuffers();
            }
        });

        mGlSurfaceView.onPause();
    }

    public void onDestroy() {

        if(mMediaPlayer != null){
            mMediaPlayer.stop();
            mMediaPlayer = null;
        }
        //必须释放非opengGL句柄资源,负责内存泄漏
        synchronized (mHumanActionHandleLock) {
            mSTHumanActionNative.destroyInstance();
        }
        mSTFaceAttributeNative.destroyInstance();
        mSTMobileObjectTrackNative.destroyInstance();
    }

    /**
     * 释放纹理资源
     */
    protected void deleteTextures() {
        LogUtils.i(TAG, "delete textures");
        deleteCameraPreviewTexture();
        deleteInternalTextures();
    }

    // must in opengl thread
    private void deleteCameraPreviewTexture() {
        if (mTextureId != OpenGLUtils.NO_TEXTURE) {
            GLES20.glDeleteTextures(1, new int[]{
                    mTextureId
            }, 0);
        }
        mTextureId = OpenGLUtils.NO_TEXTURE;
    }

    private void deleteInternalTextures() {
        if (mBeautifyTextureId != null) {
            GLES20.glDeleteTextures(1, mBeautifyTextureId, 0);
            mBeautifyTextureId = null;
        }

        if (mTextureOutId != null) {
            GLES20.glDeleteTextures(1, mTextureOutId, 0);
            mTextureOutId = null;
        }

        if(mFilterTextureOutId != null){
            GLES20.glDeleteTextures(1, mFilterTextureOutId, 0);
            mFilterTextureOutId = null;
        }

        if(mVideoEncoderTexture != null){
            GLES20.glDeleteTextures(1, mVideoEncoderTexture, 0);
            mVideoEncoderTexture = null;
        }
    }

    public void enableObject(boolean enabled){
        mNeedObject = enabled;

        if(mNeedObject){
            resetIndexRect();
        }
    }

    public void setIndexRect(int x, int y, boolean needRect){
        mIndexRect = new Rect(x, y, x + mScreenIndexRectWidth, y + mScreenIndexRectWidth);
        mNeedShowRect = needRect;
    }

    public Rect getIndexRect(){
        return mIndexRect;
    }

    public void setObjectTrackRect(){
        mNeedSetObjectTarget = true;
        mIsObjectTracking = false;
        mTargetRect = STUtils.adjustToImageRectMin(getIndexRect(), mSurfaceWidth, mSurfaceHeight, mImageWidth,mImageHeight);
    }

    public void disableObjectTracking(){
        mIsObjectTracking = false;
    }

    public void resetObjectTrack(){
        mSTMobileObjectTrackNative.reset();
    }

    public void resetIndexRect(){
        if(mImageWidth == 0){
            return;
        }

        mScreenIndexRectWidth = mSurfaceWidth/4;

        mIndexRect.left = (mSurfaceWidth - mScreenIndexRectWidth)/2;
        mIndexRect.top = (mSurfaceHeight - mScreenIndexRectWidth)/2;
        mIndexRect.right = mIndexRect.left + mScreenIndexRectWidth;
        mIndexRect.bottom = mIndexRect.top + mScreenIndexRectWidth;

        mNeedShowRect = true;
        mNeedSetObjectTarget = false;
        mIsObjectTracking = false;
    }

    public int getPreviewWidth(){
        return mImageWidth;
    }

    public int getPreviewHeight(){
        return mImageHeight;
    }

    public void setVideoEncoder(final MediaVideoEncoder encoder) {

        mGlSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                synchronized (this) {
                    if (encoder != null) {
                        encoder.setEglContext(EGL14.eglGetCurrentContext(), mVideoEncoderTexture[0]);
                    }
                    mVideoEncoder = encoder;
                }
            }
        });
    }

    public int getFrameCost(){
        return mFrameCost;
    }

    public float getFpsInfo(){
        return (float)(Math.round(mFps * 10))/10;
    }

    public void addSubModelByName(String modelName){
        Message msg = mSubModelsManagerHandler.obtainMessage(MESSAGE_ADD_SUB_MODEL);
        msg.obj = modelName;

        mSubModelsManagerHandler.sendMessage(msg);
    }

    public void removeSubModelByConfig(int Config){
        Message msg = mSubModelsManagerHandler.obtainMessage(MESSAGE_REMOVE_SUB_MODEL);
        msg.obj = Config;
        mSubModelsManagerHandler.sendMessage(msg);
    }

    public long getHandActionInfo(){
        return mHandAction;
    }

    public long getBodyActionInfo(){
        return mBodyAction;
    }

    public boolean[] getFaceExpressionInfo(){
        return mFaceExpressionResult;
    }

    public void changeCustomEvent(){
        mCustomEvent = STCustomEvent.ST_CUSTOM_EVENT_1 | STCustomEvent.ST_CUSTOM_EVENT_2;
    }

    public void setSensorEvent(SensorEvent event){
        mSensorEvent =  event;
    }

    public void StartPlayVideo(){
        if(mMediaPlayer != null){
            mNeedPause = false;

            mTimerTask = new TimerTask() {
                @Override
                public void run() {
                    if(mMediaPlayer != null){
                        int position = mMediaPlayer.getCurrentPosition();
                        int duration = mMediaPlayer.getDuration();
                        if (duration > 0) {
                            Message msg = mHandler.obtainMessage(VideoPlayerActivity.MSG_MEDIA_PROGRESS_UPDTAE);
                            msg.arg1 = position;
                            mHandler.sendMessage(msg);
                        }
                    }
                }
            };
            mMediaPlayer.start();
            mTimer.schedule(mTimerTask,0,500);
        }
    }

    public void StopPlayViedo(){
        if(mMediaPlayer != null){
            try {
                mMediaPlayer.pause();
                mMediaPlayer.seekTo(0);
            }catch (Exception e){
                e.printStackTrace();
            }
        }
    }

    public void setmIsFirstPlaying(boolean firstPlaying){
        this.mIsFirstPlaying = firstPlaying;
    }

    private void processStMatrix(float[] matrix){
        matrix[0] = 1f;
        matrix[1] = 0f;
        matrix[2] = 0f;
        matrix[3] = 0f;
        matrix[4] = 0f;
        matrix[5] = -1.0f;
        matrix[6] = 0f;
        matrix[7] = 0f;
        matrix[8] = 0f;
        matrix[9] = 0f;
        matrix[10] = 1f;
        matrix[11] = 0f;
        matrix[12] = 0f;
        matrix[13] = 1.0f;
        matrix[14] = 0f;
        matrix[15] = 1f;
        return;
    }
}
