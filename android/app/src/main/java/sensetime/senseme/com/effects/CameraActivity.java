package sensetime.senseme.com.effects;

import android.Manifest;
import android.animation.Animator;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import android.graphics.PorterDuff;
import android.graphics.Rect;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.opengl.GLSurfaceView;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.text.TextUtils;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.CompoundButton;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import com.example.gengmei_app_face.R;
import com.sensetime.sensearsourcemanager.SenseArMaterial;
import com.sensetime.sensearsourcemanager.SenseArMaterialGroupId;
import com.sensetime.sensearsourcemanager.SenseArMaterialService;
import com.sensetime.sensearsourcemanager.SenseArMaterialType;
import com.sensetime.stmobile.STMobileHumanActionNative;
import com.sensetime.stmobile.model.STMobileType;
import com.sensetime.stmobile.model.STPoint;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import sensetime.senseme.com.effects.adapter.BeautyItemAdapter;
import sensetime.senseme.com.effects.adapter.BeautyOptionsAdapter;
import sensetime.senseme.com.effects.adapter.FilterAdapter;
import sensetime.senseme.com.effects.adapter.MakeupAdapter;
import sensetime.senseme.com.effects.adapter.NativeStickerAdapter;
import sensetime.senseme.com.effects.adapter.ObjectAdapter;
import sensetime.senseme.com.effects.adapter.StickerAdapter;
import sensetime.senseme.com.effects.adapter.StickerOptionsAdapter;
import sensetime.senseme.com.effects.display.CameraDisplayDoubleInputMultithread;
import sensetime.senseme.com.effects.display.ChangePreviewSizeListener;
import sensetime.senseme.com.effects.encoder.MediaAudioEncoder;
import sensetime.senseme.com.effects.encoder.MediaEncoder;
import sensetime.senseme.com.effects.encoder.MediaMuxerWrapper;
import sensetime.senseme.com.effects.encoder.MediaVideoEncoder;
import sensetime.senseme.com.effects.glutils.STUtils;
import sensetime.senseme.com.effects.utils.Accelerometer;
import sensetime.senseme.com.effects.utils.CheckAudioPermission;
import sensetime.senseme.com.effects.utils.CommomDialog;
import sensetime.senseme.com.effects.utils.Constants;
import sensetime.senseme.com.effects.utils.FileUtils;
import sensetime.senseme.com.effects.utils.ImageUtils;
import sensetime.senseme.com.effects.utils.LogUtils;
import sensetime.senseme.com.effects.utils.NetworkUtils;
import sensetime.senseme.com.effects.utils.STLicenseUtils;
import sensetime.senseme.com.effects.view.BeautyItem;
import sensetime.senseme.com.effects.view.BeautyOptionsItem;
import sensetime.senseme.com.effects.view.FilterItem;
import sensetime.senseme.com.effects.view.IndicatorSeekBar;
import sensetime.senseme.com.effects.view.MakeupItem;
import sensetime.senseme.com.effects.view.ObjectItem;
import sensetime.senseme.com.effects.view.StickerItem;
import sensetime.senseme.com.effects.view.StickerOptionsItem;
import sensetime.senseme.com.effects.view.StickerState;
import sensetime.senseme.com.effects.view.VerticalSeekBar;

public class CameraActivity extends Activity implements View.OnClickListener, SensorEventListener {
    private final static String TAG = "CameraActivity";
    //正式服appid appkey
    public final static String APPID = "6dc0af51b69247d0af4b0a676e11b5ee";//正式服
    public final static String APPKEY = "e4156e4d61b040d2bcbf896c798d06e3";//正式服

    //正式服group id
//    public final static String GROUP_2D = "3de29f00471811e99b5702f2be4220bd";
//    public final static String GROUP_3D = "37bb4dc0471811e99b5702f2be4220bd";
//    public final static String GROUP_HAND = "5c4e8df0471811e99b5702f2be4220bd";
//    public final static String GROUP_BG = "49296e70471811e99b5702f2be4220bd";
//    public final static String GROUP_FACE = "eb17bf20471811e9a1b5020d88ee5e78";
//    public final static String GROUP_AVATAR = "de637d00471811e9a1b5020d88ee5e78";
//    public final static String GROUP_BEAUTY = "f10ed8a0471811e9a1b5020d88ee5e78";
//    public final static String GROUP_PARTICLE = "7c6089f0f6c211e8877702f2beb67403";

    //正式服group id
    public final static String GROUP_2D = "3cd2dae0f6c211e8877702f2beb67403";
    public final static String GROUP_3D = "4e869010f6c211e888ea020d88863a42";
    public final static String GROUP_HAND = "5aea6840f6c211e899f602f2be7c2171";
    public final static String GROUP_BG = "65365cf0f6c211e8877702f2beb67403";
    public final static String GROUP_FACE = "6d036ef0f6c211e899f602f2be7c2171";
    public final static String GROUP_AVATAR = "46028a20f6c211e888ea020d88863a42";
    public final static String GROUP_BEAUTY = "73bffb50f6c211e899f602f2be7c2171";
    public final static String GROUP_PARTICLE = "7c6089f0f6c211e8877702f2beb67403";

//    //测试服appid appkey
//    public final static String APPID = "f1c9978f14df4258b1423d4bae905df7";//测试服
//    public final static String APPKEY = "ec239abac83e459ea3ceb86ce83877da";//测试服
//    //测试服group id
//    public final static String GROUP_2D = "6f2a7ff0208b11e9af010203127b999c";
//    public final static String GROUP_3D = "7e02b380208b11e9af010203127b999c";
//    public final static String GROUP_HAND = "87f3de00208b11e9af010203127b999c";
//    public final static String GROUP_BG = "a64f7940208b11e9af010203127b999c";
//    public final static String GROUP_FACE = "4cbee540208c11e9af010203127b999c";
//    public final static String GROUP_AVATAR = "76e394c0208b11e9af010203127b999c";
//    public final static String GROUP_BEAUTY = "53755720208c11e9af010203127b999c";
//    public final static String GROUP_PARTICLE = "5ab82a80208c11e9af010203127b999c";

    //debug for test
    public static final boolean DEBUG = false;
    private Accelerometer mAccelerometer = null;

    //双输入使用
//    private CameraDisplayDoubleInput mCameraDisplay;

    //单输入使用
    //private CameraDisplaySingleInput mCameraDisplay;

    //单输入优化
    //private CameraDisplaySingleInputMultiThread mCameraDisplay;

    //双输入优化
    private CameraDisplayDoubleInputMultithread mCameraDisplay;

    private FrameLayout mPreviewFrameLayout;
    private ImageView mMeteringArea;

    private RecyclerView mStickersRecycleView;
    private RecyclerView mStickerOptionsRecycleView, mFilterOptionsRecycleView, mMakeupOptionsRecycleView;
    private RecyclerView mBeautyBaseRecycleView;
    private StickerOptionsAdapter mStickerOptionsAdapter;
    private BeautyOptionsAdapter mBeautyOptionsAdapter;
    private BeautyItemAdapter mBeautyBaseAdapter, mBeautyProfessionalAdapter, mAdjustAdapter, mMicroAdapter;
    private ArrayList<StickerOptionsItem> mStickerOptionsList = new ArrayList<>();
    private ArrayList<BeautyOptionsItem> mBeautyOptionsList;

    private HashMap<String, StickerAdapter> mStickerAdapters = new HashMap<>();
//    private HashMap<String, NewStickerAdapter> mNewStickerAdapters = new HashMap<>();
    private HashMap<String, NativeStickerAdapter> mNativeStickerAdapters = new HashMap<>();
    private HashMap<String, BeautyItemAdapter> mBeautyItemAdapters = new HashMap<>();
    private HashMap<String, ArrayList<StickerItem>> mStickerlists = new HashMap<>();
    private ArrayList<StickerItem> mNewStickers;
    private HashMap<String, ArrayList<BeautyItem>> mBeautylists = new HashMap<>();
    private HashMap<Integer, String> mBeautyOption = new HashMap<>();
    private HashMap<Integer, Integer> mBeautyOptionSelectedIndex = new HashMap<>();

    private HashMap<String, MakeupAdapter> mMakeupAdapters = new HashMap<>();
    private HashMap<String, ArrayList<MakeupItem>> mMakeupLists = new HashMap<>();
    private HashMap<String, Integer> mMakeupOptionIndex = new HashMap<>();
    private HashMap<Integer, Integer> mMakeupOptionSelectedIndex = new HashMap<>();
    private HashMap<Integer, Integer> mMakeupStrength = new HashMap<>();

    private HashMap<String, FilterAdapter> mFilterAdapters = new HashMap<>();
    private HashMap<String, ArrayList<FilterItem>> mFilterLists = new HashMap<>();

    private ObjectAdapter mObjectAdapter;
    private List<ObjectItem> mObjectList;
    private boolean mNeedObject = false;

    private TextView mSavingTv;
    private TextView mAttributeText;

    private TextView mShowOriginBtn1, mShowOriginBtn2, mShowOriginBtn3;
    private boolean mIsShowingOriginal = false;
    private TextView mShowShortVideoTime;
    private TextView mSmallPreviewSize, mLargePreviewSize;

    private LinearLayout mFilterGroupsLinearLayout, mFilterGroupPortrait, mFilterGroupStillLife, mFilterGroupScenery, mFilterGroupFood;
    private LinearLayout mMakeupGroupLip, mMakeupGroupCheeks, mMakeupGroupFace, mMakeupGroupBrow, mMakeupGroupEye, mMakeupGroupEyeLiner, mMakeupGroupEyeLash, mMakeupGroupEyeBall;
    private RelativeLayout mFilterIconsRelativeLayout, mFilterStrengthLayout, mMakeupIconsRelativeLayout, mMakeupGroupRelativeLayout;
    private ImageView mFilterGroupBack, mMakeupGroupBack;
    private TextView mFilterGroupName, mFilterStrengthText;
    private TextView mMakeupGroupName;
    private SeekBar mFilterStrengthBar;
    private VerticalSeekBar mVerticalSeekBar;
    private int mCurrentFilterGroupIndex = -1;
    private int mCurrentFilterIndex = -1;
    private int mCurrentMakeupGroupIndex = -1;
    private int mCurrentObjectIndex = -1;

    private float[] mBeautifyParams = {0.36f, 0.74f, 0.02f, 0.13f, 0.11f, 0.1f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f};

    private RelativeLayout mTipsLayout;
    private TextView mTipsTextView, mResetTextView;
    private ImageView mTipsImageView;
    private IndicatorSeekBar mIndicatorSeekbar;
    private Context mContext;
    private Handler mTipsHandler = new Handler();
    private Runnable mTipsRunnable;

    public static final int MSG_BITMAP=12200;
    public static final int MSG_SAVING_IMG = 1;
    public static final int MSG_SAVED_IMG = 2;
    public static final int MSG_DRAW_OBJECT_IMAGE_AND_RECT = 3;
    public static final int MSG_DRAW_OBJECT_IMAGE = 4;
    public static final int MSG_CLEAR_OBJECT = 5;
    public static final int MSG_MISSED_OBJECT_TRACK = 6;
    public static final int MSG_DRAW_FACE_EXTRA_POINTS = 7;
    private static final int MSG_NEED_UPDATE_TIMER = 8;
    private static final int MSG_NEED_START_CAPTURE = 9;
    private static final int MSG_NEED_START_RECORDING = 10;
    private static final int MSG_STOP_RECORDING = 11;
    public static final int MSG_HIDE_VERTICALSEEKBAR = 12;

    public final static int MSG_UPDATE_HAND_ACTION_INFO = 100;
    public final static int MSG_RESET_HAND_ACTION_INFO = 101;
    public final static int MSG_UPDATE_BODY_ACTION_INFO = 102;
    public final static int MSG_UPDATE_FACE_EXPRESSION_INFO = 103;
    public final static int MSG_NEED_UPDATE_STICKER_TIPS = 104;
    //    public final static int MSG_NEED_UPDATE_STICKER_MAP = 105;
    public final static int MSG_NEED_REPLACE_STICKER_MAP = 106;
    public final static int MSG_NEED_SHOW_TOO_MUCH_STICKER_TIPS = 107;

    private static final int PERMISSION_REQUEST_WRITE_PERMISSION = 1001;
    private boolean mPermissionDialogShowing = false;
    private Thread mCpuInofThread;
    private float mCurrentCpuRate = 0.0f;

    private SurfaceView mSurfaceViewOverlap;
    private Bitmap mGuideBitmap;
    private Paint mPaint = new Paint();

    private int mIndexX = 0, mIndexY = 0;
    private boolean mCanMove = false;

    private LinearLayout mStickerOptionsSwitch;
    private RelativeLayout mStickerOptions;
    private RecyclerView mStickerIcons;
    private boolean mIsStickerOptionsOpen = false;

    private int mCurrentStickerOptionsIndex = -1;
    private int mCurrentStickerPosition = -1;
    private int mCurrentNewStickerPosition = -1;
    private int mCurrentBeautyIndex = Constants.ST_BEAUTIFY_WHITEN_STRENGTH;

    private LinearLayout mBeautyOptionsSwitch, mBaseBeautyOptions;
    private RecyclerView mFilterIcons, mBeautyOptionsRecycleView;
    private boolean mIsBeautyOptionsOpen = false;
    private int mBeautyOptionsPosition = 0;
    private ArrayList<SeekBar> mBeautyParamsSeekBarList = new ArrayList<SeekBar>();

    private ImageView mSettingOptionsSwitch;
    private RelativeLayout mSettingOptions;
    private boolean mIsSettingOptionsOpen = false;
    private LinearLayout mFpsInfo;

    private ImageView mSelectionPicture;
    private Button mCaptureButton;

    private ImageView mBeautyOptionsSwitchIcon, mStickerOptionsSwitchIcon;
    private TextView mBeautyOptionsSwitchText, mStickerOptionsSwitchText;
    private RelativeLayout mFilterAndBeautyOptionView;
    private Switch mPerformanceInfoSwitch;
    private LinearLayout mSelectOptions;

    private int mTimeSeconds = 0;
    private int mTimeMinutes = 0;
    private Timer mTimer;
    private TimerTask mTimerTask;
    private boolean mIsRecording = false;
    private String mVideoFilePath = null;
    private long mTouchDownTime = 0;
    private long mTouchCurrentTime = 0;
    private boolean mOnBtnTouch = false;
    private boolean mIsHasAudioPermission = false;

    private Map<Integer, Integer> mStickerPackageMap;

    private Switch test;
    private boolean testboolean = false;
    private boolean mNeedStopCpuRate = false;

    private Switch mFaceExtraInfoSwitch, mEyeBallContourSwitch, mHandActionSwitch, mBodySwitch;

    private SensorManager mSensorManager;
    private Sensor mRotation;
    long timeDown = 0;
    int downX, downY;
    private float oldDist = 1f;
    //记录用户最后一次点击的素材id ,包括还未下载的，方便下载完成后，直接应用素材
    private String preMaterialId = "";
//    private Bitmap mMeteringAreaBitmap;
//    private Matrix matrix = new Matrix();

    private Handler mHandler = new Handler() {
        @Override
        public void handleMessage(final Message msg) {
            super.handleMessage(msg);

            switch (msg.what) {
                case MSG_SAVING_IMG:
                    ByteBuffer data = (ByteBuffer) msg.obj;
                    Bundle bundle = msg.getData();
                    int imageWidth = bundle.getInt("imageWidth");
                    int imageHeight = bundle.getInt("imageHeight");
                    onPictureTaken(data, FileUtils.getOutputMediaFile(), imageWidth, imageHeight);

                    break;
                case MSG_SAVED_IMG:
                    mSavingTv.setVisibility(View.VISIBLE);
                    mSavingTv.setText("图片保存成功");
                    new Handler().postDelayed(new Runnable() {
                        public void run() {
                            mSavingTv.setVisibility(View.GONE);
                        }
                    }, 1000);

                    break;
                case MSG_DRAW_OBJECT_IMAGE_AND_RECT:
                    Rect indexRect = (Rect) msg.obj;
                    drawObjectImage(indexRect, true);

                    break;
                case MSG_DRAW_OBJECT_IMAGE:
                    Rect rect = (Rect) msg.obj;
                    drawObjectImage(rect, false);

                    break;
                case MSG_CLEAR_OBJECT:
                    clearObjectImage();

                    break;
                case MSG_MISSED_OBJECT_TRACK:
                    mObjectAdapter.setSelectedPosition(1);
                    mObjectAdapter.notifyDataSetChanged();
                    break;

                case MSG_DRAW_FACE_EXTRA_POINTS:
                    STPoint[] points = (STPoint[]) msg.obj;
                    drawFaceExtraPoints(points);
                    break;

                case MSG_NEED_UPDATE_TIMER:
                    updateTimer();
                    break;

                case MSG_NEED_START_RECORDING:
                    //开始录制
                    startRecording();
                    closeTableView();
                    disableShowLayouts();
                    mShowShortVideoTime.setVisibility(View.VISIBLE);

                    mTimer = new Timer();
                    mTimerTask = new TimerTask() {
                        @Override
                        public void run() {
                            Message msg = mHandler.obtainMessage(MSG_NEED_UPDATE_TIMER);
                            mHandler.sendMessage(msg);
                        }
                    };

                    mTimer.schedule(mTimerTask, 1000, 1000);
                    break;

                case MSG_STOP_RECORDING:
                    new Handler().postDelayed(new Runnable() {
                        public void run() {
                            //结束录制
                            if (mIsRecording) {
                                return;
                            }
                            stopRecording();
                            enableShowLayouts();
                            mShowShortVideoTime.setVisibility(View.INVISIBLE);

                            if (mTimeMinutes == 0 && mTimeSeconds < 2) {
                                if (mVideoFilePath != null) {
                                    File file = new File(mVideoFilePath);
                                    if (file != null) {
                                        file.delete();
                                    }
                                    mVideoFilePath = null;
                                }
                                mSavingTv.setText("视频不能少于2秒");
                            } else {
                                mSavingTv.setText("视频保存成功");
                            }
                            notifyVideoUpdate(mVideoFilePath);
                            resetTimer();
                        }
                    }, 100);

                    mSavingTv.setVisibility(View.VISIBLE);
                    new Handler().postDelayed(new Runnable() {
                        public void run() {
                            mSavingTv.setVisibility(View.GONE);
                        }
                    }, 1000);

                    break;

                case MSG_UPDATE_HAND_ACTION_INFO:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (mCameraDisplay != null) {
                                showHandActionInfo(mCameraDisplay.getHandActionInfo());
                            }
                        }
                    });
                    break;
                case MSG_RESET_HAND_ACTION_INFO:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (mCameraDisplay != null) {
                                resetHandActionInfo();
                            }
                        }
                    });
                    break;

                case MSG_UPDATE_BODY_ACTION_INFO:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (mCameraDisplay != null) {
                                showBodyActionInfo(mCameraDisplay.getBodyActionInfo());
                            }
                        }
                    });
                    break;

                case MSG_UPDATE_FACE_EXPRESSION_INFO:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if (mCameraDisplay != null) {
                                showFaceExpressionInfo(mCameraDisplay.getFaceExpressionInfo());
                            }
                        }
                    });
                    break;

                case MSG_NEED_UPDATE_STICKER_TIPS:
                    long action = mCameraDisplay.getStickerTriggerAction();
                    showActiveTips(action);
                    break;

                case MSG_NEED_SHOW_TOO_MUCH_STICKER_TIPS:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(mContext, "添加太多贴纸了", Toast.LENGTH_SHORT).show();
                        }
                    });
                    break;

