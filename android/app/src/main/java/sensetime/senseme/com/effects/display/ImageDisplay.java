package sensetime.senseme.com.effects.display;

import android.content.Context;
import android.graphics.Bitmap;
import android.hardware.SensorEvent;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLSurfaceView.Renderer;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.util.Log;

import com.sensetime.stmobile.STBeautifyNative;
import com.sensetime.stmobile.STBeautyParamsType;
import com.sensetime.stmobile.STCommon;
import com.sensetime.stmobile.STFilterParamsType;
import com.sensetime.stmobile.STMobileAnimalNative;
import com.sensetime.stmobile.STMobileAvatarNative;
import com.sensetime.stmobile.STMobileFaceAttributeNative;
import com.sensetime.stmobile.STMobileHumanActionNative;
import com.sensetime.stmobile.STMobileMakeupNative;
import com.sensetime.stmobile.STMobileStickerNative;
import com.sensetime.stmobile.STMobileStreamFilterNative;
import com.sensetime.stmobile.STRotateType;
import com.sensetime.stmobile.model.STAnimalFace;
import com.sensetime.stmobile.model.STFaceAttribute;
import com.sensetime.stmobile.model.STHumanAction;
import com.sensetime.stmobile.model.STMobile106;
import com.sensetime.stmobile.model.STStickerInputParams;
import com.sensetime.stmobile.sticker_module_types.STCustomEvent;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.Arrays;
import java.util.Iterator;
import java.util.TreeMap;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import sensetime.senseme.com.effects.ImageActivity;
import sensetime.senseme.com.effects.glutils.GlUtil;
import sensetime.senseme.com.effects.glutils.OpenGLUtils;
import sensetime.senseme.com.effects.glutils.STUtils;
import sensetime.senseme.com.effects.glutils.TextureRotationUtil;
import sensetime.senseme.com.effects.utils.Constants;
import sensetime.senseme.com.effects.utils.FileUtils;
import sensetime.senseme.com.effects.utils.LogUtils;

public class ImageDisplay extends BaseDisplay implements Renderer {

    private Bitmap mOriginBitmap;
    private String TAG = "ImageDisplay";

	private boolean mNeedAvatar = false;
	private boolean mNeedAvatarExpression = false;
	private float[] mAvatarExpression = new float[54];
	private STMobileAvatarNative mSTMobileAvatarNative = new STMobileAvatarNative();

	private int mImageWidth;
	private int mImageHeight;
	private GLSurfaceView mGlSurfaceView;
	private int mDisplayWidth;
	private int mDisplayHeight;

	protected Context mContext;
	protected final FloatBuffer mVertexBuffer;
	protected final FloatBuffer mTextureBuffer;
	private ImageInputRender mImageInputRender;
	private boolean mInitialized = false;
	private long mFrameCostTime = 0;
	private Bitmap mProcessedImage;
	private boolean mNeedSave = false;
	private Handler mHandler;

	private STMobileStickerNative mStStickerNative = new STMobileStickerNative();
	private STBeautifyNative mStBeautifyNative = new STBeautifyNative();
	private STMobileHumanActionNative mSTHumanActionNative = new STMobileHumanActionNative();
	private STHumanAction mHumanActionBeautyOutput = new STHumanAction();
	private STMobileAnimalNative mStAnimalNative = new STMobileAnimalNative();
	private STMobileStreamFilterNative mSTMobileStreamFilterNative = new STMobileStreamFilterNative();
	private STMobileFaceAttributeNative mSTFaceAttributeNative = new STMobileFaceAttributeNative();
	private STMobileMakeupNative mSTMobileMakeupNative = new STMobileMakeupNative();

	private CostChangeListener mCostListener;

	private String mCurrentSticker;
	private String mCurrentFilterStyle;
	private float mCurrentFilterStrength = 0.65f;
	private float mFilterStrength = 0.65f;
	private String mFilterStyle;
	private float[] mBeautifyParams = new float[27];

