package sensetime.senseme.com.effects.display;

import android.content.Context;
import android.graphics.Rect;
import android.graphics.SurfaceTexture;
import android.hardware.Camera;
import android.hardware.SensorEvent;
import android.opengl.EGL14;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLSurfaceView.Renderer;
import android.os.Bundle;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.util.Log;

import com.sensetime.stmobile.STBeautifyNative;
import com.sensetime.stmobile.STBeautyParamsType;
import com.sensetime.stmobile.STCommon;
import com.sensetime.stmobile.STFilterParamsType;
import com.sensetime.stmobile.STHumanActionParamsType;
import com.sensetime.stmobile.STMobileAnimalNative;
import com.sensetime.stmobile.STMobileAvatarNative;
import com.sensetime.stmobile.STMobileFaceAttributeNative;
import com.sensetime.stmobile.STMobileHumanActionNative;
import com.sensetime.stmobile.STMobileMakeupNative;
import com.sensetime.stmobile.STMobileObjectTrackNative;
import com.sensetime.stmobile.STMobileStickerNative;
import com.sensetime.stmobile.STMobileStreamFilterNative;
import com.sensetime.stmobile.STRotateType;
import com.sensetime.stmobile.model.STAnimalFace;
import com.sensetime.stmobile.model.STCondition;
import com.sensetime.stmobile.model.STFaceAttribute;
import com.sensetime.stmobile.model.STHumanAction;
import com.sensetime.stmobile.model.STMobile106;
import com.sensetime.stmobile.model.STRect;
import com.sensetime.stmobile.model.STStickerInputParams;
import com.sensetime.stmobile.model.STTransParam;
import com.sensetime.stmobile.model.STTriggerEvent;
import com.sensetime.stmobile.sticker_module_types.STAnimationStateType;
import com.sensetime.stmobile.sticker_module_types.STCustomEvent;
import com.sensetime.stmobile.sticker_module_types.STModuleInfo;
import com.sensetime.stmobile.sticker_module_types.STStickerModuleParamType;
import com.sensetime.stmobile.sticker_module_types.STTriggerEventType;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.Queue;
import java.util.TreeMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingDeque;
import java.util.concurrent.LinkedBlockingQueue;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import sensetime.senseme.com.effects.CameraActivity;
import sensetime.senseme.com.effects.camera.CameraProxy;
import sensetime.senseme.com.effects.encoder.MediaVideoEncoder;
import sensetime.senseme.com.effects.glutils.GlUtil;
import sensetime.senseme.com.effects.glutils.OpenGLUtils;
import sensetime.senseme.com.effects.glutils.STUtils;
import sensetime.senseme.com.effects.glutils.TextureRotationUtil;
import sensetime.senseme.com.effects.utils.Accelerometer;
import sensetime.senseme.com.effects.utils.Constants;
import sensetime.senseme.com.effects.utils.FileUtils;
import sensetime.senseme.com.effects.utils.LogUtils;
import sensetime.senseme.com.effects.view.ByteWrapper;

/**
 * CameraDisplayDoubleInput is used for camera preview
 */

/**
 * 渲染结果显示的Render, 用户最终看到的结果在这个类中得到并显示.
 * 请重点关注Camera.PreviewCallback的onPreviewFrame/onSurfaceCreated,onSurfaceChanged,onDrawFrame
 * 四个接口, 基本上所有的处理逻辑都是围绕这四个接口展开
 */
public class CameraDisplayDoubleInputMultithread implements Renderer {

    private String TAG = "CameraDisplayDoubleInputMultithread";
    private boolean DEBUG = false;

    private boolean mNeedBeautyOutputBuffer = false;
    private boolean mNeedStickerOutputBuffer = false;
    private boolean mNeedFilterOutputBuffer = false;

    private boolean mNeedAvatar = true;
    private boolean mNeedAvatarExpression = false;

    /**
     * SurfaceTexure texture id
     */
    protected int mTextureId = OpenGLUtils.NO_TEXTURE;
    private int initTextureId[] = new int[1];

    private int mImageWidth;
    private int mImageHeight;
    private GLSurfaceView mGlSurfaceView;
    private ChangePreviewSizeListener mListener;
    private int mSurfaceWidth;
    private int mSurfaceHeight;

    private Context mContext;

    public CameraProxy mCameraProxy;
    private SurfaceTexture mSurfaceTexture;
    private String mCurrentSticker;
    private String mCurrentFilterStyle;
    private float mCurrentFilterStrength = 0.65f;//阈值为[0,1]
    private float mFilterStrength = 0.65f;
    private String mFilterStyle;

    private int mCameraID = Camera.CameraInfo.CAMERA_FACING_FRONT;
    private STGLRender mGLRender;
    private STMobileStickerNative mStStickerNative = new STMobileStickerNative();
    private STBeautifyNative mStBeautifyNative = new STBeautifyNative();
    private STMobileHumanActionNative mSTHumanActionNative = new STMobileHumanActionNative();
    private STHumanAction mHumanActionBeautyOutput = new STHumanAction();
    private STMobileAnimalNative mStAnimalNative = new STMobileAnimalNative();
    private STMobileStreamFilterNative mSTMobileStreamFilterNative = new STMobileStreamFilterNative();
    private STMobileFaceAttributeNative mSTFaceAttributeNative = new STMobileFaceAttributeNative();
    private STMobileObjectTrackNative mSTMobileObjectTrackNative = new STMobileObjectTrackNative();
    private STMobileAvatarNative mSTMobileAvatarNative = new STMobileAvatarNative();
    private STMobileMakeupNative mSTMobileMakeupNative = new STMobileMakeupNative();

    private ByteBuffer mRGBABuffer;
    private int[] mBeautifyTextureId, mMakeupTextureId;
    private int[] mTextureOutId;
    private int[] mFilterTextureOutId;
    private boolean mCameraChanging = false;
    private int mCurrentPreview = 0;
    private ArrayList<String> mSupportedPreviewSizes;
    private boolean mSetPreViewSizeSucceed = false;
    private boolean mIsChangingPreviewSize = false;

    private long mStartTime;
    private boolean mShowOriginal = false;
    private boolean mNeedBeautify = false;
    private boolean mNeedFaceAttribute = false;
    private boolean mNeedSticker = false;
    private boolean mNeedFilter = false;
    private boolean mNeedSave = false;
    private boolean mNeedBlur = false;
    private boolean mNeedObject = false;
    private boolean mCreateObjectTrackSucceeded = false;
    private boolean mNeedMakeup = false;
    private FloatBuffer mTextureBuffer;
    private float[] mBeautifyParams = {0.36f, 0.74f, 0.02f, 0.13f, 0.11f, 0.1f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f};
    private Handler mHandler;
    private String mFaceAttribute;
    private boolean mIsPaused = false;
    private long mDetectConfig = 0;
    private boolean mIsCreateHumanActionHandleSucceeded = false;
    private Object mHumanActionHandleLock = new Object();
    private Object mImageDataLock = new Object();

    private boolean mNeedShowRect = true;
    private int mScreenIndexRectWidth = 0;

    private Rect mTargetRect = new Rect();
    private Rect mIndexRect = new Rect();
    private boolean mNeedSetObjectTarget = false;
    private boolean mIsObjectTracking = false;

    private int mHumanActionCreateConfig = STMobileHumanActionNative.ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO;
    private ByteWrapper mNv21ImageData;
    private byte[][] mDataBuffer = new byte[2][];

    private HandlerThread mProcessImageThread;
    private HandlerThread mHumanActionDetectThread;
    private Handler mProcessImageHandler;
    private ExecutorService mDetectThreadPool = Executors.newFixedThreadPool(1);
    private static final int MESSAGE_PROCESS_IMAGE = 100;
    private static final int MESSAGE_DETECT_HUMANACTION = 101;
    private byte[] mImageData;
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
    private float[] mStMatrix = new float[16];
    private int[] mVideoEncoderTexture;
    private boolean mNeedResetEglContext = false;

    private static final int MESSAGE_ADD_SUB_MODEL = 1001;
    private static final int MESSAGE_REMOVE_SUB_MODEL = 1002;
    private static final int MESSAGE_NEED_CHANGE_STICKER = 1003;
    private static final int MESSAGE_NEED_REMOVE_STICKER = 1004;
    private static final int MESSAGE_NEED_REMOVEALL_STICKERS = 1005;
    private static final int MESSAGE_NEED_ADD_STICKER = 1006;

    private HandlerThread mSubModelsManagerThread;
    private Handler mSubModelsManagerHandler;

    private HandlerThread mChangeStickerManagerThread;
    private Handler mChangeStickerManagerHandler;

    private long mHandAction = 0;
    private long mBodyAction = 0;
    private boolean[] mFaceExpressionResult;
    private int mCustomEvent = 0;
    private SensorEvent mSensorEvent;

    private TreeMap<Integer, String> mCurrentStickerMaps = new TreeMap<>();
    private int mParamType = 0;
    STHumanAction humanAction;
    STHumanAction rotatedHumanAction;
    int textureIdBuffer[] = new int[2];
    boolean renderFlag = false;
    boolean dectetStarted = false;
    Object mLock = new Object();
    private ByteBuffer frameRenderBuffer = null;
    private boolean frameBufferReady = false;
    private int[] mTextureY;
    private int[] mTextureUV;
    private boolean nv21YUVDataDirty;
    private boolean mTextureInit = false;
    private boolean mFirstRender = true;
    private boolean mBufferFilled = false;
    private int mInputTextureId;
    LinkedBlockingDeque<ByteWrapper> mLBDQ = new LinkedBlockingDeque<>();
    private Queue<STHumanAction> queue = new LinkedBlockingQueue<>();
    private boolean mInited = false;
    private STAnimalFace[] mAnimalFace;
    private int animalFaceLlength = 0;
    private boolean needAnimalDetect = false;
    private float[] avatarExpression = new float[54];
    private STStickerEventCallback mSTStickerEventCallback;

    private boolean mNeedDistance = true;
    private float mFaceDistance = 0f;

    private int[] mMakeupPackageId = new int[Constants.MAKEUP_TYPE_COUNT];
    private String[] mCurrentMakeup = new String[Constants.MAKEUP_TYPE_COUNT];
    private float[] mMakeupStrength = new float[Constants.MAKEUP_TYPE_COUNT];
    private float mMakeUpStrength = 0.7f;

    public CameraDisplayDoubleInputMultithread(Context context, ChangePreviewSizeListener listener, GLSurfaceView glSurfaceView) {
        mCameraProxy = new CameraProxy(context);
        mGlSurfaceView = glSurfaceView;
        mListener = listener;
        mContext = context;
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
        initCatFace();
        initObjectTrack();

        if (mNeedAvatarExpression) initAvatar();

        if (DEBUG) {
            initFaceAttribute();
        }

        initHandlerManager();
    }