//                case MSG_NEED_UPDATE_STICKER_MAP:
//                    int packageId = msg.arg1;
//                    mStickerPackageMap.put(mCurrentNewStickerPosition, packageId);
//                    break;

                case MSG_NEED_REPLACE_STICKER_MAP:
                    int oldPackageId = msg.arg1;
                    int newPackageId = msg.arg2;

                    for (Integer index : mStickerPackageMap.keySet()) {
                        int stickerId = mStickerPackageMap.get(index);//得到每个key多对用value的值

                        if (stickerId == oldPackageId) {
                            mStickerPackageMap.put(index, newPackageId);
                        }
                    }
                    break;

                case MSG_HIDE_VERTICALSEEKBAR:
                    performVerticalSeekBarVisiable(false);
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //进程后台时被系统强制kill，需重新checkLicense
        if (savedInstanceState != null && savedInstanceState.getBoolean("process_killed")) {
            if (!STLicenseUtils.checkLicense(this)) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(getApplicationContext(), "请检查License授权！", Toast.LENGTH_SHORT).show();
                    }
                });
            }
//            if (!STLicenseUtils.checkLicense(this, SenseArMaterialService.shareInstance().getLicenseData())) {
//                runOnUiThread(new Runnable() {
//                    @Override
//                    public void run() {
//                        Toast.makeText(getApplicationContext(), "请检查License授权！", Toast.LENGTH_SHORT).show();
//                    }
//                });
//            }
        }

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_main);
        mContext = this;
        initView();
        initStickerListFromNet();
        initEvents();

        if (DEBUG) {
            findViewById(R.id.rl_test_layout).setVisibility(View.VISIBLE);
            findViewById(R.id.ll_face_expression).setVisibility(View.VISIBLE);
            findViewById(R.id.ll_hand_action_info).setVisibility(View.VISIBLE);

            ((Switch) findViewById(R.id.testSwitch0)).setVisibility(View.VISIBLE);
            ((Switch) findViewById(R.id.testSwitch1)).setVisibility(View.VISIBLE);
            ((Switch) findViewById(R.id.testSwitch2)).setVisibility(View.VISIBLE);

            LogUtils.setIsLoggable(true);
        }

        resetFilterView();
        mShowOriginBtn1.setVisibility(View.VISIBLE);
        mShowOriginBtn2.setVisibility(View.INVISIBLE);
        mShowOriginBtn3.setVisibility(View.INVISIBLE);

        //滤镜默认选中babypink效果
        setDefaultFilter();
        if (mFilterLists.get("filter_portrait").size() > 0) {
            for (int i = 0; i < mFilterLists.get("filter_portrait").size(); i++) {
                if (mFilterLists.get("filter_portrait").get(i).name.equals("babypink")) {
                    mCurrentFilterIndex = i;
                }
            }

            if (mCurrentFilterIndex > 0) {
                mCurrentFilterGroupIndex = 0;
                mFilterAdapters.get("filter_portrait").setSelectedPosition(mCurrentFilterIndex);
                mCameraDisplay.setFilterStyle(mFilterLists.get("filter_portrait").get(mCurrentFilterIndex).model);
                mCameraDisplay.enableFilter(true);

                ((ImageView) findViewById(R.id.iv_filter_group_portrait)).setImageDrawable(getResources().getDrawable(R.drawable.icon_portrait_selected));
                ((TextView) findViewById(R.id.tv_filter_group_portrait)).setTextColor(Color.parseColor("#c460e1"));
                mFilterAdapters.get("filter_portrait").notifyDataSetChanged();
            }
        }

        SharedPreferences sharedPreferences = getSharedPreferences("senseme",
                Activity.MODE_PRIVATE);
        boolean isFirstLoad = sharedPreferences.getBoolean("isFirstLoad", true);

        if (isFirstLoad) {
            SharedPreferences mySharedPreferences = getSharedPreferences("senseme", Activity.MODE_PRIVATE);
            SharedPreferences.Editor editor = mySharedPreferences.edit();
            editor.putBoolean("isFirstLoad", false);
            editor.commit();

            new CommomDialog(this, R.style.dialog, "点击屏幕底部按钮可拍照，长按可录制短视频！", new CommomDialog.OnCloseListener() {
                @Override
                public void onClick(Dialog dialog, boolean confirm) {
                    if (confirm) {
                        dialog.dismiss();
                    }
                }
            }).show();
        }

        mSensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        List<Sensor> sensors = mSensorManager.getSensorList(Sensor.TYPE_ALL);
        //todo 判断是否存在rotation vector sensor
        mRotation = mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
    }

    private void initView() {
        //copy model file to sdcard
        FileUtils.copyModelFiles(this);

        ((Switch) findViewById(R.id.testSwitch0)).setOnClickListener(this);
        ((Switch) findViewById(R.id.testSwitch1)).setOnClickListener(this);
        ((Switch) findViewById(R.id.testSwitch2)).setOnClickListener(this);

        mAccelerometer = new Accelerometer(getApplicationContext());
        GLSurfaceView glSurfaceView = (GLSurfaceView) findViewById(R.id.id_gl_sv);
        mSurfaceViewOverlap = (SurfaceView) findViewById(R.id.surfaceViewOverlap);
        mPreviewFrameLayout = (FrameLayout) findViewById(R.id.id_preview_layout);
        mMeteringArea = new ImageView(this);
        mMeteringArea.setImageResource(R.drawable.choose);
        FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(80, 80);
        mMeteringArea.setLayoutParams(layoutParams);
        mPreviewFrameLayout.addView(mMeteringArea);
        mMeteringArea.setVisibility(View.INVISIBLE);

        //单输入使用
        //mCameraDisplay = new CameraDisplaySingleInput(getApplicationContext(), mChangePreviewSizeListener, glSurfaceView);

        //单输入多线程
        //mCameraDisplay = new CameraDisplaySingleInputMultiThread(getApplicationContext(), mChangePreviewSizeListener, glSurfaceView);

        //双输入使用
//        mCameraDisplay = new CameraDisplayDoubleInput(getApplicationContext(), mChangePreviewSizeListener, glSurfaceView);

        //双输入多线程
        mCameraDisplay = new CameraDisplayDoubleInputMultithread(getApplicationContext(), mChangePreviewSizeListener, glSurfaceView);

        mCameraDisplay.setHandler(mHandler);

        mIndicatorSeekbar = (IndicatorSeekBar) findViewById(R.id.beauty_item_seekbar);
        mIndicatorSeekbar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    if (checkMicroType()) {
                        mIndicatorSeekbar.updateTextview(STUtils.convertToDisplay(progress));
                        mCameraDisplay.setBeautyParam(mCurrentBeautyIndex, (float) STUtils.convertToDisplay(progress) / 100f);
                        mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).setProgress(STUtils.convertToDisplay(progress));
                    } else {
                        mIndicatorSeekbar.updateTextview(progress);
                        mCameraDisplay.setBeautyParam(mCurrentBeautyIndex, (float) progress / 100f);
                        mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).setProgress(progress);
                    }
                    mBeautyItemAdapters.get(mBeautyOption.get(mBeautyOptionsPosition)).notifyItemChanged(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition));
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        mBeautyBaseRecycleView = (RecyclerView) findViewById(R.id.rv_beauty_base);
        LinearLayoutManager ms = new LinearLayoutManager(this);
        ms.setOrientation(LinearLayoutManager.HORIZONTAL);
        mBeautyBaseRecycleView.setLayoutManager(ms);
        mBeautyBaseRecycleView.addItemDecoration(new BeautyItemDecoration(STUtils.dip2px(this, 15)));

        ArrayList mBeautyBaseItem = new ArrayList<BeautyItem>();
        mBeautyBaseItem.add(new BeautyItem("美白", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_whiten_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_whiten_selected)));
        mBeautyBaseItem.add(new BeautyItem("红润", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_redden_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_redden_selected)));
        mBeautyBaseItem.add(new BeautyItem("磨皮", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_smooth_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_smooth_selected)));
        mBeautyBaseItem.add(new BeautyItem("去高光", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_dehighlight_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_dehighlight_selected)));

        ((BeautyItem) mBeautyBaseItem.get(0)).setProgress((int) (mBeautifyParams[2] * 100));
        ((BeautyItem) mBeautyBaseItem.get(1)).setProgress((int) (mBeautifyParams[0] * 100));
        ((BeautyItem) mBeautyBaseItem.get(2)).setProgress((int) (mBeautifyParams[1] * 100));
        ((BeautyItem) mBeautyBaseItem.get(3)).setProgress((int) (mBeautifyParams[8] * 100));

        mIndicatorSeekbar.getSeekBar().setProgress((int) (mBeautifyParams[2] * 100));
        mIndicatorSeekbar.updateTextview((int) (mBeautifyParams[2] * 100));

        mBeautylists.put("baseBeauty", mBeautyBaseItem);
        mBeautyBaseAdapter = new BeautyItemAdapter(this, mBeautyBaseItem);
        mBeautyItemAdapters.put("baseBeauty", mBeautyBaseAdapter);
        mBeautyOption.put(0, "baseBeauty");
        mBeautyBaseRecycleView.setAdapter(mBeautyBaseAdapter);

        ArrayList mProfessionalBeautyItem = new ArrayList<>();
        mProfessionalBeautyItem.add(new BeautyItem("瘦脸", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_shrink_face_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_shrink_face_selected)));
        mProfessionalBeautyItem.add(new BeautyItem("大眼", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_enlargeeye_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_enlargeeye_selected)));
        mProfessionalBeautyItem.add(new BeautyItem("小脸", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_small_face_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_small_face_selected)));
        mProfessionalBeautyItem.add(new BeautyItem("窄脸", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_narrow_face_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_narrow_face_selected)));
        mProfessionalBeautyItem.add(new BeautyItem("圆眼", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_round_eye_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_round_eye_selected)));

        ((BeautyItem) mProfessionalBeautyItem.get(0)).setProgress((int) (mBeautifyParams[4] * 100));
        ((BeautyItem) mProfessionalBeautyItem.get(1)).setProgress((int) (mBeautifyParams[3] * 100));
        ((BeautyItem) mProfessionalBeautyItem.get(2)).setProgress((int) (mBeautifyParams[5] * 100));
        ((BeautyItem) mProfessionalBeautyItem.get(3)).setProgress((int) (mBeautifyParams[9] * 100));
        ((BeautyItem) mProfessionalBeautyItem.get(4)).setProgress((int) (mBeautifyParams[26] * 100));

        mBeautylists.put("professionalBeauty", mProfessionalBeautyItem);
        mBeautyProfessionalAdapter = new BeautyItemAdapter(this, mProfessionalBeautyItem);
        mBeautyItemAdapters.put("professionalBeauty", mBeautyProfessionalAdapter);
        mBeautyOption.put(1, "professionalBeauty");

        ArrayList mMicroBeautyItem = new ArrayList<>();
        mMicroBeautyItem.add(new BeautyItem("瘦脸型", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_thin_face_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_thin_face_selected)));
        mMicroBeautyItem.add(new BeautyItem("下巴", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_chin_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_chin_selected)));
        mMicroBeautyItem.add(new BeautyItem("额头", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_forehead_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_forehead_selected)));
        mMicroBeautyItem.add(new BeautyItem("苹果肌", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_apple_musle_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_apple_musle_selected)));
        mMicroBeautyItem.add(new BeautyItem("瘦鼻翼", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_thin_nose_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_thin_nose_selected)));
        mMicroBeautyItem.add(new BeautyItem("长鼻", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_long_nose_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_long_nose_selected)));
        mMicroBeautyItem.add(new BeautyItem("侧脸隆鼻", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_profile_rhinoplasty_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_profile_rhinoplasty_selected)));
        mMicroBeautyItem.add(new BeautyItem("嘴型", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_mouth_type_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_mouth_type_selected)));
        mMicroBeautyItem.add(new BeautyItem("缩人中", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_philtrum_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_philtrum_selected)));
        mMicroBeautyItem.add(new BeautyItem("眼距", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_eye_distance_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_eye_distance_selected)));
        mMicroBeautyItem.add(new BeautyItem("眼睛角度", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_eye_angle_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_eye_angle_selected)));
        mMicroBeautyItem.add(new BeautyItem("开眼角", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_open_canthus_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_open_canthus_selected)));
        mMicroBeautyItem.add(new BeautyItem("亮眼", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_bright_eye_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_bright_eye_selected)));
        mMicroBeautyItem.add(new BeautyItem("祛黑眼圈", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_remove_dark_circles_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_remove_dark_circles_selected)));
        mMicroBeautyItem.add(new BeautyItem("祛法令纹", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_remove_nasolabial_folds_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_remove_nasolabial_folds_selected)));
        mMicroBeautyItem.add(new BeautyItem("白牙", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_white_teeth_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_white_teeth_selected)));

        for(int i = 0; i < 16; i++){
            ((BeautyItem)mMicroBeautyItem.get(i)).setProgress((int)(mBeautifyParams[i+10]* 100));
        }

        mBeautylists.put("microBeauty", mMicroBeautyItem);
        mMicroAdapter = new BeautyItemAdapter(this, mMicroBeautyItem);
        mBeautyItemAdapters.put("microBeauty", mMicroAdapter);
        mBeautyOption.put(2, "microBeauty");

        mMakeupOptionsRecycleView = (RecyclerView) findViewById(R.id.rv_makeup_icons);
        mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
        mMakeupOptionsRecycleView.addItemDecoration(new SpaceItemDecoration(0));

        mMakeupLists.put("makeup_lip", FileUtils.getMakeupFiles(this, "makeup_lip"));
        mMakeupLists.put("makeup_highlight", FileUtils.getMakeupFiles(this, "makeup_highlight"));
        mMakeupLists.put("makeup_blush", FileUtils.getMakeupFiles(this, "makeup_blush"));
        mMakeupLists.put("makeup_brow", FileUtils.getMakeupFiles(this, "makeup_brow"));
        mMakeupLists.put("makeup_eye", FileUtils.getMakeupFiles(this, "makeup_eye"));
        mMakeupLists.put("makeup_eyeliner", FileUtils.getMakeupFiles(this, "makeup_eyeliner"));
        mMakeupLists.put("makeup_eyelash", FileUtils.getMakeupFiles(this, "makeup_eyelash"));
        mMakeupLists.put("makeup_eyeball", FileUtils.getMakeupFiles(this, "makeup_eyeball"));

        mMakeupAdapters.put("makeup_lip", new MakeupAdapter(mMakeupLists.get("makeup_lip"), this));
        mMakeupAdapters.put("makeup_highlight", new MakeupAdapter(mMakeupLists.get("makeup_highlight"), this));
        mMakeupAdapters.put("makeup_blush", new MakeupAdapter(mMakeupLists.get("makeup_blush"), this));
        mMakeupAdapters.put("makeup_brow", new MakeupAdapter(mMakeupLists.get("makeup_brow"), this));
        mMakeupAdapters.put("makeup_eye", new MakeupAdapter(mMakeupLists.get("makeup_eye"), this));
        mMakeupAdapters.put("makeup_eyeliner", new MakeupAdapter(mMakeupLists.get("makeup_eyeliner"), this));
        mMakeupAdapters.put("makeup_eyelash", new MakeupAdapter(mMakeupLists.get("makeup_eyelash"), this));
        mMakeupAdapters.put("makeup_eyeball", new MakeupAdapter(mMakeupLists.get("makeup_eyeball"), this));

        mMakeupOptionIndex.put("makeup_lip", 3);
        mMakeupOptionIndex.put("makeup_highlight", 4);
        mMakeupOptionIndex.put("makeup_blush", 2);
        mMakeupOptionIndex.put("makeup_brow", 5);
        mMakeupOptionIndex.put("makeup_eye", 1);
        mMakeupOptionIndex.put("makeup_eyeliner", 6);
        mMakeupOptionIndex.put("makeup_eyelash", 7);
        mMakeupOptionIndex.put("makeup_eyeball", 8);

        for(int i = 0; i < Constants.MAKEUP_TYPE_COUNT; i++){
            mMakeupOptionSelectedIndex.put(i , 0);
            mMakeupStrength.put(i, 80);
        }

        mMakeupIconsRelativeLayout = (RelativeLayout) findViewById(R.id.rl_makeup_icons);
        mMakeupGroupRelativeLayout = ((RelativeLayout) findViewById(R.id.rl_makeup_groups));
        mMakeupGroupLip = (LinearLayout) findViewById(R.id.ll_makeup_group_lip);
        mMakeupGroupLip.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.VISIBLE);
                mCurrentMakeupGroupIndex = Constants.ST_MAKEUP_LIP;
                if(mMakeupOptionSelectedIndex.get(3) != 0){
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_lip_selected));
                }else {
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_lip_unselected));
                }
                mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mMakeupOptionsRecycleView.setAdapter(mMakeupAdapters.get("makeup_lip"));
                mMakeupGroupName.setText("口红");
            }
        });

        mMakeupGroupCheeks = (LinearLayout) findViewById(R.id.ll_makeup_group_cheeks);
        mMakeupGroupCheeks.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.VISIBLE);
                mCurrentMakeupGroupIndex = Constants.ST_MAKEUP_BLUSH;
                if(mMakeupOptionSelectedIndex.get(2) != 0){
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_cheeks_selected));
                }else {
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_cheeks_unselected));
                }
                mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mMakeupOptionsRecycleView.setAdapter(mMakeupAdapters.get("makeup_blush"));
                mMakeupGroupName.setText("腮红");
            }
        });

        mMakeupGroupFace = (LinearLayout) findViewById(R.id.ll_makeup_group_face);
        mMakeupGroupFace.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.VISIBLE);
                mCurrentMakeupGroupIndex = Constants.ST_MAKEUP_HIGHLIGHT;
                if(mMakeupOptionSelectedIndex.get(4) != 0){
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_face_selected));
                }else {
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_face_unselected));
                }

                mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mMakeupOptionsRecycleView.setAdapter(mMakeupAdapters.get("makeup_highlight"));
                mMakeupGroupName.setText("修容");
            }
        });

        mMakeupGroupBrow = (LinearLayout) findViewById(R.id.ll_makeup_group_brow);
        mMakeupGroupBrow.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.VISIBLE);
                mCurrentMakeupGroupIndex = Constants.ST_MAKEUP_BROW;
                if(mMakeupOptionSelectedIndex.get(5) != 0){
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_brow_selected));
                }else {
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_brow_unselected));
                }
                mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mMakeupOptionsRecycleView.setAdapter(mMakeupAdapters.get("makeup_brow"));
                mMakeupGroupName.setText("眉毛");
            }
        });

        mMakeupGroupEye = (LinearLayout) findViewById(R.id.ll_makeup_group_eye);
        mMakeupGroupEye.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.VISIBLE);
                mCurrentMakeupGroupIndex = Constants.ST_MAKEUP_EYE;
                if(mMakeupOptionSelectedIndex.get(1) != 0){
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eye_selected));
                }else {
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eye_unselected));
                }
                mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mMakeupOptionsRecycleView.setAdapter(mMakeupAdapters.get("makeup_eye"));
                mMakeupGroupName.setText("眼影");
            }
        });

        mMakeupGroupEyeLiner = (LinearLayout) findViewById(R.id.ll_makeup_group_eyeliner);
        mMakeupGroupEyeLiner.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.VISIBLE);
                mCurrentMakeupGroupIndex = Constants.ST_MAKEUP_EYELINER;
                if(mMakeupOptionSelectedIndex.get(6) != 0){
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeliner_selected));
                }else {
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeline_unselected));
                }
                mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mMakeupOptionsRecycleView.setAdapter(mMakeupAdapters.get("makeup_eyeliner"));
                mMakeupGroupName.setText("眼线");
            }
        });

        mMakeupGroupEyeLash = (LinearLayout) findViewById(R.id.ll_makeup_group_eyelash);
        mMakeupGroupEyeLash.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.VISIBLE);
                mCurrentMakeupGroupIndex = Constants.ST_MAKEUP_EYELASH;
                if(mMakeupOptionSelectedIndex.get(7) != 0){
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyelash_selected));
                }else {
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyelash_unselected));
                }
                mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mMakeupOptionsRecycleView.setAdapter(mMakeupAdapters.get("makeup_eyelash"));
                mMakeupGroupName.setText("眼睫毛");
            }
        });

        mMakeupGroupEyeBall = (LinearLayout) findViewById(R.id.ll_makeup_group_eyeball);
        mMakeupGroupEyeBall.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.VISIBLE);
                mCurrentMakeupGroupIndex = Constants.ST_MAKEUP_EYEBALL;
                if(mMakeupOptionSelectedIndex.get(8) != 0){
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeball_selected));
                }else {
                    mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeball_unselected));
                }
                mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mMakeupOptionsRecycleView.setAdapter(mMakeupAdapters.get("makeup_eyeball"));
                mMakeupGroupName.setText("美瞳");
            }
        });

        mMakeupGroupBack = (ImageView) findViewById(R.id.iv_makeup_group);
        mMakeupGroupBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupRelativeLayout.setVisibility(View.VISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mFilterStrengthLayout.setVisibility(View.INVISIBLE);

                if(mMakeupOptionSelectedIndex.get(Constants.ST_MAKEUP_LIP) != 0){
                    ((ImageView)findViewById(R.id.iv_makeup_group_lip)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_lip_selected));
                    ((TextView)findViewById(R.id.tv_makeup_group_lip)).setTextColor(Color.parseColor("#c460e1"));
                }else{
                    ((ImageView)findViewById(R.id.iv_makeup_group_lip)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_lip_unselected));
                    ((TextView)findViewById(R.id.tv_makeup_group_lip)).setTextColor(Color.parseColor("#ffffff"));
                }
                if(mMakeupOptionSelectedIndex.get(Constants.ST_MAKEUP_BLUSH) != 0){
                    ((ImageView)findViewById(R.id.iv_makeup_group_cheeks)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_cheeks_selected));
                    ((TextView)findViewById(R.id.tv_makeup_group_cheeks)).setTextColor(Color.parseColor("#c460e1"));
                }else{
                    ((ImageView)findViewById(R.id.iv_makeup_group_cheeks)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_cheeks_unselected));
                    ((TextView)findViewById(R.id.tv_makeup_group_cheeks)).setTextColor(Color.parseColor("#ffffff"));
                }
                if(mMakeupOptionSelectedIndex.get(Constants.ST_MAKEUP_HIGHLIGHT) != 0){
                    ((ImageView)findViewById(R.id.iv_makeup_group_face)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_face_selected));
                    ((TextView)findViewById(R.id.tv_makeup_group_face)).setTextColor(Color.parseColor("#c460e1"));
                }else{
                    ((ImageView)findViewById(R.id.iv_makeup_group_face)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_face_unselected));
                    ((TextView)findViewById(R.id.tv_makeup_group_face)).setTextColor(Color.parseColor("#ffffff"));
                }
                if(mMakeupOptionSelectedIndex.get(Constants.ST_MAKEUP_BROW) != 0){
                    ((ImageView)findViewById(R.id.iv_makeup_group_brow)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_brow_selected));
                    ((TextView)findViewById(R.id.tv_makeup_group_brow)).setTextColor(Color.parseColor("#c460e1"));
                }else{
                    ((ImageView)findViewById(R.id.iv_makeup_group_brow)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_brow_unselected));
                    ((TextView)findViewById(R.id.tv_makeup_group_brow)).setTextColor(Color.parseColor("#ffffff"));
                }
                if(mMakeupOptionSelectedIndex.get(Constants.ST_MAKEUP_EYE) != 0){
                    ((ImageView)findViewById(R.id.iv_makeup_group_eye)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eye_selected));
                    ((TextView)findViewById(R.id.tv_makeup_group_eye)).setTextColor(Color.parseColor("#c460e1"));
                }else{
                    ((ImageView)findViewById(R.id.iv_makeup_group_eye)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eye_unselected));
                    ((TextView)findViewById(R.id.tv_makeup_group_eye)).setTextColor(Color.parseColor("#ffffff"));
                }
                if(mMakeupOptionSelectedIndex.get(Constants.ST_MAKEUP_EYELINER) != 0){
                    ((ImageView)findViewById(R.id.iv_makeup_group_eyeliner)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeliner_selected));
                    ((TextView)findViewById(R.id.tv_makeup_group_eyeliner)).setTextColor(Color.parseColor("#c460e1"));
                }else{
                    ((ImageView)findViewById(R.id.iv_makeup_group_eyeliner)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeline_unselected));
                    ((TextView)findViewById(R.id.tv_makeup_group_eyeliner)).setTextColor(Color.parseColor("#ffffff"));
                }
                if(mMakeupOptionSelectedIndex.get(Constants.ST_MAKEUP_EYELASH) != 0){
                    ((ImageView)findViewById(R.id.iv_makeup_group_eyelash)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyelash_selected));
                    ((TextView)findViewById(R.id.tv_makeup_group_eyelash)).setTextColor(Color.parseColor("#c460e1"));
                }else{
                    ((ImageView)findViewById(R.id.iv_makeup_group_eyelash)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyelash_unselected));
                    ((TextView)findViewById(R.id.tv_makeup_group_eyelash)).setTextColor(Color.parseColor("#ffffff"));
                }
                if(mMakeupOptionSelectedIndex.get(Constants.ST_MAKEUP_EYEBALL) != 0){
                    ((ImageView)findViewById(R.id.iv_makeup_group_eyeball)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeball_selected));
                    ((TextView)findViewById(R.id.tv_makeup_group_eyeball)).setTextColor(Color.parseColor("#c460e1"));
                }else{
                    ((ImageView)findViewById(R.id.iv_makeup_group_eyeball)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeball_unselected));
                    ((TextView)findViewById(R.id.tv_makeup_group_eyeball)).setTextColor(Color.parseColor("#ffffff"));
                }
            }
        });
        mMakeupGroupName = (TextView) findViewById(R.id.tv_makeup_group);

        ArrayList mAdjustBeautyItem = new ArrayList<>();
        mAdjustBeautyItem.add(new BeautyItem("对比度", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_contrast_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_contrast_selected)));
        mAdjustBeautyItem.add(new BeautyItem("饱和度", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_saturation_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_saturation_selected)));
        ((BeautyItem) mAdjustBeautyItem.get(0)).setProgress((int) (mBeautifyParams[6] * 100));
        ((BeautyItem) mAdjustBeautyItem.get(1)).setProgress((int) (mBeautifyParams[7] * 100));
        mBeautylists.put("adjustBeauty", mAdjustBeautyItem);
        mAdjustAdapter = new BeautyItemAdapter(this, mAdjustBeautyItem);
        mBeautyItemAdapters.put("adjustBeauty", mAdjustAdapter);
        mBeautyOption.put(5, "adjustBeauty");

        mBeautyOptionSelectedIndex.put(0, 0);
        mBeautyOptionSelectedIndex.put(1, 0);
        mBeautyOptionSelectedIndex.put(2, 0);
        mBeautyOptionSelectedIndex.put(5, 0);

        mStickerOptionsRecycleView = (RecyclerView) findViewById(R.id.rv_sticker_options);
        mStickerOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
        mStickerOptionsRecycleView.addItemDecoration(new SpaceItemDecoration(0));

        mStickersRecycleView = (RecyclerView) findViewById(R.id.rv_sticker_icons);
        mStickersRecycleView.setLayoutManager(new GridLayoutManager(this, 6));
        mStickersRecycleView.addItemDecoration(new SpaceItemDecoration(0));

        mFilterOptionsRecycleView = (RecyclerView) findViewById(R.id.rv_filter_icons);
        mFilterOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
        mFilterOptionsRecycleView.addItemDecoration(new SpaceItemDecoration(0));
        mNewStickers = FileUtils.getStickerFiles(this, "newEngine");
        //new
        //使用本地模型加载
        mStickerOptionsList.add(0, new StickerOptionsItem("sticker_new_engine", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_local_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_local_selected)));
        //2d
        mStickerOptionsList.add(1, new StickerOptionsItem(GROUP_2D, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_2d_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_2d_selected)));
        //3d
        mStickerOptionsList.add(2, new StickerOptionsItem(GROUP_3D, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_3d_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_3d_selected)));
        //手势贴纸
        mStickerOptionsList.add(3, new StickerOptionsItem(GROUP_HAND, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_hand_action_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_hand_action_selected)));
        //背景贴纸
        mStickerOptionsList.add(4, new StickerOptionsItem(GROUP_BG, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_bg_segment_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_bg_segment_selected)));
        //脸部变形贴纸
        mStickerOptionsList.add(5, new StickerOptionsItem(GROUP_FACE, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_dedormation_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_dedormation_selected)));
        //avatar
        mStickerOptionsList.add(6, new StickerOptionsItem(GROUP_AVATAR, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_avatar_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_avatar_selected)));
        //美妆贴纸
        mStickerOptionsList.add(7, new StickerOptionsItem(GROUP_BEAUTY, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_face_morph_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_face_morph_selected)));
        //粒子贴纸
        mStickerOptionsList.add(8, new StickerOptionsItem(GROUP_PARTICLE, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.particles_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.particles_selected)));
        //通用物体跟踪
        mStickerOptionsList.add(9, new StickerOptionsItem("object_track", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.object_track_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.object_track_selected)));

        mNativeStickerAdapters.put("sticker_new_engine", new NativeStickerAdapter(mNewStickers, this));

        mStickersRecycleView.setAdapter(mNativeStickerAdapters.get("sticker_new_engine"));
        mNativeStickerAdapters.get("sticker_new_engine").notifyDataSetChanged();
        initNativeStickerAdapter("sticker_new_engine", 0);
        mStickerOptionsAdapter = new StickerOptionsAdapter(mStickerOptionsList, this);
        mStickerOptionsAdapter.setSelectedPosition(0);
        mStickerOptionsAdapter.notifyDataSetChanged();

        findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));

        mFilterAndBeautyOptionView = (RelativeLayout) findViewById(R.id.rv_beauty_and_filter_options);

        mBeautyOptionsRecycleView = (RecyclerView) findViewById(R.id.rv_beauty_options);
        mBeautyOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
        mBeautyOptionsRecycleView.addItemDecoration(new SpaceItemDecoration(0));

        mBeautyOptionsList = new ArrayList<>();
        mBeautyOptionsList.add(0, new BeautyOptionsItem("基础美颜"));
        mBeautyOptionsList.add(1, new BeautyOptionsItem("美形"));
        mBeautyOptionsList.add(2, new BeautyOptionsItem("微整形"));
        mBeautyOptionsList.add(3, new BeautyOptionsItem("美妆"));
        mBeautyOptionsList.add(4, new BeautyOptionsItem("滤镜"));
        mBeautyOptionsList.add(5, new BeautyOptionsItem("调整"));

        mBeautyOptionsAdapter = new BeautyOptionsAdapter(mBeautyOptionsList, this);
        mBeautyOptionsRecycleView.setAdapter(mBeautyOptionsAdapter);

        mFilterLists.put("filter_portrait", FileUtils.getFilterFiles(this, "filter_portrait"));
        mFilterLists.put("filter_scenery", FileUtils.getFilterFiles(this, "filter_scenery"));
        mFilterLists.put("filter_still_life", FileUtils.getFilterFiles(this, "filter_still_life"));
        mFilterLists.put("filter_food", FileUtils.getFilterFiles(this, "filter_food"));

        mFilterAdapters.put("filter_portrait", new FilterAdapter(mFilterLists.get("filter_portrait"), this));
        mFilterAdapters.put("filter_scenery", new FilterAdapter(mFilterLists.get("filter_scenery"), this));
        mFilterAdapters.put("filter_still_life", new FilterAdapter(mFilterLists.get("filter_still_life"), this));
        mFilterAdapters.put("filter_food", new FilterAdapter(mFilterLists.get("filter_food"), this));

        mFilterIconsRelativeLayout = (RelativeLayout) findViewById(R.id.rl_filter_icons);
        mFilterGroupsLinearLayout = (LinearLayout) findViewById(R.id.ll_filter_groups);
        mFilterGroupPortrait = (LinearLayout) findViewById(R.id.ll_filter_group_portrait);
        mFilterGroupPortrait.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                mFilterIconsRelativeLayout.setVisibility(View.VISIBLE);

                if (mCurrentFilterGroupIndex == 0 && mCurrentFilterIndex != -1) {
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                }

                mFilterOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mFilterOptionsRecycleView.setAdapter(mFilterAdapters.get("filter_portrait"));
                mFilterGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.icon_portrait_selected));
                mFilterGroupName.setText("人像");
            }
        });
        mFilterGroupScenery = (LinearLayout) findViewById(R.id.ll_filter_group_scenery);
        mFilterGroupScenery.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                mFilterIconsRelativeLayout.setVisibility(View.VISIBLE);

                if (mCurrentFilterGroupIndex == 1 && mCurrentFilterIndex != -1) {
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                }

                mFilterOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mFilterOptionsRecycleView.setAdapter(mFilterAdapters.get("filter_scenery"));
                mFilterGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.icon_scenery_selected));
                mFilterGroupName.setText("风景");
            }
        });
        mFilterGroupStillLife = (LinearLayout) findViewById(R.id.ll_filter_group_still_life);
        mFilterGroupStillLife.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                mFilterIconsRelativeLayout.setVisibility(View.VISIBLE);

                if (mCurrentFilterGroupIndex == 2 && mCurrentFilterIndex != -1) {
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                }

                mFilterOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mFilterOptionsRecycleView.setAdapter(mFilterAdapters.get("filter_still_life"));
                mFilterGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.icon_still_life_selected));
                mFilterGroupName.setText("静物");
            }
        });
        mFilterGroupFood = (LinearLayout) findViewById(R.id.ll_filter_group_food);
        mFilterGroupFood.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                mFilterIconsRelativeLayout.setVisibility(View.VISIBLE);

                if (mCurrentFilterGroupIndex == 3 && mCurrentFilterIndex != -1) {
                    mFilterStrengthLayout.setVisibility(View.VISIBLE);
                }

                mFilterOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
                mFilterOptionsRecycleView.setAdapter(mFilterAdapters.get("filter_food"));
                mFilterGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.icon_food_selected));
                mFilterGroupName.setText("食物");
            }
        });

        mFilterGroupBack = (ImageView) findViewById(R.id.iv_filter_group);
        mFilterGroupBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mFilterGroupsLinearLayout.setVisibility(View.VISIBLE);
                mFilterIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mFilterStrengthLayout.setVisibility(View.INVISIBLE);

                mShowOriginBtn3.setVisibility(View.VISIBLE);
            }
        });
        mFilterGroupName = (TextView) findViewById(R.id.tv_filter_group);
        mFilterStrengthText = (TextView) findViewById(R.id.tv_filter_strength);

        mFilterStrengthLayout = (RelativeLayout) findViewById(R.id.rv_filter_strength);
        mFilterStrengthBar = (SeekBar) findViewById(R.id.sb_filter_strength);
        mFilterStrengthBar.setProgress(65);
        mFilterStrengthText.setText("65");
        mFilterStrengthBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if(mBeautyOptionsPosition == 4){
                    mCameraDisplay.setFilterStrength((float) progress / 100);
                    mFilterStrengthText.setText(progress + "");
                }else if(mBeautyOptionsPosition == 3){
                    mCameraDisplay.setStrengthForType(mCurrentMakeupGroupIndex, (float)progress / 100);
                    mMakeupStrength.put(mCurrentMakeupGroupIndex, progress);
                    mFilterStrengthText.setText(progress+"");
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {
            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {
            }
        });
        mVerticalSeekBar = (VerticalSeekBar) findViewById(R.id.vertical_seekbar);
        mVerticalSeekBar.setProgress(50);
        mVerticalSeekBar.setHandler(mHandler);
        mVerticalSeekBar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                mCameraDisplay.setExposureCompensation(progress);
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });

        mStickerOptionsRecycleView.setAdapter(mStickerOptionsAdapter);

        mObjectList = FileUtils.getObjectList();
        mObjectAdapter = new ObjectAdapter(mObjectList, this);
        mObjectAdapter.setSelectedPosition(-1);

        mFilterOptionsRecycleView.setAdapter(mFilterAdapters.get("filter_portrait"));

        mSavingTv = (TextView) findViewById(R.id.tv_saving_image);
        mTipsLayout = (RelativeLayout) findViewById(R.id.tv_layout_tips);
        mAttributeText = (TextView) findViewById(R.id.tv_face_attribute);
        mAttributeText.setVisibility(View.VISIBLE);
        mTipsTextView = (TextView) findViewById(R.id.tv_text_tips);
        mTipsImageView = (ImageView) findViewById(R.id.iv_image_tips);
        mTipsLayout.setVisibility(View.GONE);

        mBeautyOptionsSwitch = (LinearLayout) findViewById(R.id.ll_beauty_options_switch);
        mBeautyOptionsSwitch.setOnClickListener(this);
        mFilterIcons = (RecyclerView) findViewById(R.id.rv_filter_icons);

        mBaseBeautyOptions = (LinearLayout) findViewById(R.id.ll_base_beauty_options);
        mBaseBeautyOptions.setOnClickListener(null);
        mIsBeautyOptionsOpen = false;

        mStickerOptionsSwitch = (LinearLayout) findViewById(R.id.ll_sticker_options_switch);
        mStickerOptionsSwitch.setOnClickListener(this);
        mStickerOptions = (RelativeLayout) findViewById(R.id.rl_sticker_options);
        mStickerIcons = (RecyclerView) findViewById(R.id.rv_sticker_icons);
        mIsStickerOptionsOpen = false;

        mSettingOptionsSwitch = (ImageView) findViewById(R.id.iv_setting_options_switch);
        mSettingOptionsSwitch.setOnClickListener(this);
        mSettingOptions = (RelativeLayout) findViewById(R.id.rl_setting_options);
        mIsSettingOptionsOpen = false;

        mSelectionPicture = (ImageView) findViewById(R.id.iv_mode_picture);
        mSelectionPicture.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
                startActivity(new Intent(getApplicationContext(), LoadImageActivity.class));
            }
        });

        findViewById(R.id.tv_cancel).setVisibility(View.INVISIBLE);
        findViewById(R.id.tv_capture).setVisibility(View.INVISIBLE);

        mSmallPreviewSize = (TextView) findViewById(R.id.tv_small_size_unselected);
        mSmallPreviewSize.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (mCameraDisplay != null && !mCameraDisplay.isChangingPreviewSize()) {
                    mCameraDisplay.changePreviewSize(0);
                    findViewById(R.id.tv_small_size_selected).setVisibility(View.VISIBLE);
                    findViewById(R.id.tv_small_size_unselected).setVisibility(View.INVISIBLE);
                    findViewById(R.id.tv_large_size_selected).setVisibility(View.INVISIBLE);
                    findViewById(R.id.tv_large_size_unselected).setVisibility(View.VISIBLE);

                    mSmallPreviewSize.setClickable(false);
                    mLargePreviewSize.setClickable(true);
                }
            }
        });
        mLargePreviewSize = (TextView) findViewById(R.id.tv_large_size_unselected);
        mLargePreviewSize.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (mCameraDisplay != null && !mCameraDisplay.isChangingPreviewSize()) {
                    mCameraDisplay.changePreviewSize(1);
                    findViewById(R.id.tv_small_size_selected).setVisibility(View.INVISIBLE);
                    findViewById(R.id.tv_small_size_unselected).setVisibility(View.VISIBLE);
                    findViewById(R.id.tv_large_size_selected).setVisibility(View.VISIBLE);
                    findViewById(R.id.tv_large_size_unselected).setVisibility(View.INVISIBLE);

                    mSmallPreviewSize.setClickable(true);
                    mLargePreviewSize.setClickable(false);
                }
            }
        });

        mFpsInfo = (LinearLayout) findViewById(R.id.ll_fps_info);
        mFpsInfo.setVisibility(View.INVISIBLE);
        mPerformanceInfoSwitch = (Switch) findViewById(R.id.sw_performance_switch);
        mPerformanceInfoSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

            @Override
            public void onCheckedChanged(CompoundButton buttonView,
                                         boolean isChecked) {
                // TODO Auto-generated method stub
                if (isChecked) {
                    mFpsInfo.setVisibility(View.VISIBLE);
                    if(mCameraDisplay != null){
                        mCameraDisplay.enableFaceDistance(true);
                    }
                } else {
                    mFpsInfo.setVisibility(View.INVISIBLE);
                    if(mCameraDisplay != null){
                        mCameraDisplay.enableFaceDistance(false);
                    }
                }
            }
        });

        mSelectOptions = (LinearLayout) findViewById(R.id.ll_select_options);
        mSelectOptions.setBackgroundColor(Color.parseColor("#00000000"));
        mCaptureButton = (Button) findViewById(R.id.btn_capture_picture);

        findViewById(R.id.rl_provisions_btn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                findViewById(R.id.rl_provisions).setVisibility(View.VISIBLE);
                ((WebView) findViewById(R.id.wv_docs)).loadUrl("file:///android_asset/SenseME_Provisions_v1.0.html");
                ((WebView) findViewById(R.id.wv_docs)).getSettings().setTextSize(WebSettings.TextSize.SMALLER);
            }
        });

        findViewById(R.id.tv_back_btn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                findViewById(R.id.rl_provisions).setVisibility(View.GONE);
            }
        });

        mResetTextView = (TextView) findViewById(R.id.reset);
    }

    private void initEvents() {
        mSurfaceViewOverlap.setZOrderOnTop(true);
        mSurfaceViewOverlap.setZOrderMediaOverlay(true);
        mSurfaceViewOverlap.getHolder().setFormat(PixelFormat.TRANSLUCENT);

        mPaint = new Paint();
        mPaint.setColor(Color.rgb(240, 100, 100));
        int strokeWidth = 10;
        mPaint.setStrokeWidth(strokeWidth);
        mPaint.setStyle(Paint.Style.STROKE);

        initStickerTabListener();

        mFilterAdapters.get("filter_portrait").setClickFilterListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                resetFilterView();
                int position = Integer.parseInt(v.getTag().toString());
                mFilterAdapters.get("filter_portrait").setSelectedPosition(position);
                mCurrentFilterGroupIndex = 0;
                mCurrentFilterIndex = -1;

                if (position == 0) {
                    mCameraDisplay.enableFilter(false);
                } else {
                    mCameraDisplay.setFilterStyle(mFilterLists.get("filter_portrait").get(position).model);
                    mCameraDisplay.enableFilter(true);
                    mCurrentFilterIndex = position;

                    mFilterStrengthLayout.setVisibility(View.VISIBLE);

                    mShowOriginBtn1.setVisibility(View.INVISIBLE);
                    mShowOriginBtn2.setVisibility(View.INVISIBLE);
                    mShowOriginBtn3.setVisibility(View.VISIBLE);
                    ((ImageView) findViewById(R.id.iv_filter_group_portrait)).setImageDrawable(getResources().getDrawable(R.drawable.icon_portrait_selected));
                    ((TextView) findViewById(R.id.tv_filter_group_portrait)).setTextColor(Color.parseColor("#c460e1"));
                }

                mFilterAdapters.get("filter_portrait").notifyDataSetChanged();
            }
        });

        mFilterAdapters.get("filter_scenery").setClickFilterListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                resetFilterView();
                int position = Integer.parseInt(v.getTag().toString());
                mFilterAdapters.get("filter_scenery").setSelectedPosition(position);
                mCurrentFilterGroupIndex = 1;
                mCurrentFilterIndex = -1;

                if (position == 0) {
                    mCameraDisplay.enableFilter(false);
                } else {
                    mCameraDisplay.setFilterStyle(mFilterLists.get("filter_scenery").get(position).model);
                    mCameraDisplay.enableFilter(true);
                    mCurrentFilterIndex = position;

                    mFilterStrengthLayout.setVisibility(View.VISIBLE);

                    mShowOriginBtn1.setVisibility(View.INVISIBLE);
                    mShowOriginBtn2.setVisibility(View.INVISIBLE);
                    mShowOriginBtn3.setVisibility(View.VISIBLE);
                    ((ImageView) findViewById(R.id.iv_filter_group_scenery)).setImageDrawable(getResources().getDrawable(R.drawable.icon_scenery_selected));
                    ((TextView) findViewById(R.id.tv_filter_group_scenery)).setTextColor(Color.parseColor("#c460e1"));
                }

                mFilterAdapters.get("filter_scenery").notifyDataSetChanged();
            }
        });

        mFilterAdapters.get("filter_still_life").setClickFilterListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                resetFilterView();
                int position = Integer.parseInt(v.getTag().toString());
                mFilterAdapters.get("filter_still_life").setSelectedPosition(position);
                mCurrentFilterGroupIndex = 2;
                mCurrentFilterIndex = -1;

                if (position == 0) {
                    mCameraDisplay.enableFilter(false);
                } else {
                    mCameraDisplay.setFilterStyle(mFilterLists.get("filter_still_life").get(position).model);
                    mCameraDisplay.enableFilter(true);
                    mCurrentFilterIndex = position;

                    mFilterStrengthLayout.setVisibility(View.VISIBLE);

                    mShowOriginBtn1.setVisibility(View.INVISIBLE);
                    mShowOriginBtn2.setVisibility(View.INVISIBLE);
                    mShowOriginBtn3.setVisibility(View.VISIBLE);
                    ((ImageView) findViewById(R.id.iv_filter_group_still_life)).setImageDrawable(getResources().getDrawable(R.drawable.icon_still_life_selected));
                    ((TextView) findViewById(R.id.tv_filter_group_still_life)).setTextColor(Color.parseColor("#c460e1"));
                }

                mFilterAdapters.get("filter_still_life").notifyDataSetChanged();
            }
        });

        mFilterAdapters.get("filter_food").setClickFilterListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                resetFilterView();
                int position = Integer.parseInt(v.getTag().toString());
                mFilterAdapters.get("filter_food").setSelectedPosition(position);
                mCurrentFilterGroupIndex = 3;
                mCurrentFilterIndex = -1;

                if (position == 0) {
                    mCameraDisplay.enableFilter(false);
                } else {
                    mCameraDisplay.setFilterStyle(mFilterLists.get("filter_food").get(position).model);
                    mCameraDisplay.enableFilter(true);
                    mCurrentFilterIndex = position;

                    mFilterStrengthLayout.setVisibility(View.VISIBLE);

                    mShowOriginBtn1.setVisibility(View.INVISIBLE);
                    mShowOriginBtn2.setVisibility(View.INVISIBLE);
                    mShowOriginBtn3.setVisibility(View.VISIBLE);
                    ((ImageView) findViewById(R.id.iv_filter_group_food)).setImageDrawable(getResources().getDrawable(R.drawable.icon_food_selected));
                    ((TextView) findViewById(R.id.tv_filter_group_food)).setTextColor(Color.parseColor("#c460e1"));
                }

                mFilterAdapters.get("filter_food").notifyDataSetChanged();
            }
        });

        for(final Map.Entry<String, MakeupAdapter> entry: mMakeupAdapters.entrySet()){
            entry.getValue().setClickMakeupListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int position = Integer.parseInt(v.getTag().toString());

                    if(position == 0){
                        entry.getValue().setSelectedPosition(position);
                        mMakeupOptionSelectedIndex.put(mMakeupOptionIndex.get(entry.getKey()), position);

                        mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                        mCameraDisplay.removeMakeupByType(mCurrentMakeupGroupIndex);
                        updateMakeupOptions(mCurrentMakeupGroupIndex, false);
                    }else if(position == mMakeupOptionSelectedIndex.get(mMakeupOptionIndex.get(entry.getKey()))){
                        entry.getValue().setSelectedPosition(0);
                        mMakeupOptionSelectedIndex.put(mMakeupOptionIndex.get(entry.getKey()), 0);

                        mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                        mCameraDisplay.removeMakeupByType(mCurrentMakeupGroupIndex);
                        updateMakeupOptions(mCurrentMakeupGroupIndex, false);
                    }else {
                        entry.getValue().setSelectedPosition(position);
                        mMakeupOptionSelectedIndex.put(mMakeupOptionIndex.get(entry.getKey()), position);

                        mCameraDisplay.setMakeupForType(mCurrentMakeupGroupIndex, mMakeupLists.get(getMakeupNameOfType(mCurrentMakeupGroupIndex)).get(position).path);
                        mCameraDisplay.setStrengthForType(mCurrentMakeupGroupIndex, (float)mMakeupStrength.get(mCurrentMakeupGroupIndex)/100.f);
                        mFilterStrengthLayout.setVisibility(View.VISIBLE);
                        mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                        updateMakeupOptions(mCurrentMakeupGroupIndex, true);
                    }

                    if(checkMakeUpSelect()){
                        mCameraDisplay.enableMakeUp(true);
                    }else{
                        mCameraDisplay.enableMakeUp(false);
                    }
                    entry.getValue().notifyDataSetChanged();
                }
            });
        }

        mBeautyOptionsAdapter.setClickBeautyListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int position = Integer.parseInt(v.getTag().toString());
                mBeautyOptionsAdapter.setSelectedPosition(position);
                mBeautyOptionsPosition = position;
                mResetTextView.setVisibility(View.VISIBLE);
                mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                mBaseBeautyOptions.setVisibility(View.VISIBLE);
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                if (mBeautyOptionsPosition != 3 && mBeautyOptionsPosition != 4) {
                    calculateBeautyIndex(mBeautyOptionsPosition, mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition));
                    mIndicatorSeekbar.setVisibility(View.VISIBLE);
                    if (mBeautyOptionsPosition == 2 && mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition) != 0 && mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition) != 3) {
                        mIndicatorSeekbar.getSeekBar().setProgress(STUtils.convertToData(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(position)).getProgress()));
                    } else {
                        mIndicatorSeekbar.getSeekBar().setProgress(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(position)).getProgress());
                    }
                    mIndicatorSeekbar.updateTextview(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(position)).getProgress());
                } else {
                    mIndicatorSeekbar.setVisibility(View.INVISIBLE);
                }
                mFilterIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mShowOriginBtn3.setVisibility(View.VISIBLE);
                mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                if (position == 0) {
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("baseBeauty"));
                    mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_WHITEN_STRENGTH, (mBeautifyParams[2]));
                } else if (position == 1) {
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("professionalBeauty"));
                } else if (position == 2) {
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("microBeauty"));
                } else if (position == 3) {
                    mMakeupGroupRelativeLayout.setVisibility(View.VISIBLE);
                    mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                } else if (position == 4) {
                    mFilterGroupsLinearLayout.setVisibility(View.VISIBLE);
                    mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                } else if (position == 5) {
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("adjustBeauty"));
                }
                mBeautyOptionsAdapter.notifyDataSetChanged();
            }
        });

        mObjectAdapter.setClickObjectListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int position = Integer.parseInt(v.getTag().toString());

                if (mCurrentObjectIndex == position) {
                    mCurrentObjectIndex = -1;
                    mObjectAdapter.setSelectedPosition(-1);
                    mObjectAdapter.notifyDataSetChanged();
                    mCameraDisplay.enableObject(false);
                } else {
                    mObjectAdapter.setSelectedPosition(position);

                    mNeedObject = true;
                    mCameraDisplay.enableObject(true);
                    mGuideBitmap = BitmapFactory.decodeResource(mContext.getResources(), mObjectList.get(position).drawableID);
                    mCameraDisplay.resetIndexRect();

                    mObjectAdapter.notifyDataSetChanged();

                    mCurrentObjectIndex = position;
                }

            }
        });

        for (Map.Entry<String, BeautyItemAdapter> entry : mBeautyItemAdapters.entrySet()) {
            final BeautyItemAdapter adapter = entry.getValue();
            adapter.setClickBeautyListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int position = Integer.parseInt(v.getTag().toString());
                    adapter.setSelectedPosition(position);
                    mBeautyOptionSelectedIndex.put(mBeautyOptionsPosition, position);
                    if(checkMicroType()){
                        mIndicatorSeekbar.getSeekBar().setProgress(STUtils.convertToData(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(position).getProgress()));
                    } else {
                        mIndicatorSeekbar.getSeekBar().setProgress(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(position).getProgress());
                    }
                    mIndicatorSeekbar.updateTextview(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(position).getProgress());
                    calculateBeautyIndex(mBeautyOptionsPosition, position);
                    adapter.notifyDataSetChanged();
                }
            });
        }

        mShowOriginBtn1 = (TextView) findViewById(R.id.tv_show_origin1);
        mShowOriginBtn1.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                // TODO Auto-generated method stub
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    mCameraDisplay.setShowOriginal(true);
                    mCaptureButton.setEnabled(false);
                    findViewById(R.id.tv_change_camera).setEnabled(false);
                    mIsShowingOriginal = true;
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mCameraDisplay.setShowOriginal(false);
                    mCaptureButton.setEnabled(true);
                    findViewById(R.id.tv_change_camera).setEnabled(true);
                    mIsShowingOriginal = false;
                }
                return true;
            }
        });
        mShowOriginBtn1.setVisibility(View.VISIBLE);

        mShowOriginBtn2 = (TextView) findViewById(R.id.tv_show_origin2);
        mShowOriginBtn2.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                // TODO Auto-generated method stub
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    mCameraDisplay.setShowOriginal(true);
                    mCaptureButton.setEnabled(false);
                    findViewById(R.id.tv_change_camera).setEnabled(false);
                    mIsShowingOriginal = true;
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mCameraDisplay.setShowOriginal(false);
                    mCaptureButton.setEnabled(true);
                    findViewById(R.id.tv_change_camera).setEnabled(true);
                    mIsShowingOriginal = false;
                }
                return true;
            }
        });
        mShowOriginBtn2.setVisibility(View.INVISIBLE);

        mShowOriginBtn3 = (TextView) findViewById(R.id.tv_show_origin3);
        mShowOriginBtn3.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                // TODO Auto-generated method stub
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    mCameraDisplay.setShowOriginal(true);
                    mCaptureButton.setEnabled(false);
                    findViewById(R.id.tv_change_camera).setEnabled(false);
                    mIsShowingOriginal = true;
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mCameraDisplay.setShowOriginal(false);
                    mCaptureButton.setEnabled(true);
                    findViewById(R.id.tv_change_camera).setEnabled(true);
                    mIsShowingOriginal = false;
                }
                return true;
            }
        });
        mShowOriginBtn3.setVisibility(View.INVISIBLE);

        mCaptureButton.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {

                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    mTouchDownTime = System.currentTimeMillis();
                    mOnBtnTouch = true;
                    Thread thread = new Thread() {
                        @Override
                        public void run() {
                            while (mOnBtnTouch && Build.VERSION.SDK_INT >= 17) {
                                mTouchCurrentTime = System.currentTimeMillis();
                                if (mTouchCurrentTime - mTouchDownTime >= 500 && !mIsRecording && !mIsPaused) {
                                    //开始录制
                                    Message msg = mHandler.obtainMessage(MSG_NEED_START_RECORDING);
                                    mHandler.sendMessage(msg);
                                    mIsRecording = true;
                                } else if (mTouchCurrentTime - mTouchDownTime >= 10500 && mIsRecording && !mIsPaused) {
                                    //超时结束录制
                                    Message msg = mHandler.obtainMessage(MSG_STOP_RECORDING);
                                    mHandler.sendMessage(msg);
                                    mIsRecording = false;

                                    break;
                                }
                                try {
                                    Thread.sleep(100);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    };
                    thread.start();
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mOnBtnTouch = false;
                    if (mTouchCurrentTime - mTouchDownTime > 500 && mIsRecording && !mIsPaused && Build.VERSION.SDK_INT >= 17) {
                        //结束录制
                        Message msg = mHandler.obtainMessage(MSG_STOP_RECORDING);
                        mHandler.sendMessage(msg);
                        mIsRecording = false;
                    } else if (mTouchCurrentTime - mTouchDownTime <= 500) {
                        //保存图片
                        if (isWritePermissionAllowed()) {
                            mCameraDisplay.setHandler(mHandler);
                            mCameraDisplay.setSaveImage();
                        } else {
                            requestWritePermission();
                        }
                    }
                } else if (event.getAction() == MotionEvent.ACTION_CANCEL) {
                    mOnBtnTouch = false;
                }
                return true;
            }
        });

        mShowShortVideoTime = (TextView) findViewById(R.id.tv_short_video_time);

        findViewById(R.id.rv_close_sticker).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //重置所有状态为未选中状态
                resetStickerAdapter();
                resetNewStickerAdapter();
                mCurrentStickerPosition = -1;
                mCurrentNewStickerPosition = -1;
                mCameraDisplay.removeAllStickers();
                mCameraDisplay.enableSticker(false);

                mCurrentObjectIndex = -1;
                mObjectAdapter.setSelectedPosition(-1);
                mObjectAdapter.notifyDataSetChanged();
                mCameraDisplay.enableObject(false);

                findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));
            }
        });

        findViewById(R.id.tv_change_camera).setOnClickListener(this);
        findViewById(R.id.tv_change_camera).setVisibility(View.VISIBLE);

        // switch camera
        findViewById(R.id.id_tv_changecamera).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mCameraDisplay.switchCamera();
            }
        });

        mCameraDisplay.enableBeautify(true);
        mIsHasAudioPermission = CheckAudioPermission.isHasPermission(mContext);

        if (DEBUG) {
            //for test add sub model
            mBodySwitch = (Switch) findViewById(R.id.sw_add_body_model_switch);
            mBodySwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

                @Override
                public void onCheckedChanged(CompoundButton buttonView,
                                             boolean isChecked) {
                    // TODO Auto-generated method stub
                    if (isChecked) {
                        mCameraDisplay.addSubModelByName(FileUtils.MODEL_NAME_BODY_FOURTEEN);
                    } else {
                        mCameraDisplay.removeSubModelByConfig(STMobileHumanActionNative.ST_MOBILE_ENABLE_BODY_KEYPOINTS);
                    }
                }
            });

            mFaceExtraInfoSwitch = (Switch) findViewById(R.id.sw_add_face_extra_model);
            mFaceExtraInfoSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

                @Override
                public void onCheckedChanged(CompoundButton buttonView,
                                             boolean isChecked) {
                    // TODO Auto-generated method stub
                    if (isChecked) {
                        mCameraDisplay.addSubModelByName(FileUtils.MODEL_NAME_FACE_EXTRA);
                    } else {
                        mCameraDisplay.removeSubModelByConfig(STMobileHumanActionNative.ST_MOBILE_ENABLE_FACE_EXTRA_DETECT);
                    }
                }
            });

            mEyeBallContourSwitch = (Switch) findViewById(R.id.sw_add_iris_model);
            mEyeBallContourSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

                @Override
                public void onCheckedChanged(CompoundButton buttonView,
                                             boolean isChecked) {
                    // TODO Auto-generated method stub
                    if (isChecked) {
                        mCameraDisplay.addSubModelByName(FileUtils.MODEL_NAME_EYEBALL_CONTOUR);
                    } else {
                        mCameraDisplay.removeSubModelByConfig(STMobileHumanActionNative.ST_MOBILE_ENABLE_EYEBALL_CONTOUR_DETECT);
                    }
                }
            });

            mHandActionSwitch = (Switch) findViewById(R.id.sw_add_hand_action_model);
            mHandActionSwitch.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {

                @Override
                public void onCheckedChanged(CompoundButton buttonView,
                                             boolean isChecked) {
                    // TODO Auto-generated method stub
                    if (isChecked) {
                        mCameraDisplay.addSubModelByName(FileUtils.MODEL_NAME_HAND);
                    } else {
                        mCameraDisplay.removeSubModelByConfig(STMobileHumanActionNative.ST_MOBILE_ENABLE_HAND_DETECT);
                    }
                }
            });
        }
        mResetTextView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mBeautyOptionsPosition == 3 ){
                    resetMakeup();
                } else if(mBeautyOptionsPosition == 4){
                    setDefaultFilter();
                    mFilterStrengthBar.setProgress(65);
                } else {
                    resetSetBeautyParam(mBeautyOptionsPosition);
                    resetBeautyLists(mBeautyOptionsPosition);
                    mBeautyItemAdapters.get(mBeautyOption.get(mBeautyOptionsPosition)).notifyDataSetChanged();
                    if (checkMicroType()) {
                        mIndicatorSeekbar.getSeekBar().setProgress(STUtils.convertToData(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).getProgress()));
                    } else {
                        mIndicatorSeekbar.getSeekBar().setProgress(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).getProgress());
                    }
                    mIndicatorSeekbar.updateTextview(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).getProgress());
                }
            }
        });
    }

    public void setDefaultFilter() {
        resetFilterView();
        if (mFilterLists.get("filter_portrait").size() > 0) {
            for (int i = 0; i < mFilterLists.get("filter_portrait").size(); i++) {
                if (mFilterLists.get("filter_portrait").get(i).name.equals("babypink")) {
                    mCurrentFilterIndex = i;
                }
            }

            if (mCurrentFilterIndex > 0) {
                mCurrentFilterGroupIndex = 0;
                mFilterAdapters.get("filter_portrait").setSelectedPosition(mCurrentFilterIndex);
                mCameraDisplay.setFilterStyle(mFilterLists.get("filter_portrait").get(mCurrentFilterIndex).model);
                mCameraDisplay.enableFilter(true);

                ((ImageView) findViewById(R.id.iv_filter_group_portrait)).setImageDrawable(getResources().getDrawable(R.drawable.icon_portrait_selected));
                ((TextView) findViewById(R.id.tv_filter_group_portrait)).setTextColor(Color.parseColor("#c460e1"));
                mFilterAdapters.get("filter_portrait").notifyDataSetChanged();
            }
        }
    }

    private void resetSetBeautyParam(int beautyOptionsPosition) {
        switch (beautyOptionsPosition) {
            case 0:
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_WHITEN_STRENGTH, (mBeautifyParams[2]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_REDDEN_STRENGTH, (mBeautifyParams[0]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SMOOTH_STRENGTH, (mBeautifyParams[1]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_DEHIGHLIGHT_STRENGTH, (mBeautifyParams[8]));
                break;
            case 1:
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_FACE_RATIO, (mBeautifyParams[4]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_ENLARGE_EYE_RATIO, (mBeautifyParams[3]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_JAW_RATIO, (mBeautifyParams[5]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_NARROW_FACE_STRENGTH, (mBeautifyParams[9]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_ROUND_EYE_RATIO, (mBeautifyParams[26]));
                break;
            case 2:
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, (mBeautifyParams[10]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, (mBeautifyParams[11]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, (mBeautifyParams[12]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, (mBeautifyParams[13]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, (mBeautifyParams[14]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, (mBeautifyParams[15]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, (mBeautifyParams[16]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, (mBeautifyParams[17]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, (mBeautifyParams[18]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, (mBeautifyParams[19]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_PROFILE_RHINOPLASTY_RATIO, (mBeautifyParams[20]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_BRIGHT_EYE_RATIO, (mBeautifyParams[21]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, (mBeautifyParams[22]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, (mBeautifyParams[23]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_WHITE_TEETH_RATIO, (mBeautifyParams[24]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, (mBeautifyParams[25]));
                break;
            case 5:
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_CONSTRACT_STRENGTH, (mBeautifyParams[6]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SATURATION_STRENGTH, (mBeautifyParams[7]));
                break;
        }
    }

    private void resetBeautyLists(int beautyOptionsPosition) {
        switch (beautyOptionsPosition) {
            case 0:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int) (mBeautifyParams[2] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int) (mBeautifyParams[0] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(2).setProgress((int) (mBeautifyParams[1] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(3).setProgress((int) (mBeautifyParams[8] * 100));
                break;
            case 1:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int) (mBeautifyParams[4] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int) (mBeautifyParams[3] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(2).setProgress((int) (mBeautifyParams[5] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(3).setProgress((int) (mBeautifyParams[9] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(4).setProgress((int) (mBeautifyParams[26] * 100));
                break;
            case 2:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int) (mBeautifyParams[10] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int) (mBeautifyParams[11] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(2).setProgress((int) (mBeautifyParams[12] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(3).setProgress((int) (mBeautifyParams[13] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(4).setProgress((int) (mBeautifyParams[14] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(5).setProgress((int) (mBeautifyParams[15] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(6).setProgress((int) (mBeautifyParams[16] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(7).setProgress((int) (mBeautifyParams[17] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(8).setProgress((int) (mBeautifyParams[18] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(9).setProgress((int) (mBeautifyParams[19] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(10).setProgress((int) (mBeautifyParams[20] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(11).setProgress((int) (mBeautifyParams[21] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(12).setProgress((int) (mBeautifyParams[22] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(13).setProgress((int) (mBeautifyParams[23] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(14).setProgress((int) (mBeautifyParams[24] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(15).setProgress((int) (mBeautifyParams[25] * 100));
                break;
            case 5:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int) (mBeautifyParams[6] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int) (mBeautifyParams[7] * 100));
                break;
        }
    }

    private void calculateBeautyIndex(int beautyOptionPosition, int selectPosition) {
        switch (beautyOptionPosition) {
            case 0:
                switch (selectPosition) {
                    case 0:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_WHITEN_STRENGTH;
                        break;
                    case 1:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_REDDEN_STRENGTH;
                        break;
                    case 2:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_SMOOTH_STRENGTH;
                        break;
                    case 3:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_DEHIGHLIGHT_STRENGTH;
                        break;
                }
                break;
            case 1:
                switch (selectPosition) {
                    case 0:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_SHRINK_FACE_RATIO;
                        break;
                    case 1:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_ENLARGE_EYE_RATIO;
                        break;
                    case 2:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_SHRINK_JAW_RATIO;
                        break;
                    case 3:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_NARROW_FACE_STRENGTH;
                        break;
                    case 4:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_ROUND_EYE_RATIO;
                        break;
                }
                break;
            case 2:
                switch (selectPosition) {
                    case 0:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO;
                        break;
                    case 1:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO;
                        break;
                    case 2:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO;
                        break;
                    case 3:
                        mCurrentBeautyIndex = Constants. ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO;
                        break;
                    case 4:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_NARROW_NOSE_RATIO;
                        break;
                    case 5:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO;
                        break;
                    case 6:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_PROFILE_RHINOPLASTY_RATIO;
                        break;
                    case 7:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO;
                        break;
                    case 8:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO;
                        break;
                    case 9:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO;
                        break;
                    case 10:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_EYE_ANGLE_RATIO;
                        break;
                    case 11:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO;
                        break;
                    case 12:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_BRIGHT_EYE_RATIO;
                        break;
                    case 13:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO;
                        break;
                    case 14:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO;
                        break;
                    case 15:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_3D_WHITE_TEETH_RATIO;
                        break;
                }
                break;
            case 5:
                switch (selectPosition) {
                    case 0:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_CONSTRACT_STRENGTH;
                        break;
                    case 1:
                        mCurrentBeautyIndex = Constants.ST_BEAUTIFY_SATURATION_STRENGTH;
                        break;
                }
                break;
        }
    }

    private void perFormSetMeteringArea(float touchX, float touchY) {
        performVerticalSeekBarVisiable(true);
        mCameraDisplay.setMeteringArea(touchX, touchY);
        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) mMeteringArea.getLayoutParams();
        params.setMargins((int) touchX - 50, (int) touchY - 50, 0, 0);
        mMeteringArea.setLayoutParams(params);
        mMeteringArea.setVisibility(View.VISIBLE);
        AnimatorSet animatorSet = new AnimatorSet();
        ObjectAnimator animX = ObjectAnimator.ofFloat(mMeteringArea, "scaleX", 1.5f, 1.2f);
        ObjectAnimator animY = ObjectAnimator.ofFloat(mMeteringArea, "scaleY", 1.5f, 1.2f);
        animatorSet.setDuration(500);
        animatorSet.play(animX).with(animY);
        animatorSet.start();
        animatorSet.addListener(new Animator.AnimatorListener() {
            @Override
            public void onAnimationStart(Animator animation) {

            }

            @Override
            public void onAnimationEnd(Animator animation) {
                mMeteringArea.setVisibility(View.INVISIBLE);
            }

            @Override
            public void onAnimationCancel(Animator animation) {

            }

            @Override
            public void onAnimationRepeat(Animator animation) {

            }
        });
    }

    private void performVerticalSeekBarVisiable(boolean isVisiable) {
        if (isVisiable) {
            mHandler.removeMessages(MSG_HIDE_VERTICALSEEKBAR);
            mHandler.sendEmptyMessageDelayed(MSG_HIDE_VERTICALSEEKBAR, 2000);
            mVerticalSeekBar.setVisibility(View.VISIBLE);
        } else {
            mVerticalSeekBar.setVisibility(View.GONE);
        }
    }

    private boolean isSlide(int downX, int downY, int upX, int upY) {
        if (Math.abs(upX - downX) > 25 || Math.abs(upY - downY) > 25) {
            return true;
        }
        return false;
    }

    private static float getFingerSpacing(MotionEvent event) {
        float x = event.getX(0) - event.getX(1);
        float y = event.getY(0) - event.getY(1);
        return (float) Math.sqrt(x * x + y * y);
    }

    private void resetStickerAdapter() {

        if (mCurrentStickerPosition != -1) {
            mCameraDisplay.removeAllStickers();
            mCurrentStickerPosition = -1;
        }

        //重置所有状态为为选中状态
        for (StickerOptionsItem optionsItem : mStickerOptionsList) {
            if (optionsItem.name.equals("sticker_new_engine")) {
                continue;
            }else if(optionsItem.name.equals("object_track")){
                continue;
            }
            else {
                if (mStickerAdapters.get(optionsItem.name) != null) {
                    mStickerAdapters.get(optionsItem.name).setSelectedPosition(-1);
                    mStickerAdapters.get(optionsItem.name).notifyDataSetChanged();
                }
            }
        }
    }

    private void resetNewStickerAdapter() {

        mCameraDisplay.removeAllStickers();
        mCurrentNewStickerPosition = -1;

        if (mStickerPackageMap != null) {
            mStickerPackageMap.clear();
        }

        if (mNativeStickerAdapters.get("sticker_new_engine") != null) {
            mNativeStickerAdapters.get("sticker_new_engine").setSelectedPosition(-1);
            mNativeStickerAdapters.get("sticker_new_engine").notifyDataSetChanged();
        }
    }

    private void startShowCpuInfo() {
        mNeedStopCpuRate = false;
        mCpuInofThread = new Thread() {
            @Override
            public void run() {
                super.run();
                while (!mNeedStopCpuRate) {
                    final String cpuRate;
                    if (Build.VERSION.SDK_INT <= 25) {
                        cpuRate = String.valueOf(getProcessCpuRate());
                    } else {
                        cpuRate = "null";
                    }

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            ((TextView) findViewById(R.id.tv_cpu_radio)).setText(String.valueOf(cpuRate));
                            if (mCameraDisplay != null) {
                                ((TextView) findViewById(R.id.tv_frame_radio)).setText(String.valueOf(mCameraDisplay.getFrameCost()));
                                ((TextView) findViewById(R.id.tv_fps_info)).setText(mCameraDisplay.getFpsInfo() + "");
                                ((TextView) findViewById(R.id.tv_face_distance)).setText(mCameraDisplay.getFaceDistanceInfo() + " m");

                                showFaceAttributeInfo();
                            }
                        }
                    });

                    try {
                        sleep(500);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }
        };
        mCpuInofThread.start();
    }

    private void stopShowCpuInfo() {
        if (mCpuInofThread != null) {
            mNeedStopCpuRate = true;
            mCpuInofThread.interrupt();
            //mCpuInofThread.stop();
            mCpuInofThread = null;
        }
    }

    private void showActiveTips(long actionNum) {
        if (actionNum != -1 && actionNum != 0) {
            mTipsLayout.setVisibility(View.VISIBLE);
        }

        String triggerTips = "";
        mTipsImageView.setImageDrawable(null);

        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_EYE_BLINK) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_blink);
            triggerTips = triggerTips + "眨眼 ";
            //mTipsTextView.setText("请眨眨眼~");
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_MOUTH_AH) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_mouth);
            //mTipsTextView.setText("张嘴有惊喜~");
            triggerTips = triggerTips + "张嘴 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HEAD_YAW) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_shake);
            triggerTips = triggerTips + "摇头 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HEAD_PITCH) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_nod);
            //mTipsTextView.setText("请点点头~");
            triggerTips = triggerTips + "点头 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_BROW_JUMP) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_frown);
            //mTipsTextView.setText("挑眉有惊喜~");
            triggerTips = triggerTips + "挑眉 ";
        }

        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_FACE_LIPS_UPWARD) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_lips_upward);
            //mTipsTextView.setText("挑眉有惊喜~");
            triggerTips = triggerTips + "嘴角上扬 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_FACE_LIPS_POUTED) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_lips_pouted);
            //mTipsTextView.setText("挑眉有惊喜~");
            triggerTips = triggerTips + "嘟嘴 ";
        }

        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_PALM) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_palm_selected);
            //mTipsTextView.setText("请伸出手掌~");
            triggerTips = triggerTips + "手掌 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_LOVE) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_heart_hand_selected);
            //mTipsTextView.setText("双手比个爱心吧~");
            triggerTips = triggerTips + "双手爱心 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_HOLDUP) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_palm_up_selected);
            //mTipsTextView.setText("请托手~");
            triggerTips = triggerTips + "托手 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_CONGRATULATE) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_congratulate_selected);
            //mTipsTextView.setText("抱个拳吧~");
            triggerTips = triggerTips + "抱拳 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_HEART) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_finger_heart_selected);
            //mTipsTextView.setText("单手比个爱心吧~");
            triggerTips = triggerTips + "单手爱心 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_GOOD) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_thumb_selected);
            //mTipsTextView.setText("请伸出大拇指~");
            triggerTips = triggerTips + "大拇指 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_OK) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_ok_selected);
            //mTipsTextView.setText("请亮出OK手势~");
            triggerTips = triggerTips + "OK ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_SCISSOR) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_scissor_selected);
            //mTipsTextView.setText("请比个剪刀手~");
            triggerTips = triggerTips + "剪刀手 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_PISTOL) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_pistol_selected);
            //mTipsTextView.setText("手枪");
            triggerTips = triggerTips + "手枪 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_INDEX) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_one_finger_selected);
            //mTipsTextView.setText("请伸出食指~");
            triggerTips = triggerTips + "食指 ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_FIST) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_first_selected);
            //mTipsTextView.setText("请举起拳头~");
            triggerTips = triggerTips + "请举起拳头~ ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_666) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_sixsixsix_selected);
            //mTipsTextView.setText("请亮出666手势~");
            triggerTips = triggerTips + "请亮出666手势~ ";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_BLESS) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_handbless_selected);
            //mTipsTextView.setText("请双手合十~");
            triggerTips = triggerTips + "请双手合十~";
        }
        if ((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_ILOVEYOU) > 0) {
            mTipsImageView.setImageResource(R.drawable.ic_trigger_love_selected);
            //mTipsTextView.setText("请亮出我爱你手势~");
            triggerTips = triggerTips + "请亮出我爱你手势~";
        }
        mTipsTextView.setText(triggerTips);

        mTipsLayout.setVisibility(View.VISIBLE);
        if (mTipsRunnable != null) {
            mTipsHandler.removeCallbacks(mTipsRunnable);
        }

        mTipsRunnable = new Runnable() {
            @Override
            public void run() {
                mTipsLayout.setVisibility(View.GONE);
            }
        };

        mTipsHandler.postDelayed(mTipsRunnable, 2000);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.ll_sticker_options_switch:
                mStickerOptionsSwitch.setVisibility(View.INVISIBLE);
                mBeautyOptionsSwitch.setVisibility(View.INVISIBLE);
                mSelectOptions.setBackgroundColor(Color.parseColor("#80000000"));
                mIndicatorSeekbar.setVisibility(View.INVISIBLE);
                mStickerOptions.setVisibility(View.VISIBLE);
                mStickerIcons.setVisibility(View.VISIBLE);
                mIsStickerOptionsOpen = true;
                mShowOriginBtn1.setVisibility(View.INVISIBLE);
                mShowOriginBtn2.setVisibility(View.VISIBLE);
                mShowOriginBtn3.setVisibility(View.INVISIBLE);
                mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                mFilterIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                mFilterAndBeautyOptionView.setVisibility(View.INVISIBLE);
                mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                mResetTextView.setVisibility(View.INVISIBLE);
                mIsBeautyOptionsOpen = false;
                mSettingOptions.setVisibility(View.INVISIBLE);
                mIsSettingOptionsOpen = false;
                break;

            case R.id.ll_beauty_options_switch:
                mStickerOptionsSwitch.setVisibility(View.INVISIBLE);
                mBeautyOptionsSwitch.setVisibility(View.INVISIBLE);
                mSelectOptions.setBackgroundColor(Color.parseColor("#80000000"));
                mBaseBeautyOptions.setVisibility(View.VISIBLE);
                mIndicatorSeekbar.setVisibility(View.VISIBLE);
                if (mBeautyOptionsPosition == 3){
                    mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                    mMakeupGroupRelativeLayout.setVisibility(View.VISIBLE);
                    mMakeupIconsRelativeLayout.setVisibility(View.INVISIBLE);
                    mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                    mIndicatorSeekbar.setVisibility(View.INVISIBLE);
                } else if (mBeautyOptionsPosition == 4) {
                    mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                    mFilterGroupsLinearLayout.setVisibility(View.VISIBLE);
                    mFilterIconsRelativeLayout.setVisibility(View.INVISIBLE);
                    mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                    mIndicatorSeekbar.setVisibility(View.INVISIBLE);
                }
                mFilterAndBeautyOptionView.setVisibility(View.VISIBLE);
                mIsBeautyOptionsOpen = true;
                mShowOriginBtn1.setVisibility(View.INVISIBLE);
                mShowOriginBtn2.setVisibility(View.INVISIBLE);
                mShowOriginBtn3.setVisibility(View.VISIBLE);
                mResetTextView.setVisibility(View.VISIBLE);
                mIsStickerOptionsOpen = false;
                mSettingOptions.setVisibility(View.INVISIBLE);
                mIsSettingOptionsOpen = false;
                break;

            case R.id.iv_setting_options_switch:
                mSelectOptions.setBackgroundColor(Color.parseColor("#80000000"));
                mStickerOptionsSwitch.setVisibility(View.VISIBLE);
                mBeautyOptionsSwitch.setVisibility(View.VISIBLE);
                if (mIsSettingOptionsOpen) {
                    mSelectOptions.setBackgroundColor(Color.parseColor("#00000000"));
                    mSettingOptions.setVisibility(View.INVISIBLE);
                    mIsSettingOptionsOpen = false;
                    mIndicatorSeekbar.setVisibility(View.INVISIBLE);
                    mShowOriginBtn1.setVisibility(View.VISIBLE);
                    mShowOriginBtn2.setVisibility(View.INVISIBLE);
                    mShowOriginBtn3.setVisibility(View.INVISIBLE);
                } else {
                    mSettingOptions.setVisibility(View.VISIBLE);
                    mIsSettingOptionsOpen = true;

                    mShowOriginBtn1.setVisibility(View.INVISIBLE);
                    mShowOriginBtn2.setVisibility(View.VISIBLE);
                    mShowOriginBtn3.setVisibility(View.INVISIBLE);

                    mStickerOptions.setVisibility(View.INVISIBLE);
                    mStickerIcons.setVisibility(View.INVISIBLE);
                }

                mStickerOptionsSwitchIcon = (ImageView) findViewById(R.id.iv_sticker_options_switch);
                mBeautyOptionsSwitchIcon = (ImageView) findViewById(R.id.iv_beauty_options_switch);
                mStickerOptionsSwitchText = (TextView) findViewById(R.id.tv_sticker_options_switch);
                mBeautyOptionsSwitchText = (TextView) findViewById(R.id.tv_beauty_options_switch);

                mStickerOptionsSwitchIcon.setImageDrawable(getResources().getDrawable(R.drawable.sticker));
                mStickerOptionsSwitchText.setTextColor(Color.parseColor("#ffffff"));
                mIsStickerOptionsOpen = false;

                mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                mFilterIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                mFilterAndBeautyOptionView.setVisibility(View.INVISIBLE);
                mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                mIndicatorSeekbar.setVisibility(View.INVISIBLE);
                mResetTextView.setVisibility(View.INVISIBLE);
                mBeautyOptionsSwitchIcon.setImageDrawable(getResources().getDrawable(R.drawable.beauty));
                mBeautyOptionsSwitchText.setTextColor(Color.parseColor("#ffffff"));
                mIsBeautyOptionsOpen = false;
                break;

            case R.id.id_gl_sv:
                mSelectOptions.setBackgroundColor(Color.parseColor("#00000000"));
                mStickerOptions.setVisibility(View.INVISIBLE);
                mStickerIcons.setVisibility(View.INVISIBLE);

                mStickerOptionsSwitchIcon = (ImageView) findViewById(R.id.iv_sticker_options_switch);
                mBeautyOptionsSwitchIcon = (ImageView) findViewById(R.id.iv_beauty_options_switch);
                mStickerOptionsSwitchText = (TextView) findViewById(R.id.tv_sticker_options_switch);
                mBeautyOptionsSwitchText = (TextView) findViewById(R.id.tv_beauty_options_switch);

                mStickerOptionsSwitchIcon.setImageDrawable(getResources().getDrawable(R.drawable.sticker));
                mStickerOptionsSwitchText.setTextColor(Color.parseColor("#ffffff"));
                mIsStickerOptionsOpen = false;

                mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                mFilterIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                mFilterAndBeautyOptionView.setVisibility(View.INVISIBLE);
                mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                mBeautyOptionsSwitchIcon.setImageDrawable(getResources().getDrawable(R.drawable.beauty));
                mBeautyOptionsSwitchText.setTextColor(Color.parseColor("#ffffff"));
                mIsBeautyOptionsOpen = false;

                mSettingOptions.setVisibility(View.INVISIBLE);
                mIsSettingOptionsOpen = false;

                mShowOriginBtn1.setVisibility(View.VISIBLE);
                mShowOriginBtn2.setVisibility(View.INVISIBLE);
                mShowOriginBtn3.setVisibility(View.INVISIBLE);
                break;

            case R.id.tv_change_camera:
                if (mCameraDisplay != null) {
                    mCameraDisplay.switchCamera();
                }

                break;

            case R.id.tv_cancel:
                // back to welcome page
                finish();
                break;

            case R.id.testSwitch0:
                if (!testboolean) {
                    mCameraDisplay.changeModuleTransition(0);
                }
                break;

            case R.id.testSwitch1:
                if (!testboolean) {
                    mCameraDisplay.changeModuleTransition(1);
                }
                break;

            case R.id.testSwitch2:
                if (!testboolean) {
                    mCameraDisplay.changeModuleTransition(2);
                }
                break;

            default:
                break;
        }
    }

    // 分隔间距 继承RecyclerView.ItemDecoration
    class SpaceItemDecoration extends RecyclerView.ItemDecoration {
        private int space;

        public SpaceItemDecoration(int space) {
            this.space = space;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            super.getItemOffsets(outRect, view, parent, state);
            if (parent.getChildAdapterPosition(view) != 0) {
                outRect.top = space;
            }
        }
    }

    class BeautyItemDecoration extends RecyclerView.ItemDecoration {
        private int space;

        public BeautyItemDecoration(int space) {
            this.space = space;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            super.getItemOffsets(outRect, view, parent, state);
            outRect.left = space;
            outRect.right = space;
        }
    }

    private ChangePreviewSizeListener mChangePreviewSizeListener = new ChangePreviewSizeListener() {
        public void onChangePreviewSize(final int previewW, final int previewH) {
            CameraActivity.this.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    mPreviewFrameLayout.requestLayout();
                }
            });
        }
    };

    @Override
    protected void onSaveInstanceState(Bundle savedInstanceState) {
        savedInstanceState.putBoolean("process_killed", true);
        super.onSaveInstanceState(savedInstanceState);
    }

    @Override
    protected void onResume() {
        LogUtils.i(TAG, "onResume");
        super.onResume();
        mAccelerometer.start();
        mSensorManager.registerListener(this, mRotation, SensorManager.SENSOR_DELAY_GAME);

        mCameraDisplay.onResume();
        mCameraDisplay.setShowOriginal(false);

        resetTimer();
        mIsRecording = false;
        startShowCpuInfo();
        mIsPaused = false;
    }

    private boolean mIsPaused = false;

    @Override
    protected void onPause() {
        super.onPause();
        LogUtils.i(TAG, "onPause");

        mSensorManager.unregisterListener(this);

        //if is recording, stop recording
        mIsPaused = true;
        if (mIsRecording) {
            mHandler.removeMessages(MSG_STOP_RECORDING);
            stopRecording();
            enableShowLayouts();

            if (mVideoFilePath != null) {
                File file = new File(mVideoFilePath);
                if (file != null) {
                    file.delete();
                }
            }

            resetTimer();
            mIsRecording = false;
        }

        if (!mPermissionDialogShowing) {
            mAccelerometer.stop();
            mCameraDisplay.onPause();
        }
        stopShowCpuInfo();
    }

    @Override
    protected void onDestroy() {

        super.onDestroy();
        mCameraDisplay.onDestroy();
        mStickerAdapters.clear();
        mNativeStickerAdapters.clear();
        mStickerlists.clear();
        mBeautyParamsSeekBarList.clear();
        mFilterAdapters.clear();
        mFilterLists.clear();
        mObjectList.clear();
        mStickerOptionsList.clear();
        mBeautyOptionsList.clear();
        if (mStickerPackageMap != null) {
            mStickerPackageMap.clear();
            mStickerPackageMap = null;
        }

        finish();
    }

    private float getProcessCpuRate() {
        long totalCpuTime1 = getTotalCpuTime();
        long processCpuTime1 = getAppCpuTime();
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        long totalCupTime2 = getTotalCpuTime();
        long processCpuTime2 = getAppCpuTime();

        if (totalCpuTime1 != totalCupTime2) {
            float rate = (float) (100 * (processCpuTime2 - processCpuTime1) / (totalCupTime2 - totalCpuTime1));
            if (rate >= 0.0f || rate <= 100.0f) {
                mCurrentCpuRate = rate;
            }
        }

        return mCurrentCpuRate;
    }

    private long getTotalCpuTime() {
        // 获取系统总CPU使用时间
        String[] cpuInfos = null;
        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    new FileInputStream("/proc/stat")), 1000);
            String load = reader.readLine();
            reader.close();
            cpuInfos = load.split(" ");
        } catch (IOException e) {
            e.printStackTrace();
        }

        return Long.parseLong(cpuInfos[2])
                + Long.parseLong(cpuInfos[3]) + Long.parseLong(cpuInfos[4])
                + Long.parseLong(cpuInfos[6]) + Long.parseLong(cpuInfos[5])
                + Long.parseLong(cpuInfos[7]) + Long.parseLong(cpuInfos[8]);
    }

    private long getAppCpuTime() {
        //获取应用占用的CPU时间
        String[] cpuInfos = null;
        int pid = android.os.Process.myPid();
        try {
            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    new FileInputStream("/proc/" + pid + "/stat")), 1000);
            String load = reader.readLine();
            reader.close();
            cpuInfos = load.split(" ");
        } catch (IOException e) {
            e.printStackTrace();
        }

        return Long.parseLong(cpuInfos[13])
                + Long.parseLong(cpuInfos[14]) + Long.parseLong(cpuInfos[15])
                + Long.parseLong(cpuInfos[16]);

    }

    private void onPictureTaken(ByteBuffer data, File file, int mImageWidth, int mImageHeight) {
        if (mImageWidth <= 0 || mImageHeight <= 0)
            return;
        Bitmap srcBitmap = Bitmap.createBitmap(mImageWidth, mImageHeight, Bitmap.Config.ARGB_8888);
        data.position(0);
        srcBitmap.copyPixelsFromBuffer(data);
        saveToSDCard(file, srcBitmap);
        srcBitmap.recycle();
    }


    private void saveToSDCard(File file, Bitmap bmp) {

        BufferedOutputStream bos = null;
        try {
            bos = new BufferedOutputStream(new FileOutputStream(file));
            bmp.compress(Bitmap.CompressFormat.JPEG, 90, bos);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } finally {
            if (bos != null)
                try {
                    bos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
        }

        if (mHandler != null) {
            String path = file.getAbsolutePath();
            Intent mediaScanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            Uri contentUri = Uri.fromFile(file);
            mediaScanIntent.setData(contentUri);
            this.sendBroadcast(mediaScanIntent);

            if (Build.VERSION.SDK_INT >= 19) {

                MediaScannerConnection.scanFile(this, new String[]{path}, null, null);
            }

            mHandler.sendEmptyMessage(CameraActivity.MSG_SAVED_IMG);
        }
    }

    private boolean isWritePermissionAllowed() {
        if (Build.VERSION.SDK_INT >= 23) {
            if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                    != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }

        return true;
    }

    private void requestWritePermission() {
        if (Build.VERSION.SDK_INT >= 23) {
            mPermissionDialogShowing = true;
            this.requestPermissions(new String[]{Manifest.permission.WRITE_EXTERNAL_STORAGE},
                    PERMISSION_REQUEST_WRITE_PERMISSION);
        }
    }

    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == PERMISSION_REQUEST_WRITE_PERMISSION) {
            mPermissionDialogShowing = false;
            if (grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                this.onClick(findViewById(R.id.tv_capture));
            }
        }
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        int eventAction = event.getAction();
        Rect indexRect = mCameraDisplay.getIndexRect();

        if (mIsStickerOptionsOpen || mIsBeautyOptionsOpen || mIsSettingOptionsOpen) {
            closeTableView();
        }

        if (event.getPointerCount() == 1) {
            switch (eventAction) {
                case MotionEvent.ACTION_DOWN:
                    if ((int) event.getX() >= indexRect.left && (int) event.getX() <= indexRect.right &&
                            (int) event.getY() >= indexRect.top && (int) event.getY() <= indexRect.bottom) {
                        mIndexX = (int) event.getX();
                        mIndexY = (int) event.getY();
                        mCameraDisplay.setIndexRect(mIndexX - indexRect.width() / 2, mIndexY - indexRect.width() / 2, true);
                        mCanMove = true;
                        mCameraDisplay.disableObjectTracking();
                    } else {
                        timeDown = System.currentTimeMillis();
                        downX = (int) event.getX();
                        downY = (int) event.getY();
                    }

                    if (!testboolean) {
                        mCameraDisplay.changeCustomEvent();
                    }
                    break;
                case MotionEvent.ACTION_MOVE:
                    if (mCanMove) {
                        mIndexX = (int) event.getX();
                        mIndexY = (int) event.getY();
                        mCameraDisplay.setIndexRect(mIndexX - indexRect.width() / 2, mIndexY - indexRect.width() / 2, true);
                    }
                    break;
                case MotionEvent.ACTION_UP:
                    if (mCanMove) {
                        mIndexX = (int) event.getX();
                        mIndexY = (int) event.getY();
                        mCameraDisplay.setIndexRect(mIndexX - indexRect.width() / 2, mIndexY - indexRect.width() / 2, false);
                        mCameraDisplay.setObjectTrackRect();

                        mCanMove = false;
                    } else {
                        int upX = (int) event.getX();
                        int upY = (int) event.getY();
                        if (System.currentTimeMillis() - timeDown < 300 && !isSlide(downX, downY, upX, upY)) {
                            perFormSetMeteringArea(upX, upY);
                        }
                    }
            }
        } else {
            switch (event.getAction() & MotionEvent.ACTION_MASK) {
                case MotionEvent.ACTION_POINTER_DOWN:
                    oldDist = getFingerSpacing(event);
                    break;
                case MotionEvent.ACTION_MOVE:
                    float newDist = getFingerSpacing(event);
                    if (newDist > oldDist) {
                        mCameraDisplay.handleZoom(true);
                    } else if (newDist < oldDist) {
                        mCameraDisplay.handleZoom(false);
                    }
                    oldDist = newDist;
                    break;
            }
        }
        return true;
    }


    private void drawObjectImage(final Rect rect, final boolean needDrawRect) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!mSurfaceViewOverlap.getHolder().getSurface().isValid()) {
                    return;
                }
                Canvas canvas = mSurfaceViewOverlap.getHolder().lockCanvas();
                if (canvas == null)
                    return;

                canvas.drawColor(0, PorterDuff.Mode.CLEAR);
                if (needDrawRect) {
                    canvas.drawRect(rect, mPaint);
                }
                canvas.drawBitmap(mGuideBitmap, new Rect(0, 0, mGuideBitmap.getWidth(), mGuideBitmap.getHeight()), rect, mPaint);

                mSurfaceViewOverlap.getHolder().unlockCanvasAndPost(canvas);
            }
        });
    }

//    private void drawMeteringArea(final float sf,final Bitmap bitmap, final float touchX, final float touchY){
//        new Thread(new Runnable() {
//            @Override
//            public void run() {
//                if (!mSurfaceViewOverlap.getHolder().getSurface().isValid()) {
//                    return;
//                }
//                if (bitmap != null) {
//                    Canvas canvas = mSurfaceViewOverlap.getHolder().lockCanvas();
//                    if (canvas == null)
//                        return;
//                    canvas.drawColor(0, PorterDuff.Mode.CLEAR);
//                    matrix.setScale(sf, sf, bitmap.getWidth() / 2, bitmap.getHeight() / 2);
//                    matrix.postTranslate(touchX - bitmap.getWidth() / 2, touchY - bitmap.getHeight() / 2);
//                    canvas.drawBitmap(bitmap, matrix, mPaint);
//                    mSurfaceViewOverlap.getHolder().unlockCanvasAndPost(canvas);
//                }
//            }
//        }).start();
//    }

    private void clearObjectImage() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!mSurfaceViewOverlap.getHolder().getSurface().isValid()) {
                    return;
                }
                Canvas canvas = mSurfaceViewOverlap.getHolder().lockCanvas();
                if (canvas == null)
                    return;

                canvas.drawColor(0, PorterDuff.Mode.CLEAR);
                mSurfaceViewOverlap.getHolder().unlockCanvasAndPost(canvas);
            }
        });
    }

    private void drawFaceExtraPoints(final STPoint[] points) {
        if (points == null || points.length == 0) {
            return;
        }

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!mSurfaceViewOverlap.getHolder().getSurface().isValid()) {
                    return;
                }
                Canvas canvas = mSurfaceViewOverlap.getHolder().lockCanvas();
                if (canvas == null)
                    return;

                canvas.drawColor(0, PorterDuff.Mode.CLEAR);
                STUtils.drawPoints(canvas, mPaint, points);

                mSurfaceViewOverlap.getHolder().unlockCanvasAndPost(canvas);
            }
        });
    }

    private void notifyVideoUpdate(String videoFilePath){
        if(videoFilePath == null || videoFilePath.length() == 0){
            return;
        }
        File file = new File(videoFilePath);
        Intent mediaScanIntent = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
        Uri contentUri = Uri.fromFile(file);
        mediaScanIntent.setData(contentUri);
        this.sendBroadcast(mediaScanIntent);
        if (Build.VERSION.SDK_INT >= 19) {
            MediaScannerConnection.scanFile(getApplicationContext(), new String[]{videoFilePath}, null, null);
        }
    }

    /**
     * callback methods from encoder
     */
    private final MediaEncoder.MediaEncoderListener mMediaEncoderListener = new MediaEncoder.MediaEncoderListener() {
        @Override
        public void onPrepared(final MediaEncoder encoder) {
            if (encoder instanceof MediaVideoEncoder && mCameraDisplay != null)
                mCameraDisplay.setVideoEncoder((MediaVideoEncoder) encoder);
        }

        @Override
        public void onStopped(final MediaEncoder encoder) {
            if (encoder instanceof MediaVideoEncoder && mCameraDisplay != null)
                mCameraDisplay.setVideoEncoder(null);
        }
    };

    private MediaMuxerWrapper mMuxer;

    private void startRecording() {
        try {
            mMuxer = new MediaMuxerWrapper(".mp4");    // if you record audio only, ".m4a" is also OK.

            // for video capturing
            new MediaVideoEncoder(mMuxer, mMediaEncoderListener, mCameraDisplay.getPreviewWidth(), mCameraDisplay.getPreviewHeight());

            if (mIsHasAudioPermission) {
                // for audio capturing
                new MediaAudioEncoder(mMuxer, mMediaEncoderListener);
            }

            mMuxer.prepare();
            mMuxer.startRecording();
        } catch (final IOException e) {
            Log.e(TAG, "startCapture:", e);
        }
    }

    private void stopRecording() {
        if (mMuxer != null) {
            mVideoFilePath = mMuxer.getFilePath();
            mMuxer.stopRecording();
            //mMuxer = null;
        }
        System.gc();
    }

    private void updateTimer() {
        String timeInfo;
        mTimeSeconds++;

        if (mTimeSeconds >= 60) {
            mTimeMinutes++;
            mTimeSeconds = 0;
        }

        if (mTimeSeconds < 10 && mTimeMinutes < 10) {
            timeInfo = "00:0" + mTimeMinutes + ":" + "0" + mTimeSeconds;
        } else if (mTimeSeconds < 10 && mTimeMinutes >= 10) {
            timeInfo = "00:" + mTimeMinutes + ":" + "0" + mTimeSeconds;
        } else if (mTimeSeconds >= 10 && mTimeMinutes < 10) {
            timeInfo = "00:0" + mTimeMinutes + ":" + mTimeSeconds;
        } else {
            timeInfo = "00:" + mTimeMinutes + ":" + mTimeSeconds;
        }

        mShowShortVideoTime.setText(timeInfo);
    }

    private void resetTimer() {
        mTimeMinutes = 0;
        mTimeSeconds = 0;
        if (mTimer != null) {
            mTimer.cancel();
        }
        if (mTimerTask != null) {
            mTimerTask.cancel();
        }

        mShowShortVideoTime.setText("00:00:00");
        mShowShortVideoTime.setVisibility(View.INVISIBLE);
    }

    private void closeTableView() {
        mStickerOptionsSwitch.setVisibility(View.VISIBLE);
        mBeautyOptionsSwitch.setVisibility(View.VISIBLE);
        mSelectOptions.setBackgroundColor(Color.parseColor("#00000000"));

        mStickerOptions.setVisibility(View.INVISIBLE);
        mStickerIcons.setVisibility(View.INVISIBLE);

        mStickerOptionsSwitchIcon = (ImageView) findViewById(R.id.iv_sticker_options_switch);
        mBeautyOptionsSwitchIcon = (ImageView) findViewById(R.id.iv_beauty_options_switch);
        mStickerOptionsSwitchText = (TextView) findViewById(R.id.tv_sticker_options_switch);
        mBeautyOptionsSwitchText = (TextView) findViewById(R.id.tv_beauty_options_switch);

        mStickerOptionsSwitchIcon.setImageDrawable(getResources().getDrawable(R.drawable.sticker));
        mStickerOptionsSwitchText.setTextColor(Color.parseColor("#ffffff"));
        mIsStickerOptionsOpen = false;

        mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
        mFilterIconsRelativeLayout.setVisibility(View.INVISIBLE);
        mFilterStrengthLayout.setVisibility(View.INVISIBLE);
        mFilterAndBeautyOptionView.setVisibility(View.INVISIBLE);
        mBaseBeautyOptions.setVisibility(View.INVISIBLE);
        mBeautyOptionsSwitchIcon.setImageDrawable(getResources().getDrawable(R.drawable.beauty));
        mBeautyOptionsSwitchText.setTextColor(Color.parseColor("#ffffff"));
        mIsBeautyOptionsOpen = false;
        mIndicatorSeekbar.setVisibility(View.INVISIBLE);
        mSettingOptions.setVisibility(View.INVISIBLE);
        mIsSettingOptionsOpen = false;

        mShowOriginBtn1.setVisibility(View.VISIBLE);
        mShowOriginBtn2.setVisibility(View.INVISIBLE);
        mShowOriginBtn3.setVisibility(View.INVISIBLE);
        mResetTextView.setVisibility(View.INVISIBLE);

        mMakeupGroupRelativeLayout.setVisibility(View.INVISIBLE);
        mMakeupIconsRelativeLayout.setVisibility(View.INVISIBLE);
    }

    private void disableShowLayouts() {
        mShowOriginBtn1.setVisibility(View.INVISIBLE);

        findViewById(R.id.tv_change_camera).setVisibility(View.INVISIBLE);
        mSettingOptionsSwitch.setVisibility(View.INVISIBLE);

        mBeautyOptionsSwitch.setVisibility(View.INVISIBLE);
        mStickerOptionsSwitch.setVisibility(View.INVISIBLE);
        mSelectionPicture.setVisibility(View.INVISIBLE);
    }

    private void enableShowLayouts() {
        mShowOriginBtn1.setVisibility(View.VISIBLE);

        findViewById(R.id.tv_change_camera).setVisibility(View.VISIBLE);
        mSettingOptionsSwitch.setVisibility(View.VISIBLE);

        mBeautyOptionsSwitch.setVisibility(View.VISIBLE);
        mStickerOptionsSwitch.setVisibility(View.VISIBLE);
        mSelectionPicture.setVisibility(View.VISIBLE);
    }

    private void resetFilterView() {
        ((ImageView) findViewById(R.id.iv_filter_group_portrait)).setImageDrawable(getResources().getDrawable(R.drawable.icon_portrait_unselected));
        ((TextView) findViewById(R.id.tv_filter_group_portrait)).setTextColor(Color.parseColor("#ffffff"));

        ((ImageView) findViewById(R.id.iv_filter_group_scenery)).setImageDrawable(getResources().getDrawable(R.drawable.icon_scenery_unselected));
        ((TextView) findViewById(R.id.tv_filter_group_scenery)).setTextColor(Color.parseColor("#ffffff"));

        ((ImageView) findViewById(R.id.iv_filter_group_still_life)).setImageDrawable(getResources().getDrawable(R.drawable.icon_still_life_unselected));
        ((TextView) findViewById(R.id.tv_filter_group_still_life)).setTextColor(Color.parseColor("#ffffff"));

        ((ImageView) findViewById(R.id.iv_filter_group_food)).setImageDrawable(getResources().getDrawable(R.drawable.icon_food_unselected));
        ((TextView) findViewById(R.id.tv_filter_group_food)).setTextColor(Color.parseColor("#ffffff"));

        mFilterAdapters.get("filter_portrait").setSelectedPosition(-1);
        mFilterAdapters.get("filter_portrait").notifyDataSetChanged();
        mFilterAdapters.get("filter_scenery").setSelectedPosition(-1);
        mFilterAdapters.get("filter_scenery").notifyDataSetChanged();
        mFilterAdapters.get("filter_still_life").setSelectedPosition(-1);
        mFilterAdapters.get("filter_still_life").notifyDataSetChanged();
        mFilterAdapters.get("filter_food").setSelectedPosition(-1);
        mFilterAdapters.get("filter_food").notifyDataSetChanged();

        mFilterStrengthLayout.setVisibility(View.INVISIBLE);
    }

    private int mColorBlue = Color.parseColor("#0a8dff");

    private void showHandActionInfo(long action) {

        resetHandActionInfo();

        if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_PALM) > 0) {
            findViewById(R.id.iv_palm).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_palm)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_palm_selected));
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_GOOD) > 0) {
            findViewById(R.id.iv_thumb).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_thumb)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_thumb_selected));
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_OK) > 0) {
            findViewById(R.id.iv_ok).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_ok)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_ok_selected));
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_PISTOL) > 0) {
            findViewById(R.id.iv_pistol).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_pistol)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_pistol_selected));
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_INDEX) > 0) {
            findViewById(R.id.iv_one_finger).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_one_finger)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_one_finger_selected));
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_HEART) > 0) {
            findViewById(R.id.iv_finger_heart).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_finger_heart)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_finger_heart_selected));
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_LOVE) > 0) {
            findViewById(R.id.iv_heart_hand).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_heart_hand)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_heart_hand_selected));
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_SCISSOR) > 0) {
            findViewById(R.id.iv_scissor).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_scissor)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_scissor_selected));
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_CONGRATULATE) > 0) {
            findViewById(R.id.iv_congratulate).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_congratulate)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_congratulate_selected));
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_HAND_HOLDUP) > 0) {
            findViewById(R.id.iv_palm_up).setBackgroundColor(mColorBlue);
            ((ImageView) findViewById(R.id.iv_palm_up)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_palm_up_selected));
        }
    }

    private void resetHandActionInfo() {
        findViewById(R.id.iv_palm).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_palm)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_palm));

        findViewById(R.id.iv_thumb).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_thumb)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_thumb));

        findViewById(R.id.iv_ok).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_ok)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_ok));

        findViewById(R.id.iv_pistol).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_pistol)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_pistol));

        findViewById(R.id.iv_one_finger).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_one_finger)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_one_finger));

        findViewById(R.id.iv_finger_heart).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_finger_heart)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_finger_heart));

        findViewById(R.id.iv_heart_hand).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_heart_hand)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_heart_hand));

        findViewById(R.id.iv_scissor).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_scissor)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_scissor));

        findViewById(R.id.iv_congratulate).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_congratulate)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_congratulate));

        findViewById(R.id.iv_palm_up).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView) findViewById(R.id.iv_palm_up)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_palm_up));
    }

    private void showBodyActionInfo(long action) {
        TextView bodyActionView = (TextView) findViewById(R.id.tv_show_body_action);
        bodyActionView.setVisibility(View.VISIBLE);
        //for test body action
        if ((action & STMobileHumanActionNative.ST_MOBILE_BODY_ACTION3) > 0) {
            bodyActionView.setText("肢体动作：摊手");
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_BODY_ACTION2) > 0) {
            bodyActionView.setText("肢体动作：一休");
        } else if ((action & STMobileHumanActionNative.ST_MOBILE_BODY_ACTION1) > 0) {
            bodyActionView.setText("肢体动作：龙拳");
        } else {
            bodyActionView.setVisibility(View.INVISIBLE);
        }
    }

    private void showFaceAttributeInfo() {
        if (mCameraDisplay.getFaceAttributeString() != null) {
            mAttributeText.setVisibility(View.VISIBLE);
            if (mCameraDisplay.getFaceAttributeString().equals("noFace")) {
                mAttributeText.setText("");
            } else {
                mAttributeText.setText("人脸属性: " + mCameraDisplay.getFaceAttributeString());
            }
        } else {
            mAttributeText.setVisibility(View.INVISIBLE);
        }
    }

    private void showFaceExpressionInfo(boolean[] faceExpressionInfo) {

        resetFaceExpression();

        if (faceExpressionInfo != null) {
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_HEAD_NORMAL.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_head_normal)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_normal_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_SIDE_FACE_LEFT.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_side_face_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_side_face_left_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_SIDE_FACE_RIGHT.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_side_face_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_side_face_right_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_TILTED_FACE_LEFT.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_tilted_face_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_tilted_face_left_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_TILTED_FACE_RIGHT.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_tilted_face_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_tilted_face_right_selected));
            }

            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_HEAD_RISE.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_head_rise)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_rise_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_HEAD_LOWER.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_head_lower)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_lower_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_TWO_EYE_OPEN.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_two_eye_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_two_eye_open_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_TWO_EYE_CLOSE.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_two_eye_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_two_eye_close_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_LEFTEYE_CLOSE_RIGHTEYE_OPEN.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_lefteye_close_righteye_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lefteye_close_righteye_open_selected));
            }

            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_LEFTEYE_OPEN_RIGHTEYE_CLOSE.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_lefteye_open_righteye_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lefteye_open_righteye_close_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_MOUTH_OPEN.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_mouth_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_mouth_open_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_MOUTH_CLOSE.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_mouth_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_mouth_close_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_FACE_LIPS_POUTED.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_face_lips_pouted)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_face_lips_pouted_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_FACE_LIPS_UPWARD.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_face_lips_upward)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_face_lips_upward_selected));
            }

            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_FACE_LIPS_CURL_LEFT.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_lips_curl_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lips_curl_left_selected));
            }
            if (faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_FACE_LIPS_CURL_RIGHT.getExpressionCode()]) {
                ((ImageView) findViewById(R.id.iv_face_expression_lips_curl_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lips_curl_right_selected));
            }
        }
    }

    private void resetFaceExpression() {
        ((ImageView) findViewById(R.id.iv_face_expression_head_normal)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_normal));
        ((ImageView) findViewById(R.id.iv_face_expression_side_face_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_side_face_left));
        ((ImageView) findViewById(R.id.iv_face_expression_side_face_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_side_face_right));
        ((ImageView) findViewById(R.id.iv_face_expression_tilted_face_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_tilted_face_left));
        ((ImageView) findViewById(R.id.iv_face_expression_tilted_face_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_tilted_face_right));

        ((ImageView) findViewById(R.id.iv_face_expression_head_rise)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_rise));
        ((ImageView) findViewById(R.id.iv_face_expression_head_lower)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_lower));
        ((ImageView) findViewById(R.id.iv_face_expression_two_eye_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_two_eye_open));
        ((ImageView) findViewById(R.id.iv_face_expression_two_eye_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_two_eye_close));
        ((ImageView) findViewById(R.id.iv_face_expression_lefteye_close_righteye_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lefteye_close_righteye_open));

        ((ImageView) findViewById(R.id.iv_face_expression_lefteye_open_righteye_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lefteye_open_righteye_close));
        ((ImageView) findViewById(R.id.iv_face_expression_mouth_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_mouth_open));
        ((ImageView) findViewById(R.id.iv_face_expression_mouth_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_mouth_close));
        ((ImageView) findViewById(R.id.iv_face_expression_face_lips_pouted)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_face_lips_pouted));
        ((ImageView) findViewById(R.id.iv_face_expression_face_lips_upward)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_face_lips_upward));

        ((ImageView) findViewById(R.id.iv_face_expression_lips_curl_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lips_curl_left));
        ((ImageView) findViewById(R.id.iv_face_expression_lips_curl_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lips_curl_right));
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        mCameraDisplay.setSensorEvent(event);
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }

    /**
     * 直接变更ui ,不通过数据驱动，相比notify data change 反应会快些
     * @param stickerItem
     * @param position
     * @param name
     */
    public void notifyStickerViewState(StickerItem stickerItem, int position, String name){
        RecyclerView.ViewHolder viewHolder = mStickersRecycleView.findViewHolderForAdapterPosition(position);
        //排除不必要变更
        if (viewHolder == null || mStickersRecycleView.getAdapter() != mStickerAdapters.get(name))
            return;
        View itemView = viewHolder.itemView;
        ImageView normalState = (ImageView) itemView.findViewById(R.id.normalState);
        ImageView downloadingState = (ImageView) itemView.findViewById(R.id.downloadingState);
        ViewGroup loadingStateParent = (ViewGroup) itemView.findViewById(R.id.loadingStateParent);
        switch (stickerItem.state) {
            case NORMAL_STATE:
                //设置为等待下载状态
                if (normalState.getVisibility() != View.VISIBLE) {
                    Log.i("StickerAdapter", "NORMAL_STATE");
                    normalState.setVisibility(View.VISIBLE);
                    downloadingState.setVisibility((View.INVISIBLE));
                    downloadingState.setActivated(false);
                    loadingStateParent.setVisibility((View.INVISIBLE));
                }
                break;
            case LOADING_STATE:
                //设置为loading 状态
                if (downloadingState.getVisibility() != View.VISIBLE) {
                    Log.i("StickerAdapter", "LOADING_STATE");
                    normalState.setVisibility(View.INVISIBLE);
                    downloadingState.setActivated(true);
                    downloadingState.setVisibility((View.VISIBLE));
                    loadingStateParent.setVisibility((View.VISIBLE));
                }
                break;
            case DONE_STATE:
                //设置为下载完成状态
                if (normalState.getVisibility() != View.INVISIBLE || downloadingState.getVisibility() != View.INVISIBLE) {
                    Log.i("StickerAdapter", "DONE_STATE");
                    normalState.setVisibility(View.INVISIBLE);
                    downloadingState.setVisibility((View.INVISIBLE));
                    downloadingState.setActivated(false);
                    loadingStateParent.setVisibility((View.INVISIBLE));
                }
                break;
        }
    }

    /**
     * 首先鉴权，鉴权成功后，根据group id 获取相应的group 下的素材列表
     */
    private void initStickerListFromNet() {
        SenseArMaterialService.shareInstance().authorizeWithAppId(this, APPID, APPKEY, new SenseArMaterialService.OnAuthorizedListener() {
            @Override
            public void onSuccess() {
                LogUtils.d(TAG, "鉴权成功！");
//                fetchAllGroups();
                fetchGroupMaterialList(mStickerOptionsList);
            }

            @Override
            public void onFailure(SenseArMaterialService.AuthorizeErrorCode errorCode, String errorMsg) {
                LogUtils.d(TAG, String.format(Locale.getDefault(), "鉴权失败！%d, %s", errorCode, errorMsg));
            }
        });
    }

    /**
     * 拉去所有的group id
     */
    private void fetchAllGroups(){
        SenseArMaterialService.shareInstance().fetchAllGroups(new SenseArMaterialService.FetchGroupsListener() {
            @Override
            public void onSuccess(List<SenseArMaterialGroupId> list) {
                if(list !=null && list.size()>0){
                    for (SenseArMaterialGroupId group :list) {

                        LogUtils.d(TAG,group.mId + " name is " + group.mName);
                    }
                }
            }

            @Override
            public void onFailure(int i, String s) {

            }
        });
    }

    /**
     * 初始化tab 点击事件
     */
    private void initStickerTabListener() {
        //tab 切换事件订阅
        mStickerOptionsAdapter.setClickStickerListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mStickerOptionsList == null || mStickerOptionsList.size() <= 0) {
                    LogUtils.e(TAG, "group 列表不能为空");
                    return;
                }
                int position = Integer.parseInt(v.getTag().toString());
                mStickerOptionsAdapter.setSelectedPosition(position);
                mStickersRecycleView.setLayoutManager(new GridLayoutManager(mContext, 6));

                //更新这一次的选择
                StickerOptionsItem selectedItem = mStickerOptionsAdapter.getPositionItem(position);
                if (selectedItem == null) {
                    LogUtils.e(TAG, "选择项目不能为空!");
                    return;
                }
                RecyclerView.Adapter selectedAdapter;
                if (selectedItem.name.equals("sticker_new_engine")) {
                    selectedAdapter = mNativeStickerAdapters.get(selectedItem.name);
                }else if(selectedItem.name.equals("object_track")){
                    selectedAdapter = mObjectAdapter;
                } else {
                    selectedAdapter = mStickerAdapters.get(selectedItem.name);
                }

                if (selectedAdapter == null) {
                    LogUtils.e(TAG, "贴纸adapter 不能为空");
                    Toast.makeText(getApplicationContext(),"列表正在拉取，或拉取出错!", Toast.LENGTH_SHORT).show();
                    return;
                }

                mStickersRecycleView.setAdapter(selectedAdapter);
                mStickerOptionsAdapter.notifyDataSetChanged();
                selectedAdapter.notifyDataSetChanged();
            }
        });
    }

    /**
     * 根据group id 对应素材列表
     *
     * @param groups group id 列表
     */
    private void fetchGroupMaterialList(final List<StickerOptionsItem> groups) {
        for (int i = 0; i < groups.size(); i++) {
            final StickerOptionsItem groupId = groups.get(i);
            if (groupId.name.equals("sticker_new_engine")) {
                //使用本地加载
            }else if(groupId.name.equals("object_track")){
                //使用本地object 追踪模型
            }else {
                //使用网络下载
                final int j = i;
                SenseArMaterialService.shareInstance().fetchMaterialsFromGroupId("", groupId.name, SenseArMaterialType.Effect, new SenseArMaterialService.FetchMaterialListener() {
                    @Override
                    public void onSuccess(final List<SenseArMaterial> materials) {
                        fetchGroupMaterialInfo(groupId.name, materials, j);
                    }

                    @Override
                    public void onFailure(int code, String message) {
                        LogUtils.e(TAG, String.format(Locale.getDefault(), "下载素材信息失败！%d, %s", code, TextUtils.isEmpty(message)?"":message));
                    }
                });
            }
        }
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mStickerOptionsRecycleView.getAdapter() == null) {
                    mStickerOptionsRecycleView.setAdapter(mStickerOptionsAdapter);
                }
                mStickerOptionsAdapter.setSelectedPosition(0);
                mStickerOptionsAdapter.notifyDataSetChanged();
            }
        });
    }

    /**
     * 初始化素材列表中的点击事件回调
     *
     * @param groupId
     * @param index
     * @param materials
     */
    private void initStickerListener(final String groupId, final int index, final List<SenseArMaterial> materials) {
        mStickerAdapters.get(groupId).setClickStickerListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!NetworkUtils.isNetworkAvailable(getApplicationContext())) {
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(getApplicationContext(), "Network unavailable.", Toast.LENGTH_LONG).show();

                        }
                    });
                }
                mTipsLayout.setVisibility(View.GONE);
                final int position = Integer.parseInt(v.getTag().toString());
                final StickerItem stickerItem = mStickerAdapters.get(groupId).getItem(position);
                if (stickerItem != null && stickerItem.state == StickerState.LOADING_STATE) {
                    LogUtils.d(TAG, String.format(Locale.getDefault(), "正在下载，请稍后点击!"));
                    return;
                }

                if (mCurrentStickerOptionsIndex == index && mCurrentStickerPosition == position) {
                    preMaterialId = "";
                    mStickerAdapters.get(groupId).setSelectedPosition(-1);
                    mCurrentStickerOptionsIndex = -1;
                    mCurrentStickerPosition = -1;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));
                    mCameraDisplay.enableSticker(false);
                    mCameraDisplay.removeAllStickers();
                    mStickerAdapters.get(groupId).notifyDataSetChanged();
                    return;
                }
                SenseArMaterial sarm = materials.get(position);
                preMaterialId = sarm.id;
                //如果素材还未下载，点击时需要下载
                if (stickerItem.state == StickerState.NORMAL_STATE) {
                    stickerItem.state = StickerState.LOADING_STATE;
                    notifyStickerViewState(stickerItem, position,groupId);
//                    mStickerAdapters.get(groupId).notifyDataSetChanged();
                    SenseArMaterialService.shareInstance().downloadMaterial(CameraActivity.this, sarm, new SenseArMaterialService.DownloadMaterialListener() {
                        @Override
                        public void onSuccess(final SenseArMaterial material) {
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    stickerItem.path = material.cachedPath;
                                    stickerItem.state = StickerState.DONE_STATE;
                                    //如果本次下载是用户用户最后一次选中项，则直接应用
                                    if (preMaterialId.equals(material.id)) {
                                        resetNewStickerAdapter();
                                        resetStickerAdapter();
                                        mCurrentStickerOptionsIndex = index;
                                        mCurrentStickerPosition = position;
                                        findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));

                                        mStickerAdapters.get(groupId).setSelectedPosition(position);
                                        mCameraDisplay.enableSticker(true);
                                        mCameraDisplay.changeSticker(stickerItem.path);
                                    }
                                    notifyStickerViewState(stickerItem, position, groupId);
//                                    mStickerAdapters.get(groupId).notifyDataSetChanged();
                                }
                            });
                            LogUtils.d(TAG, String.format(Locale.getDefault(), "素材下载成功:%s,cached path is %s", material.materials, material.cachedPath));
                        }

                        @Override
                        public void onFailure(SenseArMaterial material, final int code, String message) {
                            LogUtils.d(TAG, String.format(Locale.getDefault(), "素材下载失败:%s", material.materials));
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    stickerItem.state = StickerState.NORMAL_STATE;
//                                    mStickerAdapters.get(groupId).notifyDataSetChanged();
                                    notifyStickerViewState(stickerItem, position, groupId);
                                }
                            });
                        }

                        @Override
                        public void onProgress(SenseArMaterial material, float progress, int size) {

                        }
                    });
                } else if (stickerItem.state == StickerState.DONE_STATE) {
                    resetNewStickerAdapter();
                    resetStickerAdapter();
                    mCurrentStickerOptionsIndex = index;
                    mCurrentStickerPosition = position;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));

                    mStickerAdapters.get(groupId).setSelectedPosition(position);
                    mCameraDisplay.enableSticker(true);
                    mCameraDisplay.changeSticker(mStickerlists.get(groupId).get(position).path);
                }
            }
        });
    }

    private void initNativeStickerAdapter(final String stickerClassName, final int index){
        mNativeStickerAdapters.get(stickerClassName).setSelectedPosition(-1);
        mNativeStickerAdapters.get(stickerClassName).setClickStickerListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTipsLayout.setVisibility(View.GONE);
                resetNewStickerAdapter();
                resetStickerAdapter();
                int position = Integer.parseInt(v.getTag().toString());

                if(mCurrentStickerOptionsIndex == index && mCurrentStickerPosition == position){
                    mNativeStickerAdapters.get(stickerClassName).setSelectedPosition(-1);
                    mCurrentStickerOptionsIndex = -1;
                    mCurrentStickerPosition = -1;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));
                    mCameraDisplay.enableSticker(false);
                    mCameraDisplay.changeSticker(null);

                }else{
                    mCurrentStickerOptionsIndex = index;
                    mCurrentStickerPosition = position;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));

                    mNativeStickerAdapters.get(stickerClassName).setSelectedPosition(position);
                    mCameraDisplay.enableSticker(true);
                    mCameraDisplay.changeSticker(mNewStickers.get(position).path);
                }

                mNativeStickerAdapters.get(stickerClassName).notifyDataSetChanged();
            }
        });
    }