	private boolean mNeedBeautify = false;
	private boolean mNeedFaceAttribute = true;
	private boolean mNeedSticker = false;
	private boolean mNeedFilter = false;
	private boolean mNeedMakeup = false;
	private String mFaceAttribute = " ";
	private int[] mBeautifyTextureId, mMakeupTextureId;
	private int[] mTextureOutId;
	private int[] mFilterTextureOutId;

	private boolean mShowOriginal = false;

	private int mHumanActionCreateConfig = STMobileHumanActionNative.ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_IMAGE;
	private long mHumanActionDetectConfig = STMobileHumanActionNative.ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_DETECT;

	private static final int MESSAGE_NEED_CHANGE_STICKER = 1001;
	private static final int MESSAGE_NEED_REMOVEALL_STICKERS = 1005;

	private HandlerThread mChangeStickerManagerThread;
	private Handler mChangeStickerManagerHandler;
	private TreeMap<Integer, String> mCurrentStickerMaps = new TreeMap<>();

	private int mCustomEvent = 0;
	private SensorEvent mSensorEvent;

	private boolean mNeedFaceExtraInfo = true;
	private STAnimalFace[] mAnimalFace;
	private int animalFaceLlength = 0;
	private boolean needAnimalDetect;

	private int[] mMakeupPackageId = new int[Constants.MAKEUP_TYPE_COUNT];
	private String[] mCurrentMakeup = new String[Constants.MAKEUP_TYPE_COUNT];
	private float[] mMakeupStrength = new float[Constants.MAKEUP_TYPE_COUNT];
	private float mMakeUpStrength = 0.7f;

	/**
	 * SurfaceTexureid
	 */
	protected int mTextureId = OpenGLUtils.NO_TEXTURE;

    public ImageDisplay(Context context, GLSurfaceView glSurfaceView, Handler handler){
    	mImageInputRender = new ImageInputRender();
    	mGlSurfaceView = glSurfaceView;

    	glSurfaceView.setEGLContextClientVersion(2);
		glSurfaceView.setRenderer(this);
		glSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);

    	mContext = context;
    	mHandler = handler;

		mVertexBuffer = ByteBuffer.allocateDirect(TextureRotationUtil.CUBE.length * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer();
        mVertexBuffer.put(TextureRotationUtil.CUBE).position(0);

        mTextureBuffer = ByteBuffer.allocateDirect(TextureRotationUtil.TEXTURE_NO_ROTATION.length * 4)
                .order(ByteOrder.nativeOrder())
                .asFloatBuffer();
        mTextureBuffer.put(TextureRotationUtil.TEXTURE_NO_ROTATION).position(0);

		initHumanAction();
		initFaceAttribute();
		initCatFace();

		if(mNeedAvatar)initAvatar();

		for(int i = 0; i < 27; i++){
			mBeautifyParams[i] = ImageActivity.DEFAULT_BEAUTIFY_PARAMS[i];
		}

		initHandlerManager();
	}

	private void initHandlerManager(){
		mChangeStickerManagerThread = new HandlerThread("ChangeStickerManagerThread");
		mChangeStickerManagerThread.start();
		mChangeStickerManagerHandler = new Handler(mChangeStickerManagerThread.getLooper()) {
			@Override
			public void handleMessage(Message msg) {
				switch (msg.what){
					case MESSAGE_NEED_CHANGE_STICKER:
						String sticker = (String) msg.obj;
						mCurrentSticker = sticker;
						mStStickerNative.changeSticker(mCurrentSticker);
						setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
						refreshDisplay();
						break;

					case MESSAGE_NEED_REMOVEALL_STICKERS:
						mStStickerNative.removeAllStickers();
						if(mCurrentStickerMaps != null){
							mCurrentStickerMaps.clear();
						}
						setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
						refreshDisplay();
						break;

					default:
						break;
				}
			}
		};
	}

	private void initFaceAttribute() {
		int result = mSTFaceAttributeNative.createInstance(FileUtils.getFaceAttributeModelPath(mContext));
		LogUtils.i(TAG, "the result for createInstance for faceAttribute is %d", result);
	}