    private void initHandlerManager() {
        mProcessImageThread = new HandlerThread("ProcessImageThread");
        mProcessImageThread.start();
        mProcessImageHandler = new Handler(mProcessImageThread.getLooper()) {
            @Override
            public void handleMessage(Message msg) {
                if (msg.what == MESSAGE_PROCESS_IMAGE && !mIsPaused && !mCameraChanging) {
                    objectTrack();
                }
            }
        };

        mHumanActionDetectThread = new HandlerThread("mHumanActionDetectThread");
        mHumanActionDetectThread.start();

        mSubModelsManagerThread = new HandlerThread("SubModelManagerThread");
        mSubModelsManagerThread.start();
        mSubModelsManagerHandler = new Handler(mSubModelsManagerThread.getLooper()) {
            @Override
            public void handleMessage(Message msg) {
                if (!mIsPaused && !mCameraChanging && mIsCreateHumanActionHandleSucceeded) {
                    switch (msg.what) {
                        case MESSAGE_ADD_SUB_MODEL:
                            String modelName = (String) msg.obj;
                            if (modelName != null) {
                                addSubModel(modelName);
                            }
                            break;

                        case MESSAGE_REMOVE_SUB_MODEL:
                            int config = (int) msg.obj;
                            if (config != 0) {
                                removeSubModel(config);
                            }
                            break;

                        default:
                            break;
                    }
                }
            }
        };

        mChangeStickerManagerThread = new HandlerThread("ChangeStickerManagerThread");
        mChangeStickerManagerThread.start();
        mChangeStickerManagerHandler = new Handler(mChangeStickerManagerThread.getLooper()) {
            @Override
            public void handleMessage(Message msg) {
                if (!mIsPaused && !mCameraChanging) {
                    switch (msg.what) {
                        case MESSAGE_NEED_CHANGE_STICKER:
                            String sticker = (String) msg.obj;
                            mCurrentSticker = sticker;
                            int result = mStStickerNative.changeSticker(mCurrentSticker);
                            LogUtils.i(TAG, "change sticker result: %d", result);
                            mParamType = mStStickerNative.getNeededInputParams();
                            setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
                            Message message = mHandler.obtainMessage(CameraActivity.MSG_NEED_UPDATE_STICKER_TIPS);
                            mHandler.sendMessage(message);
                            break;
                        case MESSAGE_NEED_ADD_STICKER:
//                            String addSticker = (String) msg.obj;
//                            mCurrentSticker = addSticker;
//                            int stickerId = mStStickerNative.addSticker(mCurrentSticker);
//
//                            if(mCurrentStickerMaps != null){
//                                mCurrentStickerMaps.put(stickerId, mCurrentSticker);
//                            }
//                            setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction());
//
//                            Message messageAdd = mHandler.obtainMessage(CameraActivity.MSG_NEED_UPDATE_STICKER_MAP);
//                            messageAdd.arg1 = stickerId;
//                            mHandler.sendMessage(messageAdd);
//
//                            Message message1 = mHandler.obtainMessage(CameraActivity.MSG_NEED_UPDATE_STICKER_TIPS);
//                            mHandler.sendMessage(message1);
                            break;
                        case MESSAGE_NEED_REMOVE_STICKER:
                            int packageId = (int) msg.obj;
                            result = mStStickerNative.removeSticker(packageId);

                            if (mCurrentStickerMaps != null && result == 0) {
                                mCurrentStickerMaps.remove(packageId);
                            }
                            setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
                            break;
                        case MESSAGE_NEED_REMOVEALL_STICKERS:
                            mStStickerNative.removeAllStickers();
                            if (mCurrentStickerMaps != null) {
                                mCurrentStickerMaps.clear();
                            }
                            setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
                            break;
                        default:
                            break;
                    }
                }
            }
        };
    }

    private void addSubModel(final String modelName) {
        synchronized (mHumanActionHandleLock) {
            int result = mSTHumanActionNative.addSubModelFromAssetFile(modelName, mContext.getAssets());
            LogUtils.i(TAG, "add sub model result: %d", result);

            if (result == 0) {
                if (modelName.equals(FileUtils.MODEL_NAME_BODY_FOURTEEN)) {
                    mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_BODY_KEYPOINTS;
                    mSTHumanActionNative.setParam(STHumanActionParamsType.ST_HUMAN_ACTION_PARAM_BODY_LIMIT, 3.0f);
                } else if (modelName.equals(FileUtils.MODEL_NAME_FACE_EXTRA)) {
                    mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_DETECT_EXTRA_FACE_POINTS;
                } else if (modelName.equals(FileUtils.MODEL_NAME_EYEBALL_CONTOUR)) {
                    mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_DETECT_EYEBALL_CONTOUR |
                            STMobileHumanActionNative.ST_MOBILE_DETECT_EYEBALL_CENTER;
                } else if (modelName.equals(FileUtils.MODEL_NAME_HAND)) {
                    mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_HAND_DETECT_FULL;
                } else if (modelName.equals(FileUtils.MODEL_NAME_AVATAR_HELP)) {
                    mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_DETECT_AVATAR_HELPINFO;
                }
            }
        }
    }

    private void removeSubModel(final int config) {
        synchronized (mHumanActionHandleLock) {
            int result = mSTHumanActionNative.removeSubModelByConfig(config);
            LogUtils.i(TAG, "remove sub model result: %d", result);

            if (config == STMobileHumanActionNative.ST_MOBILE_ENABLE_BODY_KEYPOINTS) {
                mDetectConfig &= ~STMobileHumanActionNative.ST_MOBILE_BODY_KEYPOINTS;
            } else if (config == STMobileHumanActionNative.ST_MOBILE_ENABLE_FACE_EXTRA_DETECT) {
                mDetectConfig &= ~STMobileHumanActionNative.ST_MOBILE_DETECT_EXTRA_FACE_POINTS;
            } else if (config == STMobileHumanActionNative.ST_MOBILE_ENABLE_EYEBALL_CONTOUR_DETECT) {
                mDetectConfig &= ~(STMobileHumanActionNative.ST_MOBILE_DETECT_EYEBALL_CONTOUR |
                        STMobileHumanActionNative.ST_MOBILE_DETECT_EYEBALL_CENTER);
            } else if (config == STMobileHumanActionNative.ST_MOBILE_ENABLE_HAND_DETECT) {
                mDetectConfig &= ~STMobileHumanActionNative.ST_MOBILE_HAND_DETECT_FULL;
            } else if (config == STMobileHumanActionNative.ST_MOBILE_DETECT_AVATAR_HELPINFO) {
                mDetectConfig &= ~STMobileHumanActionNative.ST_MOBILE_DETECT_AVATAR_HELPINFO;
            }
        }
    }

    public void enableBeautify(boolean needBeautify) {
        mNeedBeautify = needBeautify;
        setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
        mNeedResetEglContext = true;
    }

    public void enableSticker(boolean needSticker) {
        mNeedSticker = needSticker;
        //reset humanAction config
        if (!needSticker) {
            setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
        }

        mNeedResetEglContext = true;
    }

    public void enableFilter(boolean needFilter) {
        mNeedFilter = needFilter;
        mNeedResetEglContext = true;
    }

    public void enableMakeUp(boolean needMakeup) {
        mNeedMakeup = needMakeup;
        mNeedResetEglContext = true;

        setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
    }

    public boolean getFaceAttribute() {
        return mNeedFaceAttribute;
    }

    public String getFaceAttributeString() {
        return mFaceAttribute;
    }

    public boolean getSupportPreviewsize(int size) {
        if (size == 0 && mSupportedPreviewSizes.contains("640x480")) {
            return true;
        } else if (size == 1 && mSupportedPreviewSizes.contains("1280x720")) {
            return true;
        } else {
            return false;
        }
    }

    public void setSaveImage() {
        mNeedSave = true;
    }

    public void toBlur() {
        mNeedBlur = true;
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
            return;
        }
        GLES20.glEnable(GL10.GL_DITHER);
        GLES20.glClearColor(0, 0, 0, 0);
        GLES20.glEnable(GL10.GL_DEPTH_TEST);

        while (!mCameraProxy.isCameraOpen()) {
            if (mCameraProxy.cameraOpenFailed()) {
                return;
            }
            try {
                Thread.sleep(10, 0);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }

        if (mCameraProxy.getCamera() != null) {
            setUpCamera();
        }

        //初始化GL相关的句柄，包括美颜，贴纸，滤镜
        initBeauty();
        initSticker();
        initFilter();
        initMakeup();
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
                    //从sd读取model路径，创建handle
                    //int result = mSTHumanActionNative.createInstance(FileUtils.getTrackModelPath(mContext), mHumanActionCreateConfig);

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

                        //240
                        result = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_FACE_EXTRA, mContext.getAssets());
                        LogUtils.i(TAG, "add face extra model result: %d", result);

                        //eye
                        result = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_EYEBALL_CONTOUR, mContext.getAssets());
                        LogUtils.i(TAG, "add eyeball contour model result: %d", result);

                        //for test avatar
                        if (mNeedAvatar) {
                            int ret = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_AVATAR_HELP, mContext.getAssets());
                            LogUtils.i(TAG, "add avatar help model result: %d", ret);