//    /**
//     * new sticker 需要区别对待
//     *
//     * @param stickerClassName
//     * @param index
//     */
//    private void initNewStickerAdapter(final String stickerClassName, final int index) {
//        mNewStickerAdapters.get(stickerClassName).setClickStickerListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                mTipsLayout.setVisibility(View.GONE);
//                int position = (int) v.getTag();
//                mStickerPackageMap = mNewStickerAdapters.get(stickerClassName).map;
//                boolean isSelected = mNewStickerAdapters.get(stickerClassName).checkSelected(position, mNewStickerAdapters.get(stickerClassName).selectedPosition);
//
//                if (mStickerPackageMap.size() > 9 && !isSelected) {
//                    Toast.makeText(getApplicationContext(), "添加太多了撒",
//                            Toast.LENGTH_SHORT).show();
//                    return;
//                }
//
//                resetStickerAdapter();
//
//                if (isSelected) {
//                    mNewStickerAdapters.get(stickerClassName).selectedPosition[position] = 0;
//                    mCurrentStickerOptionsIndex = -1;
//                    mCurrentNewStickerPosition = -1;
//                    if (mNewStickerAdapters.get(stickerClassName).checkAllUnselected(mNewStickerAdapters.get(stickerClassName).selectedPosition)) {
//                        mCameraDisplay.enableSticker(false);
//                    }
//
//                    if (mStickerPackageMap != null && mStickerPackageMap.get(position) != null) {
//                        mCameraDisplay.removeSticker(mStickerPackageMap.get(position));
//                        mStickerPackageMap.remove(position);
//                    }
//                } else {
//                    mCurrentStickerOptionsIndex = index;
//                    mCurrentNewStickerPosition = position;
//
//                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));
//
//                    mCameraDisplay.enableSticker(true);
//                    int packageId = mCameraDisplay.addSticker(mNewStickers.get(position).path);
//                    if (packageId < 0) {
//                        return;
//                    }
//                    mStickerPackageMap.put(position, packageId);
//
//                    mNewStickerAdapters.get(stickerClassName).selectedPosition[position] = 1;
//                }
//
//                mNewStickerAdapters.get(stickerClassName).notifyDataSetChanged();
//            }
//        });
//    }

    /**
     * 初始化素材的基本信息，如缩略图，是否已经缓存
     *
     * @param groupId   组id
     * @param materials 服务器返回的素材list
     */
    private void fetchGroupMaterialInfo(final String groupId, final List<SenseArMaterial> materials, final int index) {
        if (materials == null || materials.size() <= 0) {
            return;
        }
        final ArrayList<StickerItem> stickerList = new ArrayList<>();
        mStickerlists.put(groupId, stickerList);
        mStickerAdapters.put(groupId, new StickerAdapter(mStickerlists.get(groupId), getApplicationContext()));
        mStickerAdapters.get(groupId).setSelectedPosition(-1);
        LogUtils.d(TAG, "group id is " + groupId + " materials size is " + materials.size());
        initStickerListener(groupId, index, materials);
        for (int i = 0; i < materials.size(); i++) {
            SenseArMaterial sarm = materials.get(i);
            Bitmap bitmap = null;
            try {
                bitmap = ImageUtils.getImageSync(sarm.thumbnail, CameraActivity.this);

            } catch (Exception e) {
                e.printStackTrace();
            }
            if (bitmap == null) {
                bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.none);
            }
            String path = "";
            //如果已经下载则传入路径地址
            if (SenseArMaterialService.shareInstance().isMaterialDownloaded(CameraActivity.this, sarm)) {
                path = SenseArMaterialService.shareInstance().getMaterialCachedPath(CameraActivity.this, sarm);
            }
            sarm.cachedPath = path;
            stickerList.add(new StickerItem(sarm.name, bitmap, path));
        }
    }

    private boolean checkMicroType(){
        int type = mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition);
        boolean ans = ((type != 0) && (type != 4) && (type != 6) && (type != 11) && (type != 12) && (type != 13) && (type != 14) && (type != 15) && (type != 3));
        return ans && (2 == mBeautyOptionsPosition);
    }

    private void updateMakeupOptions(int type, boolean value){
        if(value){
            if(type == Constants.ST_MAKEUP_LIP){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_lip_selected));
                ((ImageView)findViewById(R.id.iv_makeup_group_lip)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_lip_selected));
                ((TextView)findViewById(R.id.tv_makeup_group_lip)).setTextColor(Color.parseColor("#c460e1"));
            }

            if(type == Constants.ST_MAKEUP_BLUSH){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_cheeks_selected));
                ((ImageView)findViewById(R.id.iv_makeup_group_cheeks)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_cheeks_selected));
                ((TextView)findViewById(R.id.tv_makeup_group_cheeks)).setTextColor(Color.parseColor("#c460e1"));
            }

            if(type == Constants.ST_MAKEUP_HIGHLIGHT){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_face_selected));
                ((ImageView)findViewById(R.id.iv_makeup_group_face)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_face_selected));
                ((TextView)findViewById(R.id.tv_makeup_group_face)).setTextColor(Color.parseColor("#c460e1"));
            }

            if(type == Constants.ST_MAKEUP_BROW){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_brow_selected));
                ((ImageView)findViewById(R.id.iv_makeup_group_brow)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_brow_selected));
                ((TextView)findViewById(R.id.tv_makeup_group_brow)).setTextColor(Color.parseColor("#c460e1"));
            }

            if(type == Constants.ST_MAKEUP_EYE){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eye_selected));
                ((ImageView)findViewById(R.id.iv_makeup_group_eye)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eye_selected));
                ((TextView)findViewById(R.id.tv_makeup_group_eye)).setTextColor(Color.parseColor("#c460e1"));
            }

            if(type == Constants.ST_MAKEUP_EYELINER){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeliner_selected));
                ((ImageView)findViewById(R.id.iv_makeup_group_eyeliner)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeliner_selected));
                ((TextView)findViewById(R.id.tv_makeup_group_eyeliner)).setTextColor(Color.parseColor("#c460e1"));
            }

            if(type == Constants.ST_MAKEUP_EYELASH){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyelash_selected));
                ((ImageView)findViewById(R.id.iv_makeup_group_eyelash)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyelash_selected));
                ((TextView)findViewById(R.id.tv_makeup_group_eyelash)).setTextColor(Color.parseColor("#c460e1"));
            }

            if(type == Constants.ST_MAKEUP_EYEBALL){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeball_selected));
                ((ImageView)findViewById(R.id.iv_makeup_group_eyeball)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeball_selected));
                ((TextView)findViewById(R.id.tv_makeup_group_eyeball)).setTextColor(Color.parseColor("#c460e1"));
            }
        }else {
            if(type == Constants.ST_MAKEUP_LIP){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_lip_unselected));
                ((ImageView)findViewById(R.id.iv_makeup_group_lip)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_lip_unselected));
                ((TextView)findViewById(R.id.tv_makeup_group_lip)).setTextColor(Color.parseColor("#ffffff"));
            }

            if(type == Constants.ST_MAKEUP_BLUSH){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_cheeks_unselected));
                ((ImageView)findViewById(R.id.iv_makeup_group_cheeks)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_cheeks_unselected));
                ((TextView)findViewById(R.id.tv_makeup_group_cheeks)).setTextColor(Color.parseColor("#ffffff"));
            }

            if(type == Constants.ST_MAKEUP_HIGHLIGHT){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_face_unselected));
                ((ImageView)findViewById(R.id.iv_makeup_group_face)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_face_unselected));
                ((TextView)findViewById(R.id.tv_makeup_group_face)).setTextColor(Color.parseColor("#ffffff"));
            }

            if(type == Constants.ST_MAKEUP_BROW){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_brow_unselected));
                ((ImageView)findViewById(R.id.iv_makeup_group_brow)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_brow_unselected));
                ((TextView)findViewById(R.id.tv_makeup_group_brow)).setTextColor(Color.parseColor("#ffffff"));
            }

            if(type == Constants.ST_MAKEUP_EYE){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eye_unselected));
                ((ImageView)findViewById(R.id.iv_makeup_group_eye)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eye_unselected));
                ((TextView)findViewById(R.id.tv_makeup_group_eye)).setTextColor(Color.parseColor("#ffffff"));
            }

            if(type == Constants.ST_MAKEUP_EYELINER){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeline_unselected));
                ((ImageView)findViewById(R.id.iv_makeup_group_eyeliner)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeline_unselected));
                ((TextView)findViewById(R.id.tv_makeup_group_eyeliner)).setTextColor(Color.parseColor("#ffffff"));
            }

            if(type == Constants.ST_MAKEUP_EYELASH){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyelash_unselected));
                ((ImageView)findViewById(R.id.iv_makeup_group_eyelash)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyelash_unselected));
                ((TextView)findViewById(R.id.tv_makeup_group_eyelash)).setTextColor(Color.parseColor("#ffffff"));
            }

            if(type == Constants.ST_MAKEUP_EYEBALL){
                mMakeupGroupBack.setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeball_unselected));
                ((ImageView)findViewById(R.id.iv_makeup_group_eyeball)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeball_unselected));
                ((TextView)findViewById(R.id.tv_makeup_group_eyeball)).setTextColor(Color.parseColor("#ffffff"));
            }
        }
    }

    private void resetMakeup(){
        for(int i = 0; i < 9; i++){
            mCameraDisplay.removeMakeupByType(i);
            mMakeupOptionSelectedIndex.put(i , 0);
            mMakeupStrength.put(i, 80);
        }

        mFilterStrengthLayout.setVisibility(View.INVISIBLE);

        ((ImageView)findViewById(R.id.iv_makeup_group_lip)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_lip_unselected));
        ((TextView)findViewById(R.id.tv_makeup_group_lip)).setTextColor(Color.parseColor("#ffffff"));
        ((ImageView)findViewById(R.id.iv_makeup_group_cheeks)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_cheeks_unselected));
        ((TextView)findViewById(R.id.tv_makeup_group_cheeks)).setTextColor(Color.parseColor("#ffffff"));
        ((ImageView)findViewById(R.id.iv_makeup_group_face)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_face_unselected));
        ((TextView)findViewById(R.id.tv_makeup_group_face)).setTextColor(Color.parseColor("#ffffff"));
        ((ImageView)findViewById(R.id.iv_makeup_group_brow)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_brow_unselected));
        ((TextView)findViewById(R.id.tv_makeup_group_brow)).setTextColor(Color.parseColor("#ffffff"));
        ((ImageView)findViewById(R.id.iv_makeup_group_eye)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eye_unselected));
        ((TextView)findViewById(R.id.tv_makeup_group_eye)).setTextColor(Color.parseColor("#ffffff"));
        ((ImageView)findViewById(R.id.iv_makeup_group_eyeliner)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeline_unselected));
        ((TextView)findViewById(R.id.tv_makeup_group_eyeliner)).setTextColor(Color.parseColor("#ffffff"));
        ((ImageView)findViewById(R.id.iv_makeup_group_eyelash)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyelash_unselected));
        ((TextView)findViewById(R.id.tv_makeup_group_eyelash)).setTextColor(Color.parseColor("#ffffff"));

        ((ImageView)findViewById(R.id.iv_makeup_group_eyeball)).setImageDrawable(getResources().getDrawable(R.drawable.makeup_eyeball_unselected));
        ((TextView)findViewById(R.id.tv_makeup_group_eyeball)).setTextColor(Color.parseColor("#ffffff"));

        mMakeupAdapters.get("makeup_lip").setSelectedPosition(0);
        mMakeupAdapters.get("makeup_lip").notifyDataSetChanged();
        mMakeupAdapters.get("makeup_highlight").setSelectedPosition(0);
        mMakeupAdapters.get("makeup_highlight").notifyDataSetChanged();
        mMakeupAdapters.get("makeup_blush").setSelectedPosition(0);
        mMakeupAdapters.get("makeup_blush").notifyDataSetChanged();
        mMakeupAdapters.get("makeup_brow").setSelectedPosition(0);
        mMakeupAdapters.get("makeup_brow").notifyDataSetChanged();
        mMakeupAdapters.get("makeup_eye").setSelectedPosition(0);
        mMakeupAdapters.get("makeup_eye").notifyDataSetChanged();
        mMakeupAdapters.get("makeup_eyeliner").setSelectedPosition(0);
        mMakeupAdapters.get("makeup_eyeliner").notifyDataSetChanged();
        mMakeupAdapters.get("makeup_eyelash").setSelectedPosition(0);
        mMakeupAdapters.get("makeup_eyelash").notifyDataSetChanged();

        mMakeupAdapters.get("makeup_eyeball").setSelectedPosition(0);
        mMakeupAdapters.get("makeup_eyeball").notifyDataSetChanged();
    }

    private String getMakeupNameOfType(int type){
        String name = "makeup_blush";
        if(type == STMobileType.ST_MAKEUP_TYPE_BROW){
            name = "makeup_brow";
        }else if(type == STMobileType.ST_MAKEUP_TYPE_EYE){
            name = "makeup_eye";
        }else if(type == STMobileType.ST_MAKEUP_TYPE_BLUSH){
            name = "makeup_blush";
        }else if(type == STMobileType.ST_MAKEUP_TYPE_LIP){
            name = "makeup_lip";
        }else if(type == STMobileType.ST_MAKEUP_TYPE_HIGHLIGHT){
            name = "makeup_highlight";
        }else if(type == STMobileType.ST_MAKEUP_TYPE_EYELINER){
            name = "makeup_eyeliner";
        }else if(type == STMobileType.ST_MAKEUP_TYPE_EYELASH){
            name = "makeup_eyelash";
        }else if(type == STMobileType.ST_MAKEUP_TYPE_EYEBALL){
            name = "makeup_eyeball";
        }

        return name;
    }

    private boolean checkMakeUpSelect(){
        for (Map.Entry<Integer, Integer> entry : mMakeupOptionSelectedIndex.entrySet()) {
            if(entry.getValue() != 0){
                return true;
            }
        }
        return false;
    }
}