	private void initCatFace(){
		int result = mStAnimalNative.createInstance(FileUtils.getFilePath(mContext, FileUtils.MODEL_NAME_CATFACE_CORE), STCommon.ST_MOBILE_TRACKING_MULTI_THREAD);
		LogUtils.i(TAG, "create animal handle result: %d", result);
	}

	private void initAvatar(){
		int result = mSTMobileAvatarNative.createInstanceFromAssetFile(FileUtils.MODEL_NAME_AVATAR_CORE, mContext.getAssets());
		LogUtils.i(TAG, "create avatar handle result: %d", result);
	}

	private void initHumanAction() {
		//从sd读取model路径，创建handle
		//int result = mSTHumanActionNative.createInstance(FileUtils.getTrackModelPath(mContext), mHumanActionCreateConfig);

		//从asset资源文件夹读取model到内存，再使用底层st_mobile_human_action_create_from_buffer接口创建handle
		int result = mSTHumanActionNative.createInstanceFromAssetFile(FileUtils.getActionModelName(), mHumanActionCreateConfig, mContext.getAssets());
		LogUtils.i(TAG, "the result for createInstance for human action is %d", result);

		if(result == 0){
            result = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_HAND, mContext.getAssets());
            LogUtils.i(TAG, "add hand model result: %d", result);
            result = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_SEGMENT, mContext.getAssets());
            LogUtils.i(TAG, "add figure segment model result: %d", result);

			result = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.getFaceExtraModelName(), mContext.getAssets());
			LogUtils.i(TAG, "add face extra model result %d", result);

			result = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_EYEBALL_CONTOUR, mContext.getAssets());
			LogUtils.i(TAG, "add eyeball contour model result: %d", result);

			//for test avatar
			if(mNeedAvatar){
				int ret = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_AVATAR_HELP, mContext.getAssets());
				LogUtils.i(TAG, "add avatar help model result: %d", ret);