//                            ret = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_TONGUE, mContext.getAssets());
//                            LogUtils.i(TAG,"add tongue model result: %d", ret );
                        }
                    }
                }
            }
        }).start();
    }

    private void initCatFace() {
        //int result = mStAnimalNative.createInstance(FileUtils.getFilePath(mContext, FileUtils.MODEL_NAME_CATFACE_CORE), STCommon.ST_MOBILE_TRACKING_MULTI_THREAD);
        int result = mStAnimalNative.createInstanceFromAssetFile(FileUtils.MODEL_NAME_CATFACE_CORE, STCommon.ST_MOBILE_TRACKING_MULTI_THREAD, mContext.getAssets());
        LogUtils.i(TAG, "create animal handle result: %d", result);
    }

    private void initSticker() {
        int result = mStStickerNative.createInstance(mContext);

        if (result == 0) {
            mSTStickerEventCallback = new STStickerEventCallback();
        }

        if (mNeedSticker && mCurrentStickerMaps.size() == 0) {
            mStStickerNative.changeSticker(mCurrentSticker);
        }

        if (mNeedSticker && mCurrentStickerMaps != null) {
            TreeMap<Integer, String> currentStickerMap = new TreeMap<>();

            for (Integer index : mCurrentStickerMaps.keySet()) {
                String sticker = mCurrentStickerMaps.get(index);//得到每个key多对用value的值

                int packageId = mStStickerNative.addSticker(sticker);
                currentStickerMap.put(packageId, sticker);

                Message messageReplace = mHandler.obtainMessage(CameraActivity.MSG_NEED_REPLACE_STICKER_MAP);
                messageReplace.arg1 = index;
                messageReplace.arg2 = packageId;
                mHandler.sendMessage(messageReplace);
            }

            mCurrentStickerMaps.clear();

            Iterator<Integer> iter = currentStickerMap.keySet().iterator();
            while (iter.hasNext()) {
                int key = iter.next();
                mCurrentStickerMaps.put(key, currentStickerMap.get(key));
            }
        }

        //从sd卡加载Avatar模型
        //mStStickerNative.loadAvatarModel(FileUtils.getAvatarCoreModelPath(mContext));

        //从资源文件加载Avatar模型
        mStStickerNative.loadAvatarModelFromAssetFile(FileUtils.MODEL_NAME_AVATAR_CORE, mContext.getAssets());

        setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
        LogUtils.i(TAG, "the result for createInstance for human_action is %d", result);
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
        }
    }

    /**
     * human action detect的配置选项,根据Sticker的TriggerAction和是否需要美颜配置
     *
     * @param needFaceDetect 是否需要开启face detect
     * @param stickerConfig  sticker的TriggerAction
     * @param makeupConfig   makeup的TriggerAction
     */
    private void setHumanActionDetectConfig(boolean needFaceDetect, long stickerConfig, long makeupConfig) {
        if (!mNeedSticker || mCurrentSticker == null) {
            stickerConfig = 0;
        }

        if (!mNeedMakeup) {
            makeupConfig = 0;
        }

        if (needFaceDetect) {
            mDetectConfig = (stickerConfig | makeupConfig | STMobileHumanActionNative.ST_MOBILE_FACE_DETECT);
        } else {
            mDetectConfig = stickerConfig | makeupConfig;
        }

        needAnimalDetect = ((mStStickerNative.getAnimalDetectConfig() & STMobileAnimalNative.ST_MOBILE_CAT_DETECT) > 0);
    }

    private void initFilter() {
        int result = mSTMobileStreamFilterNative.createInstance();
        LogUtils.i(TAG, "filter create instance result %d", result);

        mSTMobileStreamFilterNative.setStyle(mCurrentFilterStyle);

        mCurrentFilterStrength = mFilterStrength;
        mSTMobileStreamFilterNative.setParam(STFilterParamsType.ST_FILTER_STRENGTH, mCurrentFilterStrength);
    }

    private void initMakeup() {
        int result = mSTMobileMakeupNative.createInstance();
        LogUtils.i(TAG, "makeup create instance result %d", result);

        for (int i = 0; i < Constants.MAKEUP_TYPE_COUNT; i++) {
            if (mMakeupPackageId[i] > 0) {
                setMakeupForType(i, mCurrentMakeup[i]);
                setStrengthForType(i, mMakeupStrength[i]);
            }
        }

        setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
    }

    private void initAvatar() {
        int result = mSTMobileAvatarNative.createInstanceFromAssetFile(FileUtils.MODEL_NAME_AVATAR_CORE, mContext.getAssets());
        LogUtils.i(TAG, "create avatar handle result: %d", result);
    }

    private void setUpTexture() {
        // nv21 y texture
        mTextureY = new int[1];
        GLES20.glGenTextures(1, mTextureY, 0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mTextureY[0]);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);

        // nv21 uv texture
        mTextureUV = new int[1];
        GLES20.glGenTextures(1, mTextureUV, 0);
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mTextureUV[0]);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
        GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
    }

    private void initObjectTrack() {
        int result = mSTMobileObjectTrackNative.createInstance();

        if (result == 0) {
            mCreateObjectTrackSucceeded = true;
        }
    }

    private void objectTrack() {
        if (mImageData == null || mImageData.length == 0) {
            return;
        }

        if (mNeedObject && mCreateObjectTrackSucceeded) {
            if (mNeedSetObjectTarget) {
                long startTimeSetTarget = System.currentTimeMillis();

                mTargetRect = STUtils.getObjectTrackInputRect(mTargetRect, mImageWidth, mImageHeight, mCameraID, mCameraProxy.getOrientation());
                STRect inputRect = new STRect(mTargetRect.left, mTargetRect.top, mTargetRect.right, mTargetRect.bottom);

                mSTMobileObjectTrackNative.setTarget(mImageData, STCommon.ST_PIX_FMT_NV21, mImageHeight, mImageWidth, inputRect);
                LogUtils.i(TAG, "setTarget cost time: %d", System.currentTimeMillis() - startTimeSetTarget);
                mNeedSetObjectTarget = false;
                mIsObjectTracking = true;
            }

            Rect rect = new Rect(0, 0, 0, 0);

            if (mIsObjectTracking) {
                long startTimeObjectTrack = System.currentTimeMillis();
                float[] score = new float[1];
                STRect outputRect = mSTMobileObjectTrackNative.objectTrack(mImageData, STCommon.ST_PIX_FMT_NV21, mImageHeight, mImageWidth, score);
                LogUtils.i(TAG, "objectTrack cost time: %d", System.currentTimeMillis() - startTimeObjectTrack);
                mObjectCost = System.currentTimeMillis() - startTimeObjectTrack;

                if (outputRect != null && score != null && score.length > 0) {
                    Rect outputTargetRect = new Rect(outputRect.getRect().left, outputRect.getRect().top, outputRect.getRect().right, outputRect.getRect().bottom);
                    outputTargetRect = STUtils.getObjectTrackOutputRect(outputTargetRect, mImageWidth, mImageHeight, mCameraID, mCameraProxy.getOrientation());

                    rect = STUtils.adjustToScreenRectMin(outputTargetRect, mSurfaceWidth, mSurfaceHeight, mImageWidth, mImageHeight);

                    if (!mNeedShowRect) {
                        Message msg = mHandler.obtainMessage(CameraActivity.MSG_DRAW_OBJECT_IMAGE);
                        msg.obj = rect;
                        mHandler.sendMessage(msg);
                        mIndexRect = rect;
                    }
                }

            } else {
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
        } else {
            mObjectCost = 0;

            if (!mNeedObject || !(mNeedBeautify || mNeedSticker || mNeedFaceAttribute)) {
                Message msg = mHandler.obtainMessage(CameraActivity.MSG_CLEAR_OBJECT);
                mHandler.sendMessage(msg);
            }
        }
    }


    private void humanActionDetect(byte[] data) {
        dectetStarted = true;
        long startHumanAction = System.currentTimeMillis();
        //如果使用前置摄像头，请注意显示的图像与帧图像左右对称，需处理坐标

        int dir = getHumanActionDetectDir(mCameraProxy.getOrientation(), Accelerometer.getDirection());
        humanAction = mSTHumanActionNative.humanActionDetect(data, STCommon.ST_PIX_FMT_NV21,
                mDetectConfig, dir, mImageHeight, mImageWidth);
        LogUtils.i(TAG, "human action cost time: %d", System.currentTimeMillis() - startHumanAction);

        if (mNeedAvatarExpression) {
            if (humanAction.getFaceInfos() != null) {
                mSTMobileAvatarNative.avatarExpressionDetect(dir, mImageWidth, mImageHeight, humanAction.getFaceInfos()[0], avatarExpression);
                Log.d("avatarExpressionResult:", Arrays.toString(avatarExpression));
            }
        }

        if (mNeedDistance) {
            if (humanAction != null && humanAction.faceCount > 0) {
                long distanceStartTime = System.currentTimeMillis();
                mFaceDistance = mSTHumanActionNative.getFaceDistance(humanAction.faces[0], dir, mImageHeight, mImageWidth, mCameraProxy.getCamera().getParameters().getVerticalViewAngle());
                LogUtils.i(TAG, "human action face distance cost time: %d", System.currentTimeMillis() - distanceStartTime);
            } else {
                //无人脸信息
                mFaceDistance = 0f;
            }
        }

        if (humanAction != null && humanAction.faceCount > 0) {
            Log.e(TAG, "humanActionDetect faceActionScoreCount: " + humanAction.faces[0].faceActionScoreCount);
            if (humanAction.faces[0].faceActionScore != null) {
                for (int i = 0; i < humanAction.faces[0].faceActionScore.length; i++) {
                    Log.e(TAG, "humanActionDetect faceAction ret: index: " + i + ",  score: " + humanAction.faces[0].faceActionScore[i]);
                }

            }
        }

        synchronized (mLock) {
            humanAction = STHumanAction.humanActionRotateAndMirror(humanAction, mImageWidth, mImageHeight, mCameraID, mCameraProxy.getOrientation());
            queue.add(humanAction);
            mLock.notify();
        }
    }

    private int getHumanActionDetectDir(int cameraOrientation, int mobileOrientation) {
        int dir = 0;
        switch (cameraOrientation) {
            case 0:
                dir = (mobileOrientation + 3) % 4;
                break;
            case 90:
                dir = mobileOrientation;
                break;
            case 180:
                dir = (mobileOrientation + 1) % 4;
                break;
            case 270:
                dir = mobileOrientation;
                if ((mobileOrientation & 1) == 1) {
                    dir = mobileOrientation ^ 2;
                }
                break;
        }
        return dir;
    }

    private void faceAttributeDetect(byte[] data, STHumanAction humanAction) {
        if (humanAction != null && data != null && data.length == mImageWidth * mImageHeight * 3 / 2) {
            STMobile106[] arrayFaces = null;
            arrayFaces = humanAction.getMobileFaces();

            if (arrayFaces != null && arrayFaces.length != 0) { // face attribute
                STFaceAttribute[] arrayFaceAttribute = new STFaceAttribute[arrayFaces.length];
                long attributeCostTime = System.currentTimeMillis();
                int result = mSTFaceAttributeNative.detect(data, STCommon.ST_PIX_FMT_NV21, mImageHeight, mImageWidth, arrayFaces, arrayFaceAttribute);
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
        if (mBeautifyParams[index] != value) {
            mStBeautifyNative.setParam(Constants.beautyTypes[index], value);
            mBeautifyParams[index] = value;
        }
    }

    public float[] getBeautyParams() {
        float[] values = new float[6];
        for (int i = 0; i < mBeautifyParams.length; i++) {
            values[i] = mBeautifyParams[i];
        }

        return values;
    }

    public void setShowOriginal(boolean isShow) {
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
            return;
        }
        adjustViewPort(width, height);

        if (mInited) {        //解决虚拟按键引起的glerror
            return;
        }
        mGLRender.init(mImageWidth, mImageHeight);
        mStartTime = System.currentTimeMillis();
        setUpTexture();
        mInited = true;
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

    private Camera.PreviewCallback mPreviewCallback = new Camera.PreviewCallback() {
        @Override
        public void onPreviewFrame(final byte[] data, Camera camera) {
            while (mLBDQ.size() > 1) {
                mLBDQ.pollLast();
            }
            mLBDQ.offer(new ByteWrapper(data));

            if (mCameraChanging || mCameraProxy.getCamera() == null) {
                return;
            }

            if (mImageData == null || mImageData.length != mImageHeight * mImageWidth * 3 / 2) {
                mImageData = new byte[mImageWidth * mImageHeight * 3 / 2];
            }
            synchronized (mImageDataLock) {
                System.arraycopy(data, 0, mImageData, 0, data.length);
            }

            mProcessImageHandler.removeMessages(MESSAGE_PROCESS_IMAGE);
            mProcessImageHandler.sendEmptyMessage(MESSAGE_PROCESS_IMAGE);
            if (!frameBufferReady) {
                mFirstRender = true;
                mLBDQ.clear();
                queue.clear();
                initFrameRenderBuffer((mImageWidth / 2) * (mImageHeight / 2));
                mLBDQ.offer(new ByteWrapper(data));
                mBufferFilled = true;
            }
            nv21YUVDataDirty = true;

            mGlSurfaceView.requestRender();
        }
    };

    private void initFrameRenderBuffer(int size) {
        frameRenderBuffer = ByteBuffer.allocateDirect(size * 6);
        frameRenderBuffer.position(0);
        frameBufferReady = true;
    }

    /**
     * 工作在opengl线程, 具体渲染的工作函数
     *
     * @param gl
     */
    @Override
    public void onDrawFrame(GL10 gl) {
        // during switch camera
        if (mCameraChanging || !mBufferFilled || !frameBufferReady) {
            return;
        }

        if (mCameraProxy.getCamera() == null) {
            return;
        }

        LogUtils.i(TAG, "onDrawFrame");
        if (mRGBABuffer == null) {
            mRGBABuffer = ByteBuffer.allocate(mImageHeight * mImageWidth * 4);
        }

        if (mBeautifyTextureId == null) {
            mBeautifyTextureId = new int[1];
            GlUtil.initEffectTexture(mImageWidth, mImageHeight, mBeautifyTextureId, GLES20.GL_TEXTURE_2D);
        }

        if (mMakeupTextureId == null) {
            mMakeupTextureId = new int[1];
            GlUtil.initEffectTexture(mImageWidth, mImageHeight, mMakeupTextureId, GLES20.GL_TEXTURE_2D);
        }

        if (mTextureOutId == null) {
            mTextureOutId = new int[1];
            GlUtil.initEffectTexture(mImageWidth, mImageHeight, mTextureOutId, GLES20.GL_TEXTURE_2D);
        }

        if (mVideoEncoderTexture == null) {
            mVideoEncoderTexture = new int[1];
        }
        mStartTime = System.currentTimeMillis();

        renderFlag = !renderFlag;
        final int doubleBufIndex = renderFlag ? 0 : 1;
        if (mLBDQ.size() > 0) {
            mDataBuffer[doubleBufIndex] = mLBDQ.remove().getData();
        } else {
            renderFlag = !renderFlag;
            return;
        }
        if (nv21YUVDataDirty) {
            long updateTextureCostTime = System.currentTimeMillis();
            updateFrameWhenDirty(mDataBuffer[doubleBufIndex]);
            updateNV21YUVTexture();
            LogUtils.i(TAG, "updateTexture cost time: %d", System.currentTimeMillis() - updateTextureCostTime);
        }
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);
        mRGBABuffer.rewind();

        long preProcessCostTime = System.currentTimeMillis();
        int textureId = mGLRender.YUV2RGB(mTextureY[0], mTextureUV[0], renderFlag);
        mInputTextureId = textureId;
        LogUtils.i(TAG, "preprocess cost time: %d", System.currentTimeMillis() - preProcessCostTime);

        int result = -1;

        if (needAnimalDetect) {
            long catDetectStartTime = System.currentTimeMillis();
            mAnimalFace = mStAnimalNative.animalDetect(mDataBuffer[doubleBufIndex], STCommon.ST_PIX_FMT_NV21, getHumanActionDetectDir(mCameraProxy.getOrientation(), Accelerometer.getDirection()), mImageHeight, mImageWidth);
            LogUtils.i(TAG, "cat face detect cost time: %d", System.currentTimeMillis() - catDetectStartTime);
        }
        if (needAnimalDetect && mAnimalFace != null && mAnimalFace.length > 0) {
            mAnimalFace = processAnimalFaceResult(mAnimalFace, mCameraID == Camera.CameraInfo.CAMERA_FACING_FRONT, mCameraProxy.getOrientation());
        }
        animalFaceLlength = mAnimalFace == null ? 0 : mAnimalFace.length;
        if (DEBUG) {
            if (animalFaceLlength > 0) {
                for (int i = 0; i < animalFaceLlength; i++) {
                    float[] points = STUtils.getCatPoints(mAnimalFace[i], mImageWidth, mImageHeight);
                    if (points != null && points.length > 0) {
                        mGLRender.onDrawPoints(textureId, points);
                    }
                }
            }
        }

        if (!mShowOriginal) {

            if ((mNeedBeautify || mNeedSticker || mNeedFaceAttribute) && mIsCreateHumanActionHandleSucceeded) {
                if (mCameraChanging || mImageData == null || mImageData.length != mImageHeight * mImageWidth * 3 / 2) {
                    return;
                }
                mDetectThreadPool.submit(new Runnable() {
                    @Override
                    public void run() {
                        if (!mIsPaused && !mCameraChanging) {
                            humanActionDetect(mDataBuffer[doubleBufIndex]);
                        }
                    }
                });

                rotatedHumanAction = queue.peek();
                if (rotatedHumanAction != null) {
                    queue.remove();
                } else {
                    if (dectetStarted && mFirstRender) {
                        textureIdBuffer[0] = textureId;
                        mFirstRender = false;
                        return;
                    }

                    synchronized (mLock) {
                        rotatedHumanAction = queue.peek();
                        if (rotatedHumanAction == null) {
                            try {
                                mLock.wait();
                            } catch (InterruptedException e) {
                                e.printStackTrace();
                            }
                        }
                    }

                    rotatedHumanAction = queue.peek();
                    if (rotatedHumanAction == null) {
                        return;
                    } else {
                        queue.remove();
                    }
                }

                if (!renderFlag) {
                    textureIdBuffer[1] = textureId;
                    mInputTextureId = textureIdBuffer[0];
                } else {
                    textureIdBuffer[0] = textureId;
                    mInputTextureId = textureIdBuffer[1];
                }

                if (DEBUG) {
                    if (rotatedHumanAction != null && rotatedHumanAction.faceCount > 0) {
                        long expressionStartTime = System.currentTimeMillis();
                        mFaceExpressionResult = mSTHumanActionNative.getExpression(rotatedHumanAction, getHumanActionOrientation(), mCameraID == Camera.CameraInfo.CAMERA_FACING_FRONT);
                        LogUtils.i(TAG, "face expression cost time: %d", System.currentTimeMillis() - expressionStartTime);

                        Message msg = mHandler.obtainMessage(CameraActivity.MSG_UPDATE_FACE_EXPRESSION_INFO);
                        mHandler.sendMessage(msg);
                    } else {
                        mFaceExpressionResult = null;
                    }

                    /**
                     * DEBUG模式下，每20帧计算一次人脸属性值，需要先加载人脸属性model和创建句柄，测试使用
                     */
                    if (mFrameCount <= 20) {
                        mFrameCount++;
                    } else {
                        mFrameCount = 0;
                        faceAttributeDetect(mDataBuffer[doubleBufIndex], rotatedHumanAction);//do face attribute
                    }
                }

                /**
                 * HumanAction rotate && mirror:双输入场景中，buffer为相机原始数据，而texture已根据预览旋转和镜像处理，所以buffer和texture方向不一致，
                 * 根据buffer计算出的HumanAction不能直接使用，需要根据摄像头ID和摄像头方向处理后使用
                 */
                int orientation = getCurrentOrientation();


                if (mNeedBeautify) {// do beautify
                    long beautyStartTime = System.currentTimeMillis();
                    //如果需要输出buffer推流或其他，设置该开关为true
                    if (!mNeedBeautyOutputBuffer) {
                        result = mStBeautifyNative.processTexture(mInputTextureId, mImageWidth, mImageHeight, orientation, rotatedHumanAction, mBeautifyTextureId[0], mHumanActionBeautyOutput);
                    } else {  //如果需要输出buffer用作推流等
                        byte[] outputImageBuffer = new byte[mImageWidth * mImageHeight * 4];
                        result = mStBeautifyNative.processTextureAndOutputBuffer(mInputTextureId, mImageWidth, mImageHeight, orientation, rotatedHumanAction, mBeautifyTextureId[0], outputImageBuffer, STCommon.ST_PIX_FMT_RGBA8888, mHumanActionBeautyOutput);

                        if (mNeedSave && result == 0) {
                            saveImageBuffer2Picture(outputImageBuffer);
                        }

                    }
                    long beautyEndTime = System.currentTimeMillis();
                    LogUtils.i(TAG, "beautify cost time: %d", beautyEndTime - beautyStartTime);
                    if (result == 0) {
                        rotatedHumanAction = mHumanActionBeautyOutput;
                        mInputTextureId = mBeautifyTextureId[0];
                        LogUtils.i(TAG, "replace enlarge eye and shrink face action");
                    }
                }

                if (mNeedMakeup) {// do makeup
                    long startMakeup = System.currentTimeMillis();
                    result = mSTMobileMakeupNative.processTexture(mInputTextureId, rotatedHumanAction, orientation, mImageWidth, mImageHeight, mMakeupTextureId[0]);

                    if (result == 0) {
                        mInputTextureId = mMakeupTextureId[0];
                    }

                    LogUtils.i(TAG, "makeup cost time: %d", System.currentTimeMillis() - startMakeup);
                }

                if (mCameraChanging) {
                    return;
                }
                //调用贴纸API绘制贴纸
                if (mNeedSticker) {
                    /**
                     * 1.在切换贴纸时，调用STMobileStickerNative的changeSticker函数，传入贴纸路径(参考setShowSticker函数的使用)
                     * 2.切换贴纸后，使用STMobileStickerNative的getTriggerAction函数获取当前贴纸支持的手势和前后背景等信息，返回值为int类型
                     * 3.根据getTriggerAction函数返回值，重新配置humanActionDetect函数的config参数，使detect更高效
                     *
                     * 例：只检测人脸信息和当前贴纸支持的手势等信息时，使用如下配置：
                     * mDetectConfig = mSTMobileStickerNative.getTriggerAction()|STMobileHumanActionNative.ST_MOBILE_FACE_DETECT;
                     */

                    int event = mCustomEvent;
                    STStickerInputParams inputEvent;
                    if ((mParamType & STMobileStickerNative.ST_INPUT_PARAM_CAMERA_QUATERNION) == STMobileStickerNative.ST_INPUT_PARAM_CAMERA_QUATERNION &&
                            mSensorEvent != null && mSensorEvent.values != null && mSensorEvent.values.length > 0) {
                        inputEvent = new STStickerInputParams(mSensorEvent.values, mCameraID == Camera.CameraInfo.CAMERA_FACING_FRONT, event);
                    } else {
                        inputEvent = new STStickerInputParams(new float[]{0, 0, 0, 1}, mCameraID == Camera.CameraInfo.CAMERA_FACING_FRONT, event);
                    }
                    long stickerStartTime = System.currentTimeMillis();
                    //如果需要输出buffer推流或其他，设置该开关为true
                    if (!mNeedStickerOutputBuffer) {
                        result = mStStickerNative.processTextureBoth(mInputTextureId, rotatedHumanAction, orientation, getForeGroundStickerOrientation(), mImageWidth, mImageHeight,
                                false, inputEvent, mAnimalFace, animalFaceLlength, mTextureOutId[0]);
                    } else {  //如果需要输出buffer用作推流等
                        byte[] outputImageBuffer = new byte[mImageWidth * mImageHeight * 4];
                        result = mStStickerNative.processTextureAndOutputBuffer(mInputTextureId, rotatedHumanAction, orientation, getForeGroundStickerOrientation(), mImageWidth,
                                mImageHeight, false, inputEvent, mTextureOutId[0], STCommon.ST_PIX_FMT_RGBA8888, outputImageBuffer);


                        if (mNeedSave && result == 0) {
                            saveImageBuffer2Picture(outputImageBuffer);
                        }
                    }
                    if (event == mCustomEvent) {
                        mCustomEvent = 0;
                    }

                    LogUtils.i(TAG, "processTexture result: %d", result);
                    LogUtils.i(TAG, "sticker cost time: %d", System.currentTimeMillis() - stickerStartTime);

                    if (result == 0) {
                        mInputTextureId = mTextureOutId[0];
                    }
                }

                /**
                 * DEBUG模式，测试使用
                 */
                if (DEBUG) {
                    /**
                     * DEBUG模式下，打印segment和handAction结果，测试使用
                     */
                    if (rotatedHumanAction != null) {
                        if (rotatedHumanAction.getImage() != null) {
                            LogUtils.i(TAG, "human action background result: %d", 1);
                        } else {
                            LogUtils.i(TAG, "human action background result: %d", 0);
                        }

                        if (rotatedHumanAction.hands != null && rotatedHumanAction.hands.length > 0) {
                            mHandAction = rotatedHumanAction.hands[0].handAction;

                            Message msg = mHandler.obtainMessage(CameraActivity.MSG_UPDATE_HAND_ACTION_INFO);
                            mHandler.sendMessage(msg);
                        } else {
                            mHandAction = 0;
                            Message msg = mHandler.obtainMessage(CameraActivity.MSG_RESET_HAND_ACTION_INFO);
                            mHandler.sendMessage(msg);
                        }
                    }

                    /**
                     * DEBUG模式下，将240、眼球轮廓和中心点、肢体关键点使用opengl绘制到屏幕，测试使用
                     */
                    if (rotatedHumanAction != null) {
                        if (rotatedHumanAction.faceCount > 0) {
                            for (int i = 0; i < rotatedHumanAction.faceCount; i++) {
                                float[] points = STUtils.getExtraPoints(rotatedHumanAction, i, mImageWidth, mImageHeight);
                                if (points != null && points.length > 0) {
                                    mGLRender.onDrawPoints(mInputTextureId, points);
                                }
                            }
                        }

                        if (rotatedHumanAction.faceCount > 0) {
                            for (int i = 0; i < rotatedHumanAction.faceCount; i++) {
                                float[] points = STUtils.getTonguePoints(rotatedHumanAction, i, mImageWidth, mImageHeight);
                                if (points != null && points.length > 0) {
                                    mGLRender.onDrawPoints(mInputTextureId, points);
                                }
                            }
                        }

                        if (rotatedHumanAction.bodyCount > 0) {
                            for (int i = 0; i < rotatedHumanAction.bodyCount; i++) {
                                float[] points = STUtils.getBodyKeyPoints(rotatedHumanAction, i, mImageWidth, mImageHeight);
                                if (points != null && points.length > 0) {
                                    mGLRender.onDrawPoints(mInputTextureId, points);
                                }
                            }

                            //print body[0] action
                            mBodyAction = rotatedHumanAction.bodys[0].bodyAction;
                            LogUtils.i(TAG, "human action body count: %d", rotatedHumanAction.bodyCount);
                            LogUtils.i(TAG, "human action body[0] action: %d", rotatedHumanAction.bodys[0].bodyAction);

                            Message msg = mHandler.obtainMessage(CameraActivity.MSG_UPDATE_BODY_ACTION_INFO);
                            mHandler.sendMessage(msg);
                        } else {
                            mBodyAction = 0;
                        }

                        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
                    }
                }
            }

            if (mCurrentFilterStyle != mFilterStyle) {
                mCurrentFilterStyle = mFilterStyle;
                mSTMobileStreamFilterNative.setStyle(mCurrentFilterStyle);
            }
            if (mCurrentFilterStrength != mFilterStrength) {
                mCurrentFilterStrength = mFilterStrength;
                mSTMobileStreamFilterNative.setParam(STFilterParamsType.ST_FILTER_STRENGTH, mCurrentFilterStrength);
            }

            if (mFilterTextureOutId == null) {
                mFilterTextureOutId = new int[1];
                GlUtil.initEffectTexture(mImageWidth, mImageHeight, mFilterTextureOutId, GLES20.GL_TEXTURE_2D);
            }

            //滤镜
            if (mNeedFilter) {
                long filterStartTime = System.currentTimeMillis();
                //如果需要输出buffer推流或其他，设置该开关为true
                if (!mNeedFilterOutputBuffer) {
                    result = mSTMobileStreamFilterNative.processTexture(mInputTextureId, mImageWidth, mImageHeight, mFilterTextureOutId[0]);
                } else {  //如果需要输出buffer用作推流等
                    byte[] outputImageBuffer = new byte[mImageWidth * mImageHeight * 4];
                    result = mSTMobileStreamFilterNative.processTextureAndOutputBuffer(mInputTextureId, mImageWidth, mImageHeight, mFilterTextureOutId[0], outputImageBuffer, STCommon.ST_PIX_FMT_RGBA8888);

                    if (mNeedSave && result == 0) {
                        saveImageBuffer2Picture(outputImageBuffer);
                    }
                }
                LogUtils.i(TAG, "filter cost time: %d", System.currentTimeMillis() - filterStartTime);
                if (result == 0) {
                    mInputTextureId = mFilterTextureOutId[0];
                }
            }

            LogUtils.i(TAG, "frame cost time total: %d", System.currentTimeMillis() - mStartTime + mRotateCost + mObjectCost + mFaceAttributeCost / 20);
        }


        if (mNeedSave) {
            savePicture(mInputTextureId);
            mNeedSave = false;
        }

        if (mNeedBlur) {
            savePictureBlur(mInputTextureId);
            mNeedBlur = false;
        }


        //video capturing
        if (mVideoEncoder != null) {
            GLES20.glFinish();

            mVideoEncoderTexture[0] = mInputTextureId;
            processStMatrix(mStMatrix);

            synchronized (this) {
                if (mVideoEncoder != null) {
                    if (mNeedResetEglContext) {
                        mVideoEncoder.setEglContext(EGL14.eglGetCurrentContext(), mVideoEncoderTexture[0]);
                        mNeedResetEglContext = false;
                    }
                    mVideoEncoder.frameAvailableSoon(mStMatrix);
                }
            }
        }

        mFrameCost = (int) (System.currentTimeMillis() - mStartTime + mRotateCost + mObjectCost + mFaceAttributeCost / 20);

        long timer = System.currentTimeMillis();
        mCount++;
        if (mIsFirstCount) {
            mCurrentTime = timer;
            mIsFirstCount = false;
        } else {
            int cost = (int) (timer - mCurrentTime);
            if (cost >= 1000) {
                mCurrentTime = timer;
                mFps = (((float) mCount * 1000) / cost);
                mCount = 0;
            }
        }

        LogUtils.i(TAG, "render fps: %f", mFps);

        GLES20.glViewport(0, 0, mSurfaceWidth, mSurfaceHeight);
        if (!mShowOriginal) {
            mGLRender.onDrawFrame(mInputTextureId);
        } else {
            mGLRender.onDrawFrame(textureId);
        }
    }

    private void updateFrameWhenDirty(byte[] data) {
        frameRenderBuffer.clear();
        frameRenderBuffer.position(0);
        frameRenderBuffer.put(data);
        frameRenderBuffer.position(0);
        nv21YUVDataDirty = false;
    }

    private void updateNV21YUVTexture() {
        if (!mTextureInit) {
            frameRenderBuffer.position(0);
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mTextureY[0]);
            GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, mImageHeight, mImageWidth, 0,
                    GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, frameRenderBuffer);
            frameRenderBuffer.position(4 * (mImageWidth / 2) * (mImageHeight / 2));
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mTextureUV[0]);
            GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE_ALPHA, mImageHeight / 2, mImageWidth / 2, 0,
                    GLES20.GL_LUMINANCE_ALPHA, GLES20.GL_UNSIGNED_BYTE, frameRenderBuffer);
            mTextureInit = true;
        } else {
            frameRenderBuffer.position(0);
            GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mTextureY[0]);
            GLES20.glTexSubImage2D(GLES20.GL_TEXTURE_2D, 0, 0, 0, mImageHeight, mImageWidth, GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, frameRenderBuffer);
            frameRenderBuffer.position(4 * (mImageWidth / 2) * (mImageHeight / 2));
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, mTextureUV[0]);
            GLES20.glTexSubImage2D(GLES20.GL_TEXTURE_2D, 0, 0, 0, mImageHeight / 2, mImageWidth / 2, GLES20.GL_LUMINANCE_ALPHA, GLES20.GL_UNSIGNED_BYTE, frameRenderBuffer);
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

    private void savePictureBlur(int textureId) {
        ByteBuffer mTmpBuffer = ByteBuffer.allocate(mImageHeight * mImageWidth * 4);
        mGLRender.saveTextureToFrameBuffer(textureId, mTmpBuffer);

        mTmpBuffer.position(0);
        Message msg = Message.obtain(mHandler);
        msg.what = CameraActivity.MSG_BITMAP;
        msg.obj = mTmpBuffer;
        Bundle bundle = new Bundle();
        bundle.putInt("imageWidth", mImageWidth);
        bundle.putInt("imageHeight", mImageHeight);
        msg.setData(bundle);
        msg.sendToTarget();
    }

    private void saveImageBuffer2Picture(byte[] imageBuffer) {
        ByteBuffer mTmpBuffer = ByteBuffer.allocate(mImageHeight * mImageWidth * 4);
        mTmpBuffer.put(imageBuffer);

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
        int orientation;
        if (mCameraProxy.getOrientation() == 90 || mCameraProxy.getOrientation() == 270) {
            orientation = dir - 1;
            if (orientation < 0) {
                orientation = dir ^ 3;
            }
        } else {
            orientation = (dir + 2) % 4;    //适配平板方向
        }
        return orientation;
    }

    private int getForeGroundStickerOrientation() {
        int dir = Accelerometer.getDirection();
        int orientation;
        if (mCameraProxy.getOrientation() == 90 || mCameraProxy.getOrientation() == 270) {
            orientation = dir - 1;
            if (orientation < 0) {
                orientation = dir ^ 3;
            }
        } else {
            orientation = (dir + 2) % 4;    //适配平板方向
        }
        return orientation;
    }