//				ret = mSTHumanActionNative.addSubModelFromAssetFile(FileUtils.MODEL_NAME_TONGUE, mContext.getAssets());
//				LogUtils.i(TAG,"add tongue model result: %d", ret );
			}
		}
	}

	private void initSticker() {
		int result = mStStickerNative.createInstance(null);
		LogUtils.i(TAG, "the result for createInstance for sticker is %d", result);

		result = mStStickerNative.setWaitingMaterialLoaded(true);
		LogUtils.i(TAG, "the result for createInstance for setWaitingMaterialLoaded is %d", result);

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

	private void initFilter(){
		mSTMobileStreamFilterNative.createInstance();

		//mFilterStyle = null;
		mSTMobileStreamFilterNative.setStyle(null);
		mSTMobileStreamFilterNative.setParam(STFilterParamsType.ST_FILTER_STRENGTH, mFilterStrength);
	}

	private void initMakeup(){
		int result = mSTMobileMakeupNative.createInstance();
		LogUtils.i(TAG, "makeup create instance result %d", result);

		for(int i = 0; i < Constants.MAKEUP_TYPE_COUNT; i++){
			if(mMakeupPackageId[i] > 0){
				setMakeupForType(i, mCurrentMakeup[i]);
				setStrengthForType(i, mMakeupStrength[i]);
			}
		}
	}

	public void enableBeautify(boolean needBeautify) {
		mNeedBeautify = needBeautify;
	}

	public void enableFaceAttribute(boolean needFaceAttribute) {
		mNeedFaceAttribute = needFaceAttribute;
		refreshDisplay();
	}

	private String genFaceAttributeString(STFaceAttribute arrayFaceAttribute){
		String attribute = null;
		String gender = arrayFaceAttribute.arrayAttribute[2].label;
		if(gender.equals("male")){
			gender = "男";
		}else{
			gender = "女";
		}
		attribute = "颜值:" + arrayFaceAttribute.arrayAttribute[1].label + " "
				+ "性别:" + gender + " "
				+ "年龄:"+arrayFaceAttribute.arrayAttribute[0].label + " ";
		return attribute;
	}

	public void enableSticker(boolean needSticker){
		mNeedSticker = needSticker;
		if(!needSticker){
			refreshDisplay();
		}
	}

	public void enableFilter(boolean needFilter){
		mNeedFilter = needFilter;
		if(!needFilter){
			refreshDisplay();
		}
	}

	public void enableMakeUp(boolean needMakeup){
		mNeedMakeup = needMakeup;
		setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());

		if(needMakeup){
			refreshDisplay();
		}
	}

	public long getCostTime(){
		return mFrameCostTime;
	}

	public String getFaceAttributeString() {
		return mFaceAttribute;
	}

	public void changeSticker(String sticker) {
		mChangeStickerManagerHandler.removeMessages(MESSAGE_NEED_CHANGE_STICKER);
		Message msg = mChangeStickerManagerHandler.obtainMessage(MESSAGE_NEED_CHANGE_STICKER);
		msg.obj = sticker;

		mChangeStickerManagerHandler.sendMessage(msg);
	}

	public int addSticker(String addSticker) {
		mCurrentSticker = addSticker;
		int stickerId = mStStickerNative.addSticker(mCurrentSticker);

		if(stickerId > 0){
			if(mCurrentStickerMaps != null){
				mCurrentStickerMaps.put(stickerId, mCurrentSticker);
			}

			refreshDisplay();

			return stickerId;
		}else {
			Message message = mHandler.obtainMessage(ImageActivity.MSG_NEED_SHOW_TOO_MUCH_STICKER_TIPS);
			mHandler.sendMessage(message);
			return -1;
		}
	}

	public void removeSticker(int packageId) {

		int result = mStStickerNative.removeSticker(packageId);

		if(mCurrentStickerMaps != null && result == 0){
			mCurrentStickerMaps.remove(packageId);
		}
		refreshDisplay();
	}

	public void removeAllStickers() {
		mChangeStickerManagerHandler.removeMessages(MESSAGE_NEED_REMOVEALL_STICKERS);
		Message msg = mChangeStickerManagerHandler.obtainMessage(MESSAGE_NEED_REMOVEALL_STICKERS);

		mChangeStickerManagerHandler.sendMessage(msg);
	}

	public void setFilterStyle(String modelPath) {
		mFilterStyle = modelPath;
		refreshDisplay();
	}

	public void setFilterStrength(float strength){
		mFilterStrength = strength;
		refreshDisplay();
	}

	public void setBeautyParam(int index, float value) {
		if(mBeautifyParams[index] != value){
			mStBeautifyNative.setParam(Constants.beautyTypes[index], value);
			mBeautifyParams[index] = value;
			refreshDisplay();
		}

	}

	public float[] getBeautyParams(){
		float[] values = new float[6];
		for(int i = 0; i< mBeautifyParams.length; i++){
			values[i] = mBeautifyParams[i];
		}

		return values;
	}

	public void enableSave(boolean save){
		mNeedSave = save;
		refreshDisplay();
	}

	public void setHandler(Handler handler){
		mHandler = handler;
	}

	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig config) {
		GLES20.glDisable(GL10.GL_DITHER);
        GLES20.glClearColor(0,0,0,0);
        GLES20.glDisable(GL10.GL_CULL_FACE);
        GLES20.glEnable(GL10.GL_DEPTH_TEST);
        mImageInputRender.init();

		initSticker();

		if(mNeedSticker && mCurrentStickerMaps.size() == 0){
			mStStickerNative.changeSticker(mCurrentSticker);
		}

		if(mNeedSticker && mCurrentStickerMaps != null){
			TreeMap<Integer, String> currentStickerMap = new TreeMap<>();

			for (Integer index : mCurrentStickerMaps.keySet()) {
				String sticker = mCurrentStickerMaps.get(index);//得到每个key多对用value的值

				int packageId = mStStickerNative.addSticker(sticker);
				currentStickerMap.put(packageId, sticker);

				Message messageReplace = mHandler.obtainMessage(ImageActivity.MSG_NEED_REPLACE_STICKER_MAP);
				messageReplace.arg1 = index;
				messageReplace.arg2 = packageId;
				mHandler.sendMessage(messageReplace);
			}

			mCurrentStickerMaps.clear();

			Iterator<Integer> iter =  currentStickerMap.keySet().iterator();
			while (iter.hasNext()) {
				int key = iter.next();
				mCurrentStickerMaps.put(key, currentStickerMap.get(key));
			}
		}

		setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
	}

	@Override
	public void onSurfaceChanged(GL10 gl, int width, int height) {
		GLES20.glViewport(0, 0, width, height);
		mDisplayWidth = width;
		mDisplayHeight = height;
		adjustImageDisplaySize();
		mInitialized = true;
	}

	@Override
	public void onDrawFrame(GL10 gl) {
		long frameStartTime = System.currentTimeMillis();
		if(!mInitialized)
			return;
		GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
		GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT | GLES20.GL_DEPTH_BUFFER_BIT);

		int textureId = OpenGLUtils.NO_TEXTURE;

		if(mOriginBitmap != null && mTextureId == OpenGLUtils.NO_TEXTURE){
			mTextureId = OpenGLUtils.loadTexture(mOriginBitmap, OpenGLUtils.NO_TEXTURE);
			textureId = mTextureId;
		}else if(mTextureId != OpenGLUtils.NO_TEXTURE){
			textureId = mTextureId;
		}else{
			return;
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

		byte[] mTmpBuffer = null;
		if(mOriginBitmap != null) {
			if(mTmpBuffer == null){
				mTmpBuffer = STUtils.getBGRFromBitmap(mOriginBitmap);
			}

			if(!mShowOriginal){
				if(mNeedBeautify || mCurrentSticker != null || mNeedFaceAttribute) {
					STMobile106[] arrayFaces = null, arrayOutFaces = null;
					int orientation = 0;
					long humanActionCostTime = System.currentTimeMillis();
					STHumanAction humanAction = mSTHumanActionNative.humanActionDetect(mTmpBuffer, STCommon.ST_PIX_FMT_BGR888,
							mHumanActionDetectConfig, orientation,
							mImageWidth, mImageHeight);
					LogUtils.i(TAG, "human action cost time: %d", System.currentTimeMillis() - humanActionCostTime);

//					if(mNeedFaceExtraInfo && humanAction != null){
//						if(humanAction.faceExtraInfo != null){
//							STPoint[] points = humanAction.faceExtraInfo.getAllPoints();
//						}
//					}

					if(mNeedAvatarExpression){
						if(humanAction != null && humanAction.getFaceInfos() != null){
							mSTMobileAvatarNative.avatarExpressionDetect(orientation, mImageWidth, mImageHeight, humanAction.getFaceInfos()[0], mAvatarExpression);
							Log.d("avatarExpressionResult:", Arrays.toString(mAvatarExpression));
						}
					}

					long catDetectStartTime = System.currentTimeMillis();
					mAnimalFace = mStAnimalNative.animalDetect(mTmpBuffer,  STCommon.ST_PIX_FMT_BGR888, orientation, mImageWidth, mImageHeight);
					LogUtils.i(TAG, "cat face detect cost time: %d", System.currentTimeMillis() - catDetectStartTime);
					animalFaceLlength = mAnimalFace == null ? 0 : mAnimalFace.length;

					if(mNeedBeautify || mNeedFaceAttribute){
						if (humanAction != null) {
							arrayFaces = humanAction.getMobileFaces();
							if (arrayFaces != null && arrayFaces.length > 0) {
								arrayOutFaces = new STMobile106[arrayFaces.length];
							}
						}
					}
					if(arrayFaces != null && arrayFaces.length != 0){
						if (mNeedFaceAttribute && arrayFaces != null && arrayFaces.length != 0) { // face attribute
							STFaceAttribute[] arrayFaceAttribute = new STFaceAttribute[arrayFaces.length];
							long attributeCostTime = System.currentTimeMillis();
							int result = mSTFaceAttributeNative.detect(mTmpBuffer, STCommon.ST_PIX_FMT_BGR888, mImageWidth, mImageHeight, arrayFaces, arrayFaceAttribute);
							LogUtils.i(TAG, "attribute cost time: %d", System.currentTimeMillis() - attributeCostTime);
							if (result == 0) {
								if (arrayFaceAttribute[0].attribute_count > 0) {
									mFaceAttribute = genFaceAttributeString(arrayFaceAttribute[0]);
									mNeedFaceAttribute = false;
								} else {
									mFaceAttribute = "null";
								}
							}
						}
					}

					if (mNeedBeautify) {// do beautify
						long beautyStartTime = System.currentTimeMillis();
						int result = mStBeautifyNative.processTexture(textureId, mImageWidth, mImageHeight, orientation, humanAction, mBeautifyTextureId[0], mHumanActionBeautyOutput);
						long beautyEndTime = System.currentTimeMillis();
						LogUtils.i(TAG, "beautify cost time: %d", beautyEndTime-beautyStartTime);
						if (result == 0) {
							textureId = mBeautifyTextureId[0];
						}

						humanAction = mHumanActionBeautyOutput;
						LogUtils.i(TAG, "replace enlarge eye and shrink face action");
					}

					if(mNeedMakeup){
						long startMakeup = System.currentTimeMillis();

						int ret = mSTMobileMakeupNative.prepare(mTmpBuffer, STCommon.ST_PIX_FMT_BGR888, mImageWidth, mImageHeight, humanAction);

						int result = mSTMobileMakeupNative.processTexture(textureId, humanAction, orientation,  mImageWidth, mImageHeight, mMakeupTextureId[0]);

						if (result == 0) {
							textureId = mMakeupTextureId[0];
						}

						LogUtils.i(TAG, "makeup cost time: %d", System.currentTimeMillis() - startMakeup);
					}

					if(mNeedSticker){
						int event = mCustomEvent;
						float[] values = {0f, 0f, 0f, 0f};
						STStickerInputParams inputParams = new STStickerInputParams(values, false, mCustomEvent);

						long stickerStartTime = System.currentTimeMillis();
						int result = mStStickerNative.processTextureBoth(textureId, humanAction, orientation, STRotateType.ST_CLOCKWISE_ROTATE_0, mImageWidth, mImageHeight,
								false, inputParams, mAnimalFace, animalFaceLlength, mTextureOutId[0]);
						LogUtils.i(TAG, "sticker cost time: %d", System.currentTimeMillis()-stickerStartTime);
						if (result == 0) {
							textureId = mTextureOutId[0];
						}

						if(event == mCustomEvent){
							mCustomEvent = 0;
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

				if (mFilterTextureOutId == null) {
					mFilterTextureOutId = new int[1];
					GlUtil.initEffectTexture(mImageWidth, mImageHeight, mFilterTextureOutId, GLES20.GL_TEXTURE_2D);
				}
				//滤镜
				if(mNeedFilter){
					long filterStartTime = System.currentTimeMillis();
					int ret = mSTMobileStreamFilterNative.processTexture(textureId, mImageWidth, mImageHeight, mFilterTextureOutId[0]);
					LogUtils.i(TAG, "filter cost time: %d", System.currentTimeMillis()-filterStartTime);
					if(ret == 0){textureId = mFilterTextureOutId[0];}
				}

				GLES20.glViewport(0, 0, mDisplayWidth, mDisplayHeight);

				mImageInputRender.onDrawFrame(textureId,mVertexBuffer,mTextureBuffer);
			} else {
				mImageInputRender.onDisplaySizeChanged(mDisplayWidth,mDisplayHeight);
				mImageInputRender.onDrawFrame(mTextureId,mVertexBuffer,mTextureBuffer);
			}
			GLES20.glFinish();
		}

		mFrameCostTime = System.currentTimeMillis() - frameStartTime;
		LogUtils.i(TAG, "image onDrawFrame, the time for frame process is " + (System.currentTimeMillis() - frameStartTime));

		if (mCostListener != null) {
			mCostListener.onCostChanged((int)mFrameCostTime);
		}
		if(mNeedSave){
			textureToBitmap(textureId);
			mNeedSave =false;
		}
	}

	public void setImageBitmap(Bitmap bitmap) {
		if (bitmap == null || bitmap.isRecycled())
			return;
		mImageWidth = bitmap.getWidth();
		mImageHeight = bitmap.getHeight();
		mOriginBitmap = bitmap;
		adjustImageDisplaySize();
		refreshDisplay();
	}

	public void setShowOriginal(boolean isShow)
	{
		mShowOriginal = isShow;
		refreshDisplay();
	}

	private void refreshDisplay(){
		//deleteTextures();
		mGlSurfaceView.requestRender();
		setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());
	}

	public void onResume(){
		initBeauty();
		//initSticker();
		initFilter();
		initMakeup();
		mGlSurfaceView.onResume();

//		if(mNeedSticker || mNeedFilter){
//			mStStickerNative.changeSticker(mCurrentSticker);
//			mCurrentFilterStyle = null;
//		}

		if(mNeedFilter){
			mCurrentFilterStyle = null;
		}
	}

	public void onPause(){
		//mCurrentSticker = null;

		mGlSurfaceView.queueEvent(new Runnable() {
			@Override
			public void run() {
				mStStickerNative.removeAvatarModel();
				mStStickerNative.destroyInstance();
				mStBeautifyNative.destroyBeautify();
				mSTMobileStreamFilterNative.destroyInstance();
				mSTMobileAvatarNative.destroyInstance();
				mSTMobileMakeupNative.destroyInstance();

				deleteTextures();
			}
		});

		mGlSurfaceView.onPause();
	}

	public void onDestroy(){
		mSTHumanActionNative.destroyInstance();
		mSTFaceAttributeNative.destroyInstance();
		mStAnimalNative.destroyInstance();
	}

	private void adjustImageDisplaySize() {
		float ratio1 = (float)mDisplayWidth / mImageWidth;
        float ratio2 = (float)mDisplayHeight / mImageHeight;
        float ratioMax = Math.max(ratio1, ratio2);
        int imageWidthNew = Math.round(mImageWidth * ratioMax);
        int imageHeightNew = Math.round(mImageHeight * ratioMax);

        float ratioWidth = imageWidthNew / (float)mDisplayWidth;
        float ratioHeight = imageHeightNew / (float)mDisplayHeight;

        float[] cube = new float[]{
        		TextureRotationUtil.CUBE[0] / ratioHeight, TextureRotationUtil.CUBE[1] / ratioWidth,
        		TextureRotationUtil.CUBE[2] / ratioHeight, TextureRotationUtil.CUBE[3] / ratioWidth,
        		TextureRotationUtil.CUBE[4] / ratioHeight, TextureRotationUtil.CUBE[5] / ratioWidth,
        		TextureRotationUtil.CUBE[6] / ratioHeight, TextureRotationUtil.CUBE[7] / ratioWidth,
        };
        mVertexBuffer.clear();
        mVertexBuffer.put(cube).position(0);
    }

	private void textureToBitmap(int textureId){
		ByteBuffer mTmpBuffer = ByteBuffer.allocate(mImageHeight * mImageWidth * 4);

		int[] mFrameBuffers = new int[1];
		if(textureId != OpenGLUtils.NO_TEXTURE) {
			GLES20.glGenFramebuffers(1, mFrameBuffers, 0);
			GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId);
			GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, mFrameBuffers[0]);
			GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0, GLES20.GL_TEXTURE_2D,textureId, 0);
		}
		GLES20.glReadPixels(0, 0, mImageWidth, mImageHeight, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, mTmpBuffer);
		GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
		GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
		mProcessedImage = Bitmap.createBitmap(mImageWidth, mImageHeight, Bitmap.Config.ARGB_8888);
		mProcessedImage.copyPixelsFromBuffer(mTmpBuffer);

//		mProcessedImage = STUtils.getBitmapFromRGBA(mTmpBuffer.array(),mImageWidth,mImageHeight);

		Message msg = Message.obtain(mHandler);
		msg.what = ImageActivity.MSG_SAVING_IMG;
		msg.sendToTarget();
	}

	public Bitmap getBitmap(){
		return mProcessedImage;
	}

	protected void deleteTextures() {
		if(mTextureId != OpenGLUtils.NO_TEXTURE)
			mGlSurfaceView.queueEvent(new Runnable() {

				@Override
				public void run() {
	                GLES20.glDeleteTextures(1, new int[]{
	                        mTextureId
	                }, 0);
	                mTextureId = OpenGLUtils.NO_TEXTURE;

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

					if(mFilterTextureOutId != null){
						GLES20.glDeleteTextures(1, mFilterTextureOutId, 0);
						mFilterTextureOutId = null;
					}
	            }
	        });
    }

	public interface CostChangeListener {
		void onCostChanged(int value);
	}

	public void setCostChangeListener(CostChangeListener listener) {
		mCostListener = listener;
	}

	public void changeCustomEvent(){
		mCustomEvent = STCustomEvent.ST_CUSTOM_EVENT_1 | STCustomEvent.ST_CUSTOM_EVENT_2;
	}

	public void setSensorEvent(SensorEvent event){
		mSensorEvent =  event;
	}

	public void setMakeupForType(int type, String typePath){
		mMakeupPackageId[type] = mSTMobileMakeupNative.setMakeupForType(type, typePath);
		setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());

		if(mMakeupPackageId[type] > 0){
			mCurrentMakeup[type] = typePath;
			refreshDisplay();
		}
	}

	public void setMakeupForTypeFromAssets(int type, String typePath){
		mMakeupPackageId[type] = mSTMobileMakeupNative.setMakeupForTypeFromAssetsFile(type, typePath, mContext.getAssets());
		setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());

		if(mMakeupPackageId[type] > 0){
			mCurrentMakeup[type] = typePath;
			refreshDisplay();
		}
	}

	public void removeMakeupByType(int type){
		int ret = mSTMobileMakeupNative.removeMakeup(mMakeupPackageId[type]);
		setHumanActionDetectConfig(mNeedBeautify|mNeedFaceAttribute, mStStickerNative.getTriggerAction(), mSTMobileMakeupNative.getTriggerAction());

		if(ret == 0){
			mMakeupPackageId[type] = 0;
			refreshDisplay();
		}
	}

	public void setStrengthForType(int type, float strength){
		if(type == Constants.ST_MAKEUP_HIGHLIGHT){
			mSTMobileMakeupNative.setStrengthForType(type, strength * mMakeUpStrength);
			mMakeupStrength[type] = strength * mMakeUpStrength;
		}else{
			mSTMobileMakeupNative.setStrengthForType(type, strength);
			mMakeupStrength[type] = strength;
		}
		refreshDisplay();
	}

	private void setHumanActionDetectConfig(boolean needFaceDetect, long stickerConfig, long makeupConfig){
		if(!mNeedSticker || mCurrentSticker == null){
			stickerConfig = 0;
		}

		if(!mNeedMakeup){
			makeupConfig = 0;
		}

		if(needFaceDetect){
			mHumanActionDetectConfig = (stickerConfig | makeupConfig | STMobileHumanActionNative.ST_MOBILE_FACE_DETECT);
		}else{
			mHumanActionDetectConfig = stickerConfig | makeupConfig;
		}

		needAnimalDetect = ((mStStickerNative.getAnimalDetectConfig() & STMobileAnimalNative.ST_MOBILE_CAT_DETECT) > 0);
	}
}