//    private OnFrameAvailableListener mOnFrameAvailableListener = new OnFrameAvailableListener() {
//
//        @Override
//        public void onFrameAvailable(SurfaceTexture surfaceTexture) {
//            if (!mCameraChanging) {
//                mGlSurfaceView.requestRender();
//            }
//        }
//    };

    /**
     * camera设备startPreview
     */
    private void setUpCamera() {
        // 初始化Camera设备预览需要的显示区域(mSurfaceTexture)
        if (mTextureId == OpenGLUtils.NO_TEXTURE) {
            mTextureId = OpenGLUtils.getExternalOESTextureID();
            mSurfaceTexture = new SurfaceTexture(mTextureId);
//            mSurfaceTexture.setOnFrameAvailableListener(mOnFrameAvailableListener);
        }

        String size = mSupportedPreviewSizes.get(mCurrentPreview);
        int index = size.indexOf('x');
        mImageHeight = Integer.parseInt(size.substring(0, index));
        mImageWidth = Integer.parseInt(size.substring(index + 1));

        if (initTextureId[0] == 0) {
            initTextureId[0] = OpenGLUtils.initEffectTexture(mImageWidth, mImageHeight, initTextureId);
        }

        if (mIsPaused)
            return;

        while (!mSetPreViewSizeSucceed) {
            try {
                mCameraProxy.setPreviewSize(mImageHeight, mImageWidth);
                mSetPreViewSizeSucceed = true;
            } catch (Exception e) {
                mSetPreViewSizeSucceed = false;
            }

            try {
                Thread.sleep(10);
            } catch (Exception e) {

            }
        }

        boolean flipHorizontal = mCameraProxy.isFlipHorizontal();
        boolean flipVertical = mCameraProxy.isFlipVertical();
        mGLRender.adjustTextureBuffer(mCameraProxy.getOrientation(), flipVertical, flipHorizontal);

        if (mIsPaused)
            return;
        mCameraProxy.startPreview(mSurfaceTexture, mPreviewCallback);
        mFirstRender = true;
    }

    public void changeSticker(String sticker) {
        mChangeStickerManagerHandler.removeMessages(MESSAGE_NEED_CHANGE_STICKER);
        Message msg = mChangeStickerManagerHandler.obtainMessage(MESSAGE_NEED_CHANGE_STICKER);
        msg.obj = sticker;

        mChangeStickerManagerHandler.sendMessage(msg);
    }

    public int addSticker(String addSticker) {
//        mChangeStickerManagerHandler.removeMessages(MESSAGE_NEED_ADD_STICKER);
//        Message msg = mChangeStickerManagerHandler.obtainMessage(MESSAGE_NEED_ADD_STICKER);
//        msg.obj = sticker;
//
//        mChangeStickerManagerHandler.sendMessage(msg);

        mCurrentSticker = addSticker;
        int stickerId = mStStickerNative.addSticker(mCurrentSticker);

        if (stickerId > 0) {
            mParamType = mStStickerNative.getNeededInputParams();
            if (mCurrentStickerMaps != null) {
                mCurrentStickerMaps.put(stickerId, mCurrentSticker);
            }
            setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());

            Message message1 = mHandler.obtainMessage(CameraActivity.MSG_NEED_UPDATE_STICKER_TIPS);
            mHandler.sendMessage(message1);

            return stickerId;
        } else {
            Message message2 = mHandler.obtainMessage(CameraActivity.MSG_NEED_SHOW_TOO_MUCH_STICKER_TIPS);
            mHandler.sendMessage(message2);

            return -1;
        }
    }

    public void removeSticker(int packageId) {
        mChangeStickerManagerHandler.removeMessages(MESSAGE_NEED_REMOVE_STICKER);
        Message msg = mChangeStickerManagerHandler.obtainMessage(MESSAGE_NEED_REMOVE_STICKER);
        msg.obj = packageId;

        mChangeStickerManagerHandler.sendMessage(msg);

//        int result = mStStickerNative.removeSticker(packageId);

//        if(mCurrentStickerMaps != null && result == 0){
//            mCurrentStickerMaps.remove(packageId);
//        }
//        setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction());
    }

    public void removeAllStickers() {
        mChangeStickerManagerHandler.removeMessages(MESSAGE_NEED_REMOVEALL_STICKERS);
        Message msg = mChangeStickerManagerHandler.obtainMessage(MESSAGE_NEED_REMOVEALL_STICKERS);

        mChangeStickerManagerHandler.sendMessage(msg);
    }


    public void setFilterStyle(String modelPath) {
        mFilterStyle = modelPath;
    }

    public void setFilterStrength(float strength) {
        mFilterStrength = strength;
    }

    public long getStickerTriggerAction() {
        return mStStickerNative.getTriggerAction();
    }

    public long getAnimalDetectConfig() {
        return mStStickerNative.getAnimalDetectConfig();
    }

    public void onResume() {
        LogUtils.i(TAG, "onResume");

        if (mCameraProxy.getCamera() == null) {
            if (mCameraProxy.getNumberOfCameras() == 1) {
                mCameraID = Camera.CameraInfo.CAMERA_FACING_BACK;
            }
            mCameraProxy.openCamera(mCameraID);
            mSupportedPreviewSizes = mCameraProxy.getSupportedPreviewSize(new String[]{"640x480", "1280x720"});
        }
        mIsPaused = false;
        mSetPreViewSizeSucceed = false;
        mNeedResetEglContext = true;
        mTextureInit = false;

        mGLRender = new STGLRender();

        mGlSurfaceView.onResume();
        mGlSurfaceView.forceLayout();
        //mGlSurfaceView.requestRender();
    }

    public void onPause() {
        LogUtils.i(TAG, "onPause");
        mSetPreViewSizeSucceed = false;

        mInited = false;
        mIsPaused = true;
        mImageData = null;
        renderFlag = false;
        textureIdBuffer[0] = 0;
        textureIdBuffer[1] = 0;
        mDataBuffer[0] = null;
        mDataBuffer[1] = null;
        mFirstRender = true;
        frameBufferReady = false;
        mTextureInit = false;
        dectetStarted = false;
        mCameraProxy.releaseCamera();
        LogUtils.d(TAG, "Release camera");

        mGlSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                mLBDQ.clear();
                queue.clear();
                mSTHumanActionNative.reset();

                mStBeautifyNative.destroyBeautify();
                mStStickerNative.removeAvatarModel();
                mStStickerNative.destroyInstance();
                mSTMobileStreamFilterNative.destroyInstance();
                mSTMobileMakeupNative.destroyInstance();

                mRGBABuffer = null;
                mNv21ImageData = null;
                deleteTextures();
                if (mSurfaceTexture != null) {
                    mSurfaceTexture.release();
                }
                mGLRender.destroyFrameBuffers();
            }
        });

        mGlSurfaceView.onPause();
    }

    public void onDestroy() {
//必须释放非opengGL句柄资源,负责内存泄漏
        synchronized (mHumanActionHandleLock) {
            mSTHumanActionNative.destroyInstance();
        }
        mSTFaceAttributeNative.destroyInstance();
        mSTMobileObjectTrackNative.destroyInstance();
        mStAnimalNative.destroyInstance();
        if (mNeedAvatarExpression) mSTMobileAvatarNative.destroyInstance();

        if (mCurrentStickerMaps != null) {
            mCurrentStickerMaps.clear();
            mCurrentStickerMaps = null;
        }
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

        if (mMakeupTextureId != null) {
            GLES20.glDeleteTextures(1, mMakeupTextureId, 0);
            mMakeupTextureId = null;
        }

        if (mTextureOutId != null) {
            GLES20.glDeleteTextures(1, mTextureOutId, 0);
            mTextureOutId = null;
        }

        if (mFilterTextureOutId != null) {
            GLES20.glDeleteTextures(1, mFilterTextureOutId, 0);
            mFilterTextureOutId = null;
        }

        if (mVideoEncoderTexture != null) {
            GLES20.glDeleteTextures(1, mVideoEncoderTexture, 0);
            mVideoEncoderTexture = null;
        }

        if (mTextureY != null) {
            GLES20.glDeleteTextures(1, mTextureY, 0);
            mTextureY = null;
        }

        if (mTextureUV != null) {
            GLES20.glDeleteTextures(1, mTextureUV, 0);
            mTextureUV = null;
        }
    }

    public void switchCamera() {
        if (Camera.getNumberOfCameras() == 1
                || mCameraChanging) {
            return;
        }

        renderFlag = false;
        textureIdBuffer[0] = 0;
        textureIdBuffer[1] = 0;
        mDataBuffer[0] = null;
        mDataBuffer[1] = null;
        mFirstRender = true;

        final int cameraID = 1 - mCameraID;
        mCameraChanging = true;
        mCameraProxy.openCamera(cameraID);

        if (mCameraProxy.cameraOpenFailed()) {
            return;
        }

        mSetPreViewSizeSucceed = false;

        if (mNeedObject) {
            resetIndexRect();
        } else {
            Message msg = mHandler.obtainMessage(CameraActivity.MSG_CLEAR_OBJECT);
            mHandler.sendMessage(msg);
        }

        mGlSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                if (mRGBABuffer != null) {
                    mRGBABuffer.clear();
                }
                mRGBABuffer = null;
                mLBDQ.clear();
                queue.clear();
                deleteCameraPreviewTexture();
                if (mCameraProxy.getCamera() != null) {
                    setUpCamera();
                }
                mCameraChanging = false;
                mCameraID = cameraID;
            }
        });
        //fix 双输入camera changing时，贴纸和画点mirrow显示
        //mGlSurfaceView.requestRender();
    }

    public int getCameraID() {
        return mCameraID;
    }

    public void changePreviewSize(int currentPreview) {
        if (mCameraProxy.getCamera() == null || mCameraChanging
                || mIsPaused) {
            return;
        }

        renderFlag = false;
        textureIdBuffer[0] = 0;
        textureIdBuffer[1] = 0;
        mDataBuffer[0] = null;
        mDataBuffer[1] = null;
        mFirstRender = true;
        mCurrentPreview = currentPreview;
        mSetPreViewSizeSucceed = false;
        mIsChangingPreviewSize = true;
        frameBufferReady = false;
        dectetStarted = false;

        mCameraChanging = true;
        mCameraProxy.stopPreview();
        mGlSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                if (mRGBABuffer != null) {
                    mRGBABuffer.clear();
                }
                mRGBABuffer = null;
                mLBDQ.clear();
                queue.clear();
                deleteTextures();
                if (mCameraProxy.getCamera() != null) {
                    setUpCamera();
                }

                mGLRender.init(mImageWidth, mImageHeight);
                if (DEBUG) {
                    mGLRender.initDrawPoints();
                }

                if (mNeedObject) {
                    resetIndexRect();
                }

                mGLRender.calculateVertexBuffer(mSurfaceWidth, mSurfaceHeight, mImageWidth, mImageHeight);
                if (mListener != null) {
                    mListener.onChangePreviewSize(mImageHeight, mImageWidth);
                }

                mCameraChanging = false;
                mIsChangingPreviewSize = false;
                //mGlSurfaceView.requestRender();
                LogUtils.d(TAG, "exit  change Preview size queue event");
                setUpTexture();
                mTextureInit = false;
            }
        });

    }

    public void enableObject(boolean enabled) {
        mNeedObject = enabled;

        if (mNeedObject) {
            resetIndexRect();
        }
    }

    public void setIndexRect(int x, int y, boolean needRect) {
        mIndexRect = new Rect(x, y, x + mScreenIndexRectWidth, y + mScreenIndexRectWidth);
        mNeedShowRect = needRect;
    }

    public Rect getIndexRect() {
        return mIndexRect;
    }

    public void setObjectTrackRect() {
        mNeedSetObjectTarget = true;
        mIsObjectTracking = false;
        mTargetRect = STUtils.adjustToImageRectMin(getIndexRect(), mSurfaceWidth, mSurfaceHeight, mImageWidth, mImageHeight);
    }

    public void disableObjectTracking() {
        mIsObjectTracking = false;
    }

    public void resetObjectTrack() {
        mSTMobileObjectTrackNative.reset();
    }

    public void resetIndexRect() {
        if (mImageWidth == 0) {
            return;
        }

        mScreenIndexRectWidth = mSurfaceWidth / 4;

        mIndexRect.left = (mSurfaceWidth - mScreenIndexRectWidth) / 2;
        mIndexRect.top = (mSurfaceHeight - mScreenIndexRectWidth) / 2;
        mIndexRect.right = mIndexRect.left + mScreenIndexRectWidth;
        mIndexRect.bottom = mIndexRect.top + mScreenIndexRectWidth;

        mNeedShowRect = true;
        mNeedSetObjectTarget = false;
        mIsObjectTracking = false;
    }

    /**
     * 用于humanActionDetect接口。根据传感器方向计算出在不同设备朝向时，人脸在buffer中的朝向
     *
     * @return 人脸在buffer中的朝向
     */
    private int getHumanActionOrientation() {
        boolean frontCamera = (mCameraID == Camera.CameraInfo.CAMERA_FACING_FRONT);

        //获取重力传感器返回的方向
        int orientation = Accelerometer.getDirection();

        //在使用后置摄像头，且传感器方向为0或2时，后置摄像头与前置orentation相反
        if (!frontCamera && orientation == STRotateType.ST_CLOCKWISE_ROTATE_0) {
            orientation = STRotateType.ST_CLOCKWISE_ROTATE_180;
        } else if (!frontCamera && orientation == STRotateType.ST_CLOCKWISE_ROTATE_180) {
            orientation = STRotateType.ST_CLOCKWISE_ROTATE_0;
        }

        // 请注意前置摄像头与后置摄像头旋转定义不同 && 不同手机摄像头旋转定义不同
        if (((mCameraProxy.getOrientation() == 270 && (orientation & STRotateType.ST_CLOCKWISE_ROTATE_90) == STRotateType.ST_CLOCKWISE_ROTATE_90) ||
                (mCameraProxy.getOrientation() == 90 && (orientation & STRotateType.ST_CLOCKWISE_ROTATE_90) == STRotateType.ST_CLOCKWISE_ROTATE_0)))
            orientation = (orientation ^ STRotateType.ST_CLOCKWISE_ROTATE_180);
        return orientation;
    }

    public int getPreviewWidth() {
        return mImageWidth;
    }

    public int getPreviewHeight() {
        return mImageHeight;
    }

    public void setVideoEncoder(final MediaVideoEncoder encoder) {

        mGlSurfaceView.queueEvent(new Runnable() {
            @Override
            public void run() {
                synchronized (this) {
                    if (encoder != null && mVideoEncoderTexture != null) {
                        encoder.setEglContext(EGL14.eglGetCurrentContext(), mVideoEncoderTexture[0]);
                    }
                    mVideoEncoder = encoder;
                }
            }
        });
    }

    private void processStMatrix(float[] matrix) {
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

    public int getFrameCost() {
        return mFrameCost;
    }

    public float getFpsInfo() {
        return (float) (Math.round(mFps * 10)) / 10;
    }

    public boolean isChangingPreviewSize() {
        return mIsChangingPreviewSize;
    }

    public void addSubModelByName(String modelName) {
        Message msg = mSubModelsManagerHandler.obtainMessage(MESSAGE_ADD_SUB_MODEL);
        msg.obj = modelName;

        mSubModelsManagerHandler.sendMessage(msg);
    }

    public void removeSubModelByConfig(int Config) {
        Message msg = mSubModelsManagerHandler.obtainMessage(MESSAGE_REMOVE_SUB_MODEL);
        msg.obj = Config;
        mSubModelsManagerHandler.sendMessage(msg);
    }

    public long getHandActionInfo() {
        return mHandAction;
    }

    public long getBodyActionInfo() {
        return mBodyAction;
    }

    public boolean[] getFaceExpressionInfo() {
        return mFaceExpressionResult;
    }

    public void changeModuleTransition(int value) {
        int count = 0;

        int huluwaFireModuleId = -1;
        int huluwaHandModuleId = -1;
        int bunnyHeartaModuleId = -1;
        int bunnyHeartbModuleId = -1;

        STModuleInfo[] moduleInfos = mStStickerNative.getModules();

        if (moduleInfos == null) {
            return;
        }

        count = moduleInfos.length;

        for (int i = 0; i < count; ++i) {
            String s = new String(moduleInfos[i].name).trim();
            if (s.equals("fire")) {
                huluwaFireModuleId = moduleInfos[i].id;
            } else if (s.equals("hand")) {
                huluwaHandModuleId = moduleInfos[i].id;
            } else if (s.equals("hearta")) {
                bunnyHeartaModuleId = moduleInfos[i].id;
            } else if (s.equals("heartb")) {
                bunnyHeartbModuleId = moduleInfos[i].id;
            }
        }

        int result = -1;

        if (value == 0 && huluwaFireModuleId != -1 && huluwaHandModuleId != -1) {
            result = mStStickerNative.clearModuleTransition(huluwaFireModuleId);
            result = mStStickerNative.clearModuleTransition(huluwaHandModuleId);

            //huluwa fire Appear transition
            STTriggerEvent fireAppearTriggerEvent = new STTriggerEvent();
            fireAppearTriggerEvent.setTriggerType(STTriggerEventType.ST_EVENT_HUMAN_ACTION);
            fireAppearTriggerEvent.setTrigger(STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_INDEX);
            fireAppearTriggerEvent.setModuleId(-1);
            fireAppearTriggerEvent.setAppear(true);

            STTriggerEvent[] fireAppearTriggerEvents = new STTriggerEvent[1];
            fireAppearTriggerEvents[0] = fireAppearTriggerEvent;

            STCondition fireAppearCondition = new STCondition();
            fireAppearCondition.setPreStateModuleId(-1);
            fireAppearCondition.setPreState(STAnimationStateType.ST_AS_PLAYING);
            fireAppearCondition.setTriggerCount(1);
            fireAppearCondition.setTriggers(fireAppearTriggerEvents);

            STCondition[] fireConditions = new STCondition[1];
            fireConditions[0] = fireAppearCondition;

            STTransParam fireAppearTransParam = new STTransParam();
            fireAppearTransParam.setFadeFrame(0);
            fireAppearTransParam.setDelayFrame(0);
            fireAppearTransParam.setLastingFrame(0);
            fireAppearTransParam.setPlayloop(1);

            STTransParam[] fireAppearTransParams = new STTransParam[1];
            fireAppearTransParams[0] = fireAppearTransParam;

            int[] fireAppearTransIds = new int[1];
            fireAppearTransIds[0] = -1;

            result = mStStickerNative.addModuleTransition(huluwaFireModuleId, STAnimationStateType.ST_AS_PLAYING, fireConditions, fireAppearTransParams, fireAppearTransIds);

            //huluwa fire disappear transition
            STTriggerEvent fireDisappearTriggerEvent = new STTriggerEvent();
            fireDisappearTriggerEvent.setTriggerType(STTriggerEventType.ST_EVENT_HUMAN_ACTION);
            fireDisappearTriggerEvent.setTrigger(STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_INDEX);
            fireDisappearTriggerEvent.setModuleId(-1);
            fireDisappearTriggerEvent.setAppear(false);

            STTriggerEvent[] fireDisappearTriggerEvents = new STTriggerEvent[1];
            fireDisappearTriggerEvents[0] = fireDisappearTriggerEvent;

            STCondition fireDisappearCondition = new STCondition();
            fireDisappearCondition.setPreStateModuleId(-1);
            fireDisappearCondition.setPreState(STAnimationStateType.ST_AS_PLAYING);
            fireDisappearCondition.setTriggerCount(1);
            fireDisappearCondition.setTriggers(fireDisappearTriggerEvents);

            STCondition[] fireDisappearConditions = new STCondition[1];
            fireDisappearConditions[0] = fireDisappearCondition;

            STTransParam fireDisappearTransParam = new STTransParam();
            fireDisappearTransParam.setFadeFrame(0);
            fireDisappearTransParam.setDelayFrame(0);
            fireDisappearTransParam.setLastingFrame(0);
            fireDisappearTransParam.setPlayloop(1);

            STTransParam[] fireDisappearTransParams = new STTransParam[1];
            fireDisappearTransParams[0] = fireDisappearTransParam;

            int[] fireDisappearTransIds = new int[1];
            fireDisappearTransIds[0] = -1;

            result = mStStickerNative.addModuleTransition(huluwaFireModuleId, STAnimationStateType.ST_AS_INVISIBLE, fireDisappearConditions, fireDisappearTransParams, fireDisappearTransIds);


            //huluwa hand Appear transition
            STTriggerEvent handAppearTriggerEvent = new STTriggerEvent();
            handAppearTriggerEvent.setTriggerType(STTriggerEventType.ST_EVENT_HUMAN_ACTION);
            handAppearTriggerEvent.setTrigger(STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_INDEX);
            handAppearTriggerEvent.setModuleId(-1);
            handAppearTriggerEvent.setAppear(true);

            STTriggerEvent[] handAppearTriggerEvents = new STTriggerEvent[1];
            handAppearTriggerEvents[0] = handAppearTriggerEvent;

            STCondition handAppearCondition = new STCondition();
            handAppearCondition.setPreStateModuleId(-1);
            handAppearCondition.setPreState(STAnimationStateType.ST_AS_PLAYING);
            handAppearCondition.setTriggerCount(1);
            handAppearCondition.setTriggers(handAppearTriggerEvents);

            STCondition[] handAppearConditions = new STCondition[1];
            handAppearConditions[0] = handAppearCondition;

            STTransParam handAppearTransParam = new STTransParam();
            handAppearTransParam.setFadeFrame(0);
            handAppearTransParam.setDelayFrame(0);
            handAppearTransParam.setLastingFrame(0);
            handAppearTransParam.setPlayloop(1);

            STTransParam[] handAppearTransParams = new STTransParam[1];
            handAppearTransParams[0] = handAppearTransParam;

            int[] handAppearTransIds = new int[1];
            handAppearTransIds[0] = -1;

            result = mStStickerNative.addModuleTransition(huluwaHandModuleId, STAnimationStateType.ST_AS_PLAYING, handAppearConditions, handAppearTransParams, handAppearTransIds);

            //huluwa hand Disappear transition
            STTriggerEvent handDisappearTriggerEvent = new STTriggerEvent();
            handDisappearTriggerEvent.setTriggerType(STTriggerEventType.ST_EVENT_HUMAN_ACTION);
            handDisappearTriggerEvent.setTrigger(STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_INDEX);
            handDisappearTriggerEvent.setModuleId(-1);
            handDisappearTriggerEvent.setAppear(false);

            STTriggerEvent[] handDisappearTriggerEvents = new STTriggerEvent[1];
            handDisappearTriggerEvents[0] = handDisappearTriggerEvent;

            STCondition handDisappearCondition = new STCondition();
            handDisappearCondition.setPreStateModuleId(-1);
            handDisappearCondition.setPreState(STAnimationStateType.ST_AS_PLAYING);
            handDisappearCondition.setTriggerCount(1);
            handDisappearCondition.setTriggers(handDisappearTriggerEvents);

            STCondition[] handDisappearConditions = new STCondition[1];
            handDisappearConditions[0] = handDisappearCondition;

            STTransParam handDisappearTransParam = new STTransParam();
            handDisappearTransParam.setFadeFrame(0);
            handDisappearTransParam.setDelayFrame(0);
            handDisappearTransParam.setLastingFrame(0);
            handDisappearTransParam.setPlayloop(1);

            STTransParam[] handDisappearTransParams = new STTransParam[1];
            handDisappearTransParams[0] = handDisappearTransParam;

            int[] handDisappearTransIds = new int[1];
            handDisappearTransIds[0] = -1;

            result = mStStickerNative.addModuleTransition(huluwaHandModuleId, STAnimationStateType.ST_AS_INVISIBLE, handDisappearConditions, handDisappearTransParams, handDisappearTransIds);

            mDetectConfig |= STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_INDEX;
        } else if (value == 1 && bunnyHeartaModuleId != -1 && bunnyHeartbModuleId != -1) {
            result = mStStickerNative.clearModuleTransition(bunnyHeartaModuleId);
            result = mStStickerNative.clearModuleTransition(bunnyHeartbModuleId);

            //hearta appear transition
            STTriggerEvent heartaAppearTriggerEvent = new STTriggerEvent();
            heartaAppearTriggerEvent.setTriggerType(STTriggerEventType.ST_EVENT_HUMAN_ACTION);
            heartaAppearTriggerEvent.setTrigger(STMobileHumanActionNative.ST_MOBILE_EYE_BLINK);
            heartaAppearTriggerEvent.setModuleId(-1);
            heartaAppearTriggerEvent.setAppear(true);

            STTriggerEvent[] heartaAppearTriggerEvents = new STTriggerEvent[1];
            heartaAppearTriggerEvents[0] = heartaAppearTriggerEvent;

            STCondition heartaAppearCondition = new STCondition();
            heartaAppearCondition.setPreStateModuleId(-1);
            heartaAppearCondition.setPreState(STAnimationStateType.ST_AS_INVISIBLE);
            heartaAppearCondition.setTriggerCount(1);
            heartaAppearCondition.setTriggers(heartaAppearTriggerEvents);

            STCondition[] heartaAppearConditions = new STCondition[1];
            heartaAppearConditions[0] = heartaAppearCondition;

            STTransParam heartaAppearTransParam = new STTransParam();
            heartaAppearTransParam.setFadeFrame(0);
            heartaAppearTransParam.setDelayFrame(10);
            heartaAppearTransParam.setLastingFrame(0);
            heartaAppearTransParam.setPlayloop(3);

            STTransParam[] heartaAppearTransParams = new STTransParam[1];
            heartaAppearTransParams[0] = heartaAppearTransParam;

            int[] heartaAppearTransIds = new int[1];
            heartaAppearTransIds[0] = -1;

            result = mStStickerNative.addModuleTransition(bunnyHeartaModuleId, STAnimationStateType.ST_AS_PLAYING, heartaAppearConditions, heartaAppearTransParams, heartaAppearTransIds);


            //heartb Appear transition
            STTriggerEvent heartbAppearTriggerEvent = new STTriggerEvent();
            heartbAppearTriggerEvent.setTriggerType(STTriggerEventType.ST_EVENT_HUMAN_ACTION);
            heartbAppearTriggerEvent.setTrigger(STMobileHumanActionNative.ST_MOBILE_EYE_BLINK);
            heartbAppearTriggerEvent.setModuleId(-1);
            heartbAppearTriggerEvent.setAppear(true);

            STTriggerEvent[] heartbAppearTriggerEvents = new STTriggerEvent[1];
            heartbAppearTriggerEvents[0] = heartbAppearTriggerEvent;

            STCondition heartbAppearCondition = new STCondition();
            heartbAppearCondition.setPreStateModuleId(-1);
            heartbAppearCondition.setPreState(STAnimationStateType.ST_AS_PLAYING);
            heartbAppearCondition.setTriggerCount(1);
            heartbAppearCondition.setTriggers(heartbAppearTriggerEvents);

            STCondition[] heartbAppearConditions = new STCondition[1];
            heartbAppearConditions[0] = heartbAppearCondition;

            STTransParam heartbAppearTransParam = new STTransParam();
            heartbAppearTransParam.setFadeFrame(0);
            heartbAppearTransParam.setDelayFrame(0);
            heartbAppearTransParam.setLastingFrame(0);
            heartbAppearTransParam.setPlayloop(3);

            STTransParam[] heartbAppearTransParams = new STTransParam[1];
            heartbAppearTransParams[0] = heartbAppearTransParam;

            int[] heartbAppearTransIds = new int[1];
            heartbAppearTransIds[0] = -1;

            result = mStStickerNative.addModuleTransition(bunnyHeartbModuleId, STAnimationStateType.ST_AS_PLAYING, heartbAppearConditions, heartbAppearTransParams, heartbAppearTransIds);
        } else if (value == 2 && bunnyHeartaModuleId != -1) {
            //hearta enable
            result = mStStickerNative.setParamBool(bunnyHeartaModuleId, STStickerModuleParamType.ST_STICKER_PARAM_MODULE_ENABLED_BOOL, false);
        }
    }

    public void changeCustomEvent() {
        mCustomEvent = STCustomEvent.ST_CUSTOM_EVENT_1 | STCustomEvent.ST_CUSTOM_EVENT_2;
    }

    public void setSensorEvent(SensorEvent event) {
        mSensorEvent = event;
    }

    public void setMeteringArea(float touchX, float touchY) {
        float[] touchPosition = new float[2];
        STUtils.calculateRotatetouchPoint(touchX, touchY, mSurfaceWidth, mSurfaceHeight, mCameraID, mCameraProxy.getOrientation(), touchPosition);
        Rect rect = STUtils.calculateArea(touchPosition, mSurfaceWidth, mSurfaceHeight, 100);
        mCameraProxy.setMeteringArea(rect);
    }

    public void handleZoom(boolean isZoom) {
        if (mCameraProxy != null) {
            mCameraProxy.handleZoom(isZoom);
        }
    }

    public void setExposureCompensation(int progress) {
        if (mCameraProxy != null) {
            mCameraProxy.setExposureCompensation(progress);
        }
    }

    private STAnimalFace[] processAnimalFaceResult(STAnimalFace[] animalFaces, boolean isFrontCamera, int cameraOrientation) {
        if (animalFaces == null) {
            return null;
        }
        if (isFrontCamera && cameraOrientation == 90) {
            animalFaces = STMobileAnimalNative.animalRotate(mImageHeight, mImageWidth, STRotateType.ST_CLOCKWISE_ROTATE_90, animalFaces, animalFaces.length);
            animalFaces = STMobileAnimalNative.animalMirror(mImageWidth, animalFaces, animalFaces.length);
        } else if (isFrontCamera && cameraOrientation == 270) {
            animalFaces = STMobileAnimalNative.animalRotate(mImageHeight, mImageWidth, STRotateType.ST_CLOCKWISE_ROTATE_270, animalFaces, animalFaces.length);
            animalFaces = STMobileAnimalNative.animalMirror(mImageWidth, animalFaces, animalFaces.length);
        } else if (!isFrontCamera && cameraOrientation == 270) {
            animalFaces = STMobileAnimalNative.animalRotate(mImageHeight, mImageWidth, STRotateType.ST_CLOCKWISE_ROTATE_270, animalFaces, animalFaces.length);
        } else if (!isFrontCamera && cameraOrientation == 90) {
            animalFaces = STMobileAnimalNative.animalRotate(mImageHeight, mImageWidth, STRotateType.ST_CLOCKWISE_ROTATE_90, animalFaces, animalFaces.length);
        }
        return animalFaces;
    }

    public void enableFaceDistance(boolean enable) {
        mNeedDistance = enable;
    }

    public float getFaceDistanceInfo() {
        return mFaceDistance;
    }

    public void setStrengthForType(int type, float strength) {
        if (type == Constants.ST_MAKEUP_HIGHLIGHT) {
            mSTMobileMakeupNative.setStrengthForType(type, strength * mMakeUpStrength);
            mMakeupStrength[type] = strength * mMakeUpStrength;
        } else {
            mSTMobileMakeupNative.setStrengthForType(type, strength);
            mMakeupStrength[type] = strength;
        }
    }

    public void setMakeupForTypeFromAssets(int type, String typePath) {
        mMakeupPackageId[type] = mSTMobileMakeupNative.setMakeupForTypeFromAssetsFile(type, typePath, mContext.getAssets());

        if (mMakeupPackageId[type] > 0) {
            mCurrentMakeup[type] = typePath;
        }

        setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
    }

    public void removeMakeupByType(int type) {
        int ret = mSTMobileMakeupNative.removeMakeup(mMakeupPackageId[type]);

        if (ret == 0) {
            mMakeupPackageId[type] = 0;
        }

        setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
    }

    public void setMakeupForType(int type, String typePath) {
        mMakeupPackageId[type] = mSTMobileMakeupNative.setMakeupForType(type, typePath);

        if (mMakeupPackageId[type] > 0) {
            mCurrentMakeup[type] = typePath;
        }

        setHumanActionDetectConfig(mNeedBeautify | mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
    }
}
