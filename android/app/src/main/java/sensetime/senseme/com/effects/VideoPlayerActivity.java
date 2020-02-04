package sensetime.senseme.com.effects;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
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
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceView;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
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
import com.sensetime.sensearsourcemanager.SenseArMaterialService;
import com.sensetime.sensearsourcemanager.SenseArMaterialType;
import com.sensetime.stmobile.STMobileHumanActionNative;
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
import sensetime.senseme.com.effects.adapter.ObjectAdapter;
import sensetime.senseme.com.effects.adapter.StickerAdapter;
import sensetime.senseme.com.effects.adapter.StickerOptionsAdapter;
import sensetime.senseme.com.effects.display.VideoPlayerDisplay;
import sensetime.senseme.com.effects.encoder.MediaAudioEncoder;
import sensetime.senseme.com.effects.encoder.MediaEncoder;
import sensetime.senseme.com.effects.encoder.MediaMuxerWrapper;
import sensetime.senseme.com.effects.encoder.MediaVideoEncoder;
import sensetime.senseme.com.effects.glutils.STUtils;
import sensetime.senseme.com.effects.utils.Accelerometer;
import sensetime.senseme.com.effects.utils.CheckAudioPermission;
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
import sensetime.senseme.com.effects.view.ObjectItem;
import sensetime.senseme.com.effects.view.StickerItem;
import sensetime.senseme.com.effects.view.StickerOptionsItem;
import sensetime.senseme.com.effects.view.StickerState;

import static sensetime.senseme.com.effects.CameraActivity.APPID;
import static sensetime.senseme.com.effects.CameraActivity.APPKEY;
import static sensetime.senseme.com.effects.CameraActivity.GROUP_2D;
import static sensetime.senseme.com.effects.CameraActivity.GROUP_3D;
import static sensetime.senseme.com.effects.CameraActivity.GROUP_AVATAR;
import static sensetime.senseme.com.effects.CameraActivity.GROUP_BEAUTY;
import static sensetime.senseme.com.effects.CameraActivity.GROUP_BG;
import static sensetime.senseme.com.effects.CameraActivity.GROUP_FACE;
import static sensetime.senseme.com.effects.CameraActivity.GROUP_HAND;
import static sensetime.senseme.com.effects.CameraActivity.GROUP_PARTICLE;

public class VideoPlayerActivity extends Activity implements View.OnClickListener, SensorEventListener {
    private final static String TAG = "VideoPlayerActivity";
    //debug for test
    public static final boolean DEBUG = false;
    private Accelerometer mAccelerometer = null;

    private VideoPlayerDisplay mCameraDisplay;

    private FrameLayout mPreviewFrameLayout;

    private RecyclerView mStickersRecycleView;
    private RecyclerView mStickerOptionsRecycleView, mFilterOptionsRecycleView;
    private RecyclerView mBeautyBaseRecycleView;
    private StickerOptionsAdapter mStickerOptionsAdapter;
    private BeautyOptionsAdapter mBeautyOptionsAdapter;
    private BeautyItemAdapter mBeautyBaseAdapter, mBeautyProfessionalAdapter, mAdjustAdapter, mMicroAdapter;
    private ArrayList<StickerOptionsItem> mStickerOptionsList;
    private ArrayList<BeautyOptionsItem> mBeautyOptionsList;

    private HashMap<String, StickerAdapter> mStickerAdapters = new HashMap<>();
    private HashMap<String, ArrayList<StickerItem>> mStickerlists = new HashMap<>();
    private HashMap<String, BeautyItemAdapter> mBeautyItemAdapters = new HashMap<>();
    private HashMap<String, ArrayList<BeautyItem>> mBeautylists = new HashMap<>();
    private HashMap<Integer, String> mBeautyOption = new HashMap<>();
    private HashMap<Integer, Integer> mBeautyOptionSelectedIndex = new HashMap<>();

    private HashMap<String, FilterAdapter> mFilterAdapters = new HashMap<>();
    private HashMap<String, ArrayList<FilterItem>> mFilterLists = new HashMap<>();

    private ObjectAdapter mObjectAdapter;
    private List<ObjectItem> mObjectList;
    private boolean mNeedObject = false;

    private TextView mSavingTv;
    private TextView mAttributeText;

    private TextView mShowOriginBtn1, mShowOriginBtn2, mShowOriginBtn3, mStartVideoPlayer;
    private boolean mIsShowingOriginal = false;
    private TextView mShowShortVideoTime;

    private LinearLayout mFilterGroupsLinearLayout, mFilterGroupPortrait, mFilterGroupStillLife, mFilterGroupScenery, mFilterGroupFood;
    private RelativeLayout mFilterIconsRelativeLayout, mFilterStrengthLayout;
    private ImageView mFilterGroupBack;
    private TextView mFilterGroupName, mFilterStrengthText;
    private SeekBar mFilterStrengthBar;
    private int mCurrentFilterGroupIndex = -1;
    private int mCurrentFilterIndex = -1;
    private int mCurrentObjectIndex = -1;
    private int mCurrentBeautyIndex = Constants.ST_BEAUTIFY_WHITEN_STRENGTH;
    private boolean mIsPlaying = false;
    private boolean mIsVideoSaved = false;

    private float[] mBeautifyParams = {0.36f, 0.74f, 0.02f, 0.13f, 0.11f, 0.1f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f};
    private RelativeLayout mTipsLayout;
    private TextView mTipsTextView, mResetTextView;
    private ImageView mTipsImageView;
    private IndicatorSeekBar mIndicatorSeekbar;
    private Context mContext;
    private Handler mTipsHandler = new Handler();
    private Runnable mTipsRunnable;

    public static final int MSG_SAVING_IMG = 1;
    public static final int MSG_SAVED_IMG = 2;
    public static final int MSG_DRAW_OBJECT_IMAGE_AND_RECT = 3;
    public static final int MSG_DRAW_OBJECT_IMAGE = 4;
    public static final int MSG_CLEAR_OBJECT = 5;
    public static final int MSG_MISSED_OBJECT_TRACK = 6;
    public static final int MSG_DRAW_FACE_EXTRA_POINTS = 7;
    private static final int MSG_NEED_UPDATE_TIMER = 8;
    public static final int MSG_MEDIA_PREPARE_PLAY = 9;
    private static final int MSG_NEED_START_RECORDING = 10;
    public static final int MSG_STOP_RECORDING = 11;
    public static final int MSG_MEDIA_PROGRESS_UPDTAE = 12;

    public final static int MSG_UPDATE_HAND_ACTION_INFO = 100;
    public final static int MSG_RESET_HAND_ACTION_INFO = 101;
    public final static int MSG_UPDATE_BODY_ACTION_INFO = 102;
    public final static int MSG_UPDATE_FACE_EXPRESSION_INFO = 103;

    private static final int PERMISSION_REQUEST_WRITE_PERMISSION = 101;
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

    private LinearLayout mBeautyOptionsSwitch, mBaseBeautyOptions;
    private RecyclerView mFilterIcons, mBeautyOptionsRecycleView;
    private boolean mIsBeautyOptionsOpen = false;
    private int mBeautyOptionsPosition = 0;
    private RelativeLayout mVideoProgress;
    private TextView mCurrentProgress, mTotalProgress, mSaveVideo;
    private SeekBar mVideoProgressSeekbar;

    private LinearLayout mFpsInfo;
    private Button mCaptureButton;

    private ImageView mBeautyOptionsSwitchIcon, mStickerOptionsSwitchIcon;
    private TextView mBeautyOptionsSwitchText, mStickerOptionsSwitchText;
    private RelativeLayout mFilterAndBeautyOptionView;
    private LinearLayout mSelectOptions;

    private int mTimeSeconds = 0;
    private int mTimeMinutes = 0;
    private Timer mTimer;
    private TimerTask mTimerTask;
    private boolean mIsRecording = false;
    private String mVideoFilePath = null;
    private boolean mIsHasAudioPermission = false;

    private Switch mFaceExtraInfoSwitch, mEyeBallContourSwitch, mHandActionSwitch, mBodySwitch;

    private String mVideoPath = null;
    private int mBackCount = 0;
    private Switch mEncodeVideoSwitch;
    private boolean mNeedEncodeVideo = false;

    private SensorManager mSensorManager;
    private Sensor mRotation;
    //记录用户最后一次点击的素材id ,包括还未下载的，方便下载完成后，直接应用素材
    private String preMaterialId = "";

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
                    new Handler().postDelayed(new Runnable(){
                        public void run() {
                            mSavingTv.setVisibility(View.GONE);
                        }
                    }, 1000);

                    break;
                case MSG_DRAW_OBJECT_IMAGE_AND_RECT:
                    Rect indexRect = (Rect)msg.obj;
                    drawObjectImage(indexRect, true);

                    break;
                case MSG_DRAW_OBJECT_IMAGE:
                    Rect rect = (Rect)msg.obj;
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
                    STPoint[] points = (STPoint[])msg.obj;
                    drawFaceExtraPoints(points);
                    break;

                case MSG_NEED_UPDATE_TIMER:
                    break;

                case MSG_MEDIA_PREPARE_PLAY:
                    mTotalProgress.setText(STUtils.getTimeFormMs(msg.arg1));
                    mCurrentProgress.setText(STUtils.getTimeFormMs(0));
                    mVideoProgressSeekbar.setMax(msg.arg1);
                    break;

                case MSG_NEED_START_RECORDING:
                    //开始录制
                    startRecording();
                    closeTableView();
                    disableShowLayouts();
                    mCameraDisplay.StartPlayVideo();
                    mCameraDisplay.setmIsFirstPlaying(true);
                    mIsPlaying = true;
                    break;

                case MSG_STOP_RECORDING:
                    if(!mIsRecording){
                        return;
                    }
                    mIsRecording = false;
                    mSaveVideo.setClickable(true);
                    new Handler().postDelayed(new Runnable(){
                        public void run() {
                            //结束录制
                            if(mIsRecording){
                                return;
                            }
                            stopRecording();

                        }
                    }, 100);
                    break;
                case MSG_MEDIA_PROGRESS_UPDTAE:
                    int position = msg.arg1;
                    mVideoProgressSeekbar.setProgress(position);
                    mCurrentProgress.setText(STUtils.getTimeFormMs(position));
                    break;

                case MSG_UPDATE_HAND_ACTION_INFO:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(mCameraDisplay != null){
                                showHandActionInfo(mCameraDisplay.getHandActionInfo());
                            }
                        }
                    });
                    break;
                case MSG_RESET_HAND_ACTION_INFO:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(mCameraDisplay != null){
                                resetHandActionInfo();
                            }
                        }
                    });
                    break;

                case MSG_UPDATE_BODY_ACTION_INFO:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(mCameraDisplay != null){
                                showBodyActionInfo(mCameraDisplay.getBodyActionInfo());
                            }
                        }
                    });
                    break;

                case MSG_UPDATE_FACE_EXPRESSION_INFO:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(mCameraDisplay != null){
                                showFaceExpressionInfo(mCameraDisplay.getFaceExpressionInfo());
                            }
                        }
                    });
                    break;
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        //进程后台时被系统强制kill，需重新checkLicense
        if(savedInstanceState!=null && savedInstanceState.getBoolean("process_killed")) {
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

        if(DEBUG){
            findViewById(R.id.rl_test_layout).setVisibility(View.VISIBLE);
            findViewById(R.id.ll_face_expression).setVisibility(View.VISIBLE);
            findViewById(R.id.ll_hand_action_info).setVisibility(View.VISIBLE);

            LogUtils.setIsLoggable(true);
        }

        resetFilterView();
        mShowOriginBtn1.setVisibility(View.VISIBLE);
        mShowOriginBtn2.setVisibility(View.INVISIBLE);
        mShowOriginBtn3.setVisibility(View.INVISIBLE);

        //滤镜默认选中babypink效果
        setDefaultFilter();

        mSensorManager=(SensorManager)getSystemService(Context.SENSOR_SERVICE);
        List<Sensor> sensors=mSensorManager.getSensorList(Sensor.TYPE_ALL);
        //todo 判断是否存在rotation vector sensor
        mRotation=mSensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR);
    }

    private void initView() {
        mVideoPath = this.getIntent().getStringExtra("VideoPath");

        if(mVideoPath == null || !mVideoPath.endsWith(".mp4")){
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Toast.makeText(getApplicationContext(), "请选择mp4格式视频文件！", Toast.LENGTH_SHORT).show();
                }
            });

            finish();
        }

        mAccelerometer = new Accelerometer(getApplicationContext());
        GLSurfaceView glSurfaceView = (GLSurfaceView) findViewById(R.id.id_gl_sv);
        mSurfaceViewOverlap = (SurfaceView) findViewById(R.id.surfaceViewOverlap);
        mPreviewFrameLayout = (FrameLayout) findViewById(R.id.id_preview_layout);

        mCameraDisplay = new VideoPlayerDisplay(getApplicationContext(), glSurfaceView, mVideoPath);
        mCameraDisplay.setHandler(mHandler);

        mIndicatorSeekbar = (IndicatorSeekBar) findViewById(R.id.beauty_item_seekbar);
        mIndicatorSeekbar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if(fromUser){
                    if(checkMicroType()){
                        mIndicatorSeekbar.updateTextview(STUtils.convertToDisplay(progress));
                        mCameraDisplay.setBeautyParam(mCurrentBeautyIndex, (float) STUtils.convertToDisplay(progress) / 100f);
                        mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).setProgress(STUtils.convertToDisplay(progress));
                    }else{
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
        LinearLayoutManager ms= new LinearLayoutManager(this);
        ms.setOrientation(LinearLayoutManager.HORIZONTAL);
        mBeautyBaseRecycleView.setLayoutManager(ms);
        mBeautyBaseRecycleView.addItemDecoration(new BeautyItemDecoration(STUtils.dip2px(this, 15)));

        ArrayList mBeautyBaseItem = new ArrayList<>();
        mBeautyBaseItem.add(new BeautyItem("美白", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_whiten_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_whiten_selected)));
        mBeautyBaseItem.add(new BeautyItem("红润", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_redden_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_redden_selected)));
        mBeautyBaseItem.add(new BeautyItem("磨皮", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_smooth_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_smooth_selected)));
        mBeautyBaseItem.add(new BeautyItem("去高光", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_dehighlight_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_dehighlight_selected)));
        ((BeautyItem)mBeautyBaseItem.get(0)).setProgress((int)(mBeautifyParams[2]* 100));
        ((BeautyItem)mBeautyBaseItem.get(1)).setProgress((int)(mBeautifyParams[0]* 100));
        ((BeautyItem)mBeautyBaseItem.get(2)).setProgress((int)(mBeautifyParams[1]* 100));
        ((BeautyItem)mBeautyBaseItem.get(3)).setProgress((int)(mBeautifyParams[8]* 100));
        mIndicatorSeekbar.getSeekBar().setProgress((int)(mBeautifyParams[2]* 100));
        mIndicatorSeekbar.updateTextview((int)(mBeautifyParams[2]* 100));

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

        ((BeautyItem)mProfessionalBeautyItem.get(0)).setProgress((int)(mBeautifyParams[4]* 100));
        ((BeautyItem)mProfessionalBeautyItem.get(1)).setProgress((int)(mBeautifyParams[3]* 100));
        ((BeautyItem)mProfessionalBeautyItem.get(2)).setProgress((int)(mBeautifyParams[5]* 100));
        ((BeautyItem)mProfessionalBeautyItem.get(3)).setProgress((int)(mBeautifyParams[9]* 100));
        ((BeautyItem)mProfessionalBeautyItem.get(4)).setProgress((int)(mBeautifyParams[26]* 100));

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

        ArrayList mAdjustBeautyItem = new ArrayList<>();
        mAdjustBeautyItem.add(new BeautyItem("对比度", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_contrast_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_contrast_selected)));
        mAdjustBeautyItem.add(new BeautyItem("饱和度", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_saturation_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_saturation_selected)));
        ((BeautyItem)mAdjustBeautyItem.get(0)).setProgress((int)(mBeautifyParams[6]* 100));
        ((BeautyItem)mAdjustBeautyItem.get(1)).setProgress((int)(mBeautifyParams[7]* 100));
        mBeautylists.put("adjustBeauty", mAdjustBeautyItem);
        mAdjustAdapter = new BeautyItemAdapter(this, mAdjustBeautyItem);
        mBeautyItemAdapters.put("adjustBeauty", mAdjustAdapter);
        mBeautyOption.put(4, "adjustBeauty");

        mBeautyOptionSelectedIndex.put(0, 0);
        mBeautyOptionSelectedIndex.put(1, 0);
        mBeautyOptionSelectedIndex.put(2, 0);
        mBeautyOptionSelectedIndex.put(4, 0);

        mStickerOptionsRecycleView = (RecyclerView) findViewById(R.id.rv_sticker_options);
        mStickerOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
        mStickerOptionsRecycleView.addItemDecoration(new SpaceItemDecoration(0));

        mStickersRecycleView = (RecyclerView) findViewById(R.id.rv_sticker_icons);
        mStickersRecycleView.setLayoutManager(new GridLayoutManager(this, 6));
        mStickersRecycleView.addItemDecoration(new SpaceItemDecoration(0));

        mFilterOptionsRecycleView = (RecyclerView) findViewById(R.id.rv_filter_icons);
        mFilterOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
        mFilterOptionsRecycleView.addItemDecoration(new SpaceItemDecoration(0));


        mStickerOptionsList = new ArrayList<>();
        //2d
        mStickerOptionsList.add(0, new StickerOptionsItem(GROUP_2D, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_2d_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_2d_selected)));
        //3d
        mStickerOptionsList.add(1, new StickerOptionsItem(GROUP_3D, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_3d_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_3d_selected)));
        //手势贴纸
        mStickerOptionsList.add(2, new StickerOptionsItem(GROUP_HAND, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_hand_action_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_hand_action_selected)));
        //背景贴纸
        mStickerOptionsList.add(3, new StickerOptionsItem(GROUP_BG, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_bg_segment_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_bg_segment_selected)));
        //脸部变形贴纸
        mStickerOptionsList.add(4, new StickerOptionsItem(GROUP_FACE, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_dedormation_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_dedormation_selected)));
        //avatar
        mStickerOptionsList.add(5, new StickerOptionsItem(GROUP_AVATAR, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_avatar_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_avatar_selected)));
        //美妆贴纸
        mStickerOptionsList.add(6, new StickerOptionsItem(GROUP_BEAUTY, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_face_morph_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.sticker_face_morph_selected)));
        //粒子贴纸
        mStickerOptionsList.add(7, new StickerOptionsItem(GROUP_PARTICLE, BitmapFactory.decodeResource(mContext.getResources(), R.drawable.particles_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.particles_selected)));
        //通用物体跟踪
        mStickerOptionsList.add(8, new StickerOptionsItem("object_track", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.object_track_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.object_track_selected)));

        mStickerOptionsAdapter = new StickerOptionsAdapter(mStickerOptionsList, this);

        findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));

        mFilterAndBeautyOptionView = (RelativeLayout) findViewById(R.id.rv_beauty_and_filter_options);

        mBeautyOptionsRecycleView = (RecyclerView) findViewById(R.id.rv_beauty_options);
        mBeautyOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
        mBeautyOptionsRecycleView.addItemDecoration(new SpaceItemDecoration(0));

        mBeautyOptionsList = new ArrayList<>();
        mBeautyOptionsList.add(0, new BeautyOptionsItem("基础美颜"));
        mBeautyOptionsList.add(1, new BeautyOptionsItem("美形"));
        mBeautyOptionsList.add(2, new BeautyOptionsItem("微整形"));
        mBeautyOptionsList.add(3, new BeautyOptionsItem("滤镜"));
        mBeautyOptionsList.add(4, new BeautyOptionsItem("调整"));

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

                if(mCurrentFilterGroupIndex == 0 && mCurrentFilterIndex != -1){
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

                if(mCurrentFilterGroupIndex == 1 && mCurrentFilterIndex != -1){
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

                if(mCurrentFilterGroupIndex == 2 && mCurrentFilterIndex != -1){
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

                if(mCurrentFilterGroupIndex == 3 && mCurrentFilterIndex != -1){
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
                mCameraDisplay.setFilterStrength((float)progress/100);
                mFilterStrengthText.setText(progress+"");
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {}

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {}
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

        findViewById(R.id.tv_cancel).setVisibility(View.INVISIBLE);
        findViewById(R.id.tv_capture).setVisibility(View.INVISIBLE);

        mFpsInfo = (LinearLayout) findViewById(R.id.ll_fps_info);
        mFpsInfo.setVisibility(View.VISIBLE);

        mCaptureButton = (Button) findViewById(R.id.btn_capture_picture);
        mCaptureButton.setVisibility(View.GONE);
        mSelectOptions = (LinearLayout)findViewById(R.id.ll_select_options);
        mSelectOptions.setBackgroundColor(Color.parseColor("#00000000"));

        mStartVideoPlayer = (TextView)findViewById(R.id.tv_video_player_start);
        mStartVideoPlayer.setVisibility(View.VISIBLE);
        mStartVideoPlayer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mStartVideoPlayer.setVisibility(View.GONE);
                mSaveVideo.setVisibility(View.VISIBLE);
                mSaveVideo.setClickable(false);
                mBackCount++;
                Message msg = mHandler.obtainMessage(MSG_NEED_START_RECORDING);
                mHandler.sendMessage(msg);
                mIsRecording = true;
            }
        });

        ((ImageView)findViewById(R.id.iv_setting_options_switch)).setImageDrawable(getResources().getDrawable(R.drawable.back_button));
        findViewById(R.id.iv_setting_options_switch).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mBackCount > 0){
                    if(mIsRecording){
                        stopRecording();
                        mIsRecording = false;
                    }
                    if(mIsPlaying){
                        mCameraDisplay.StopPlayViedo();
                        mIsPlaying =false;
                    }
                    if(!mIsVideoSaved && mVideoFilePath != null){
                        File file = new File(mVideoFilePath);
                        if(file != null){
                            file.delete();
                        }
                    }
                    enableShowLayouts();
                    mStartVideoPlayer.setVisibility(View.VISIBLE);
                    mSaveVideo.setVisibility(View.GONE);
                    mBackCount--;
                }else{
                    finish();
                }
            }
        });

        mResetTextView = (TextView)findViewById(R.id.reset);

        mVideoProgress = (RelativeLayout) findViewById(R.id.rl_video_progress);
        mCurrentProgress = (TextView) findViewById(R.id.tv_current_progress);
        mTotalProgress = (TextView) findViewById(R.id.tv_total_progress);
        mVideoProgressSeekbar = (SeekBar) findViewById(R.id.sb_video_progress_seekbar);
        mVideoProgressSeekbar.setEnabled(false);
        mSaveVideo = (TextView) findViewById(R.id.tv_save_video);
        mSaveVideo.setOnClickListener(this);
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

                if(position == 0){
                    mCameraDisplay.enableFilter(false);
                }else{
                    mCameraDisplay.setFilterStyle(mFilterLists.get("filter_portrait").get(position).model);
                    mCameraDisplay.enableFilter(true);
                    mCurrentFilterIndex = position;

                    mFilterStrengthLayout.setVisibility(View.VISIBLE);

                    mShowOriginBtn1.setVisibility(View.INVISIBLE);
                    mShowOriginBtn2.setVisibility(View.INVISIBLE);
                    mShowOriginBtn3.setVisibility(View.VISIBLE);
                    ((ImageView)findViewById(R.id.iv_filter_group_portrait)).setImageDrawable(getResources().getDrawable(R.drawable.icon_portrait_selected));
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

                if(position == 0){
                    mCameraDisplay.enableFilter(false);
                }else{
                    mCameraDisplay.setFilterStyle(mFilterLists.get("filter_scenery").get(position).model);
                    mCameraDisplay.enableFilter(true);
                    mCurrentFilterIndex = position;

                    mFilterStrengthLayout.setVisibility(View.VISIBLE);

                    mShowOriginBtn1.setVisibility(View.INVISIBLE);
                    mShowOriginBtn2.setVisibility(View.INVISIBLE);
                    mShowOriginBtn3.setVisibility(View.VISIBLE);
                    ((ImageView)findViewById(R.id.iv_filter_group_scenery)).setImageDrawable(getResources().getDrawable(R.drawable.icon_scenery_selected));
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

                if(position == 0){
                    mCameraDisplay.enableFilter(false);
                }else{
                    mCameraDisplay.setFilterStyle(mFilterLists.get("filter_still_life").get(position).model);
                    mCameraDisplay.enableFilter(true);
                    mCurrentFilterIndex = position;

                    mFilterStrengthLayout.setVisibility(View.VISIBLE);

                    mShowOriginBtn1.setVisibility(View.INVISIBLE);
                    mShowOriginBtn2.setVisibility(View.INVISIBLE);
                    mShowOriginBtn3.setVisibility(View.VISIBLE);
                    ((ImageView)findViewById(R.id.iv_filter_group_still_life)).setImageDrawable(getResources().getDrawable(R.drawable.icon_still_life_selected));
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

                if(position == 0){
                    mCameraDisplay.enableFilter(false);
                }else{
                    mCameraDisplay.setFilterStyle(mFilterLists.get("filter_food").get(position).model);
                    mCameraDisplay.enableFilter(true);
                    mCurrentFilterIndex = position;

                    mFilterStrengthLayout.setVisibility(View.VISIBLE);

                    mShowOriginBtn1.setVisibility(View.INVISIBLE);
                    mShowOriginBtn2.setVisibility(View.INVISIBLE);
                    mShowOriginBtn3.setVisibility(View.VISIBLE);
                    ((ImageView)findViewById(R.id.iv_filter_group_food)).setImageDrawable(getResources().getDrawable(R.drawable.icon_food_selected));
                    ((TextView) findViewById(R.id.tv_filter_group_food)).setTextColor(Color.parseColor("#c460e1"));
                }

                mFilterAdapters.get("filter_food").notifyDataSetChanged();
            }
        });

        mBeautyOptionsAdapter.setClickBeautyListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int position = Integer.parseInt(v.getTag().toString());
                mBeautyOptionsAdapter.setSelectedPosition(position);
                mBeautyOptionsPosition = position;
                mResetTextView.setVisibility(View.VISIBLE);
                if(mBeautyOptionsPosition != 3){
                    calculateBeautyIndex(mBeautyOptionsPosition, mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition));
                    mIndicatorSeekbar.setVisibility(View.VISIBLE);
                    if(mBeautyOptionsPosition == 2 && mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition) != 0 && mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition) != 3){
                        mIndicatorSeekbar.getSeekBar().setProgress(STUtils.convertToData(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(position)).getProgress()));
                    }else{
                        mIndicatorSeekbar.getSeekBar().setProgress(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(position)).getProgress());
                    }
                    mIndicatorSeekbar.updateTextview(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(position)).getProgress());
                }else{
                    mIndicatorSeekbar.setVisibility(View.INVISIBLE);
                }
                mFilterIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mShowOriginBtn3.setVisibility(View.VISIBLE);
                mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                if(position == 0){
                    mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                    mBaseBeautyOptions.setVisibility(View.VISIBLE);
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("baseBeauty"));
                }else if(position == 1){
                    mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                    mBaseBeautyOptions.setVisibility(View.VISIBLE);
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("professionalBeauty"));
                }else if(position == 2){
                    mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                    mBaseBeautyOptions.setVisibility(View.VISIBLE);
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("microBeauty"));
                }else if(position == 3){
                    mFilterGroupsLinearLayout.setVisibility(View.VISIBLE);
                    mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                }else if(position == 4){
                    mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                    mBaseBeautyOptions.setVisibility(View.VISIBLE);
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("adjustBeauty"));
                }
                mBeautyOptionsAdapter.notifyDataSetChanged();
            }
        });

        mObjectAdapter.setClickObjectListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int position = Integer.parseInt(v.getTag().toString());

                if(mCurrentObjectIndex == position){
                    mCurrentObjectIndex = -1;
                    mObjectAdapter.setSelectedPosition(-1);
                    mObjectAdapter.notifyDataSetChanged();
                    mCameraDisplay.enableObject(false);
                }else {
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

        for(Map.Entry<String, BeautyItemAdapter> entry : mBeautyItemAdapters.entrySet()){
            final BeautyItemAdapter adapter = entry.getValue();
            adapter.setClickBeautyListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    int position = Integer.parseInt(v.getTag().toString());
                    adapter.setSelectedPosition(position);
                    mBeautyOptionSelectedIndex.put(mBeautyOptionsPosition, position);
                    if(checkMicroType()){
                        mIndicatorSeekbar.getSeekBar().setProgress(STUtils.convertToData(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(position).getProgress()));
                    }else{
                        mIndicatorSeekbar.getSeekBar().setProgress(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(position).getProgress());
                    }
                    mIndicatorSeekbar.updateTextview(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(position).getProgress());
                    calculateBeautyIndex(mBeautyOptionsPosition, position);
                    adapter.notifyDataSetChanged();
                }
            });
        }

        mShowOriginBtn1 = (TextView)findViewById(R.id.tv_show_origin1);
        mShowOriginBtn1.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                // TODO Auto-generated method stub
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    mCameraDisplay.setShowOriginal(true);
                    mIsShowingOriginal = true;
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mCameraDisplay.setShowOriginal(false);
                    mIsShowingOriginal = false;
                }
                return true;
            }
        });
        mShowOriginBtn1.setVisibility(View.VISIBLE);

        mShowOriginBtn2 = (TextView)findViewById(R.id.tv_show_origin2);
        mShowOriginBtn2.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                // TODO Auto-generated method stub
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    mCameraDisplay.setShowOriginal(true);
                    mIsShowingOriginal = true;
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mCameraDisplay.setShowOriginal(false);
                    mIsShowingOriginal = false;
                }
                return true;
            }
        });
        mShowOriginBtn2.setVisibility(View.INVISIBLE);

        mShowOriginBtn3 = (TextView)findViewById(R.id.tv_show_origin3);
        mShowOriginBtn3.setOnTouchListener(new View.OnTouchListener() {

            @Override
            public boolean onTouch(View v, MotionEvent event) {
                // TODO Auto-generated method stub
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    mCameraDisplay.setShowOriginal(true);
                    mIsShowingOriginal = true;
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mCameraDisplay.setShowOriginal(false);
                    mIsShowingOriginal = false;
                }
                return true;
            }
        });
        mShowOriginBtn3.setVisibility(View.INVISIBLE);

        mShowShortVideoTime = (TextView) findViewById(R.id.tv_short_video_time);

        findViewById(R.id.rv_close_sticker).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //重置所有状态为为选中状态
                for (StickerOptionsItem optionsItem : mStickerOptionsList) {
                    if (optionsItem.name.equals("sticker_new_engine")) {
                        continue;
                    }else if(optionsItem.name.equals("object_track")){
                        continue;
                    }else{
                        if(mStickerAdapters.get(optionsItem.name) != null){
                            mStickerAdapters.get(optionsItem.name).setSelectedPosition(-1);
                            mStickerAdapters.get(optionsItem.name).notifyDataSetChanged();
                        }
                    }
                }

                mCurrentStickerPosition = -1;
                mCameraDisplay.setShowSticker(null);
                mCameraDisplay.enableSticker(false);

                mCurrentObjectIndex = -1;
                mObjectAdapter.setSelectedPosition(-1);
                mObjectAdapter.notifyDataSetChanged();
                mCameraDisplay.enableObject(false);

                findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));
            }
        });

        findViewById(R.id.id_tv_changecamera).setVisibility(View.INVISIBLE);
        findViewById(R.id.iv_mode_picture).setVisibility(View.INVISIBLE);

        mCameraDisplay.enableBeautify(true);
        mIsHasAudioPermission = CheckAudioPermission.isHasPermission(mContext);

        if(DEBUG){
            //for test add sub model
            mBodySwitch = (Switch)findViewById(R.id.sw_add_body_model_switch);
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

            mFaceExtraInfoSwitch = (Switch)findViewById(R.id.sw_add_face_extra_model);
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

            mEyeBallContourSwitch = (Switch)findViewById(R.id.sw_add_iris_model);
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

            mHandActionSwitch = (Switch)findViewById(R.id.sw_add_hand_action_model);
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
                if(mBeautyOptionsPosition != 3){
                    resetSetBeautyParam(mBeautyOptionsPosition);
                    resetBeautyLists(mBeautyOptionsPosition);
                    mBeautyItemAdapters.get(mBeautyOption.get(mBeautyOptionsPosition)).notifyDataSetChanged();
                    if(checkMicroType()){
                        mIndicatorSeekbar.getSeekBar().setProgress(STUtils.convertToData(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).getProgress()));
                    }else{
                        mIndicatorSeekbar.getSeekBar().setProgress(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).getProgress());
                    }
                    mIndicatorSeekbar.updateTextview(mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).getProgress());
                }else{
                    setDefaultFilter();
                    mFilterStrengthBar.setProgress(65);
                }
            }
        });
    }

    public void setDefaultFilter(){
        resetFilterView();
        if(mFilterLists.get("filter_portrait").size() > 0){
            for(int i = 0; i < mFilterLists.get("filter_portrait").size(); i++){
                if(mFilterLists.get("filter_portrait").get(i).name.equals("babypink")){
                    mCurrentFilterIndex = i;
                }
            }

            if(mCurrentFilterIndex > 0){
                mCurrentFilterGroupIndex = 0;
                mFilterAdapters.get("filter_portrait").setSelectedPosition(mCurrentFilterIndex);
                mCameraDisplay.setFilterStyle(mFilterLists.get("filter_portrait").get(mCurrentFilterIndex).model);
                mCameraDisplay.enableFilter(true);

                ((ImageView)findViewById(R.id.iv_filter_group_portrait)).setImageDrawable(getResources().getDrawable(R.drawable.icon_portrait_selected));
                ((TextView) findViewById(R.id.tv_filter_group_portrait)).setTextColor(Color.parseColor("#c460e1"));
                mFilterAdapters.get("filter_portrait").notifyDataSetChanged();
            }
        }
    }

    private void resetSetBeautyParam(int beautyOptionsPosition){
        switch (beautyOptionsPosition){
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
            case 4:
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_CONSTRACT_STRENGTH, (mBeautifyParams[6]));
                mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SATURATION_STRENGTH, (mBeautifyParams[7]));
                break;
        }
    }

    private void resetBeautyLists(int beautyOptionsPosition){
        switch (beautyOptionsPosition){
            case 0:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int)(mBeautifyParams[2] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int)(mBeautifyParams[0] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(2).setProgress((int)(mBeautifyParams[1] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(3).setProgress((int)(mBeautifyParams[8] * 100));
                break;
            case 1:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int)(mBeautifyParams[4] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int)(mBeautifyParams[3] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(2).setProgress((int)(mBeautifyParams[5] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(3).setProgress((int)(mBeautifyParams[9] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(4).setProgress((int)(mBeautifyParams[26] * 100));
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
            case 4:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int)(mBeautifyParams[6] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int)(mBeautifyParams[7] * 100));
                break;
        }
    }

    private void calculateBeautyIndex(int beautyOptionPosition, int selectPosition){
        switch (beautyOptionPosition){
            case 0:
                switch (selectPosition){
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
                switch (selectPosition){
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
                switch (selectPosition){
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
            case 4:
                switch (selectPosition){
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

    private void initStickerAdapter(final String stickerClassName, final int index){
        mStickerAdapters.get(stickerClassName).setClickStickerListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTipsLayout.setVisibility(View.GONE);
                int position = Integer.parseInt(v.getTag().toString());

                if(mCurrentStickerOptionsIndex == index && mCurrentStickerPosition == position){
                    mStickerAdapters.get(stickerClassName).setSelectedPosition(-1);
                    mCurrentStickerOptionsIndex = -1;
                    mCurrentStickerPosition = -1;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));
                    mCameraDisplay.enableSticker(false);
                    mCameraDisplay.setShowSticker(null);

                }else{
                    mCurrentStickerOptionsIndex = index;
                    mCurrentStickerPosition = position;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));

                    mStickerAdapters.get(stickerClassName).setSelectedPosition(position);
                    mCameraDisplay.enableSticker(true);
                    mCameraDisplay.setShowSticker(mStickerlists.get(stickerClassName).get(position).path);

                    long action = mCameraDisplay.getStickerTriggerAction();
                    showActiveTips(action);
                }

                mStickerAdapters.get(stickerClassName).notifyDataSetChanged();
            }
        });
    }

    private void startShowCpuInfo() {
        mCpuInofThread = new Thread() {
            @Override
            public void run() {
                super.run();
                while (true) {
                    final String cpuRate;
                    if(Build.VERSION.SDK_INT <= 25){
                        cpuRate = String.valueOf(getProcessCpuRate());
                    }else{
                        cpuRate = "null";
                    }

                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            ((TextView) findViewById(R.id.tv_cpu_radio)).setText(String.valueOf(cpuRate));
                            if(mCameraDisplay != null){
                                ((TextView) findViewById(R.id.tv_frame_radio)).setText(String.valueOf(mCameraDisplay.getFrameCost()));
                                ((TextView) findViewById(R.id.tv_fps_info)).setText(mCameraDisplay.getFpsInfo() + "");
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
            mCpuInofThread.interrupt();
            //mCpuInofThread.stop();
            mCpuInofThread = null;
        }
    }

    private void showActiveTips(long actionNum) {
        if (actionNum != -1 && actionNum != 0) {
            mTipsLayout.setVisibility(View.VISIBLE);
        }

        if((actionNum & STMobileHumanActionNative.ST_MOBILE_EYE_BLINK) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_blink);
            mTipsTextView.setText("请眨眨眼~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_MOUTH_AH) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_mouth);
            mTipsTextView.setText("张嘴有惊喜~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HEAD_YAW) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_shake);
            mTipsTextView.setText("请摇摇头~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HEAD_PITCH) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_nod);
            mTipsTextView.setText("请点点头~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_BROW_JUMP) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_frown);
            mTipsTextView.setText("挑眉有惊喜~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_PALM) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_palm_selected);
            mTipsTextView.setText("请伸出手掌~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_LOVE) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_heart_hand_selected);
            mTipsTextView.setText("双手比个爱心吧~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_HOLDUP) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_palm_up_selected);
            mTipsTextView.setText("请托手~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_CONGRATULATE) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_congratulate_selected);
            mTipsTextView.setText("抱个拳吧~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_HEART) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_finger_heart_selected);
            mTipsTextView.setText("单手比个爱心吧~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_GOOD) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_thumb_selected);
            mTipsTextView.setText("请伸出大拇指~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_OK) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_ok_selected);
            mTipsTextView.setText("请亮出OK手势~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_SCISSOR) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_scissor_selected);
            mTipsTextView.setText("请比个剪刀手~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_PISTOL) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_pistol_selected);
            mTipsTextView.setText("请比个手枪~");
        }else if((actionNum & STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_INDEX) > 0){
            mTipsImageView.setImageResource(R.drawable.ic_trigger_one_finger_selected);
            mTipsTextView.setText("请伸出食指~");
        }else{
            mTipsImageView.setImageBitmap(null);
            mTipsTextView.setText("");
            mTipsLayout.setVisibility(View.INVISIBLE);
        }

        mTipsLayout.setVisibility(View.VISIBLE);
        if(mTipsRunnable != null){
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
                mResetTextView.setVisibility(View.INVISIBLE);
                mFilterGroupsLinearLayout.setVisibility(View.INVISIBLE);
                mFilterIconsRelativeLayout.setVisibility(View.INVISIBLE);
                mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                mFilterAndBeautyOptionView.setVisibility(View.INVISIBLE);
                mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                mIsBeautyOptionsOpen = false;
                break;

            case R.id.ll_beauty_options_switch:
                mStickerOptionsSwitch.setVisibility(View.INVISIBLE);
                mBeautyOptionsSwitch.setVisibility(View.INVISIBLE);
                mBaseBeautyOptions.setVisibility(View.VISIBLE);
                mSelectOptions.setBackgroundColor(Color.parseColor("#80000000"));
                mIndicatorSeekbar.setVisibility(View.VISIBLE);
                if(mBeautyOptionsPosition == 3){
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

                break;


            case R.id.id_gl_sv:
                mSelectOptions.setBackgroundColor(Color.parseColor("#00000000"));
                mStickerOptionsSwitch.setVisibility(View.VISIBLE);
                mBeautyOptionsSwitch.setVisibility(View.VISIBLE);
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

                mShowOriginBtn1.setVisibility(View.VISIBLE);
                mShowOriginBtn2.setVisibility(View.INVISIBLE);
                mShowOriginBtn3.setVisibility(View.INVISIBLE);
                mIndicatorSeekbar.setVisibility(View.INVISIBLE);
                mResetTextView.setVisibility(View.INVISIBLE);
                break;

            case R.id.tv_cancel:
                finish();
                break;
            case R.id.tv_save_video:
                notifyVideoUpdate(mVideoFilePath);
                mIsVideoSaved = true;
                mSavingTv.setVisibility(View.VISIBLE);
                mSavingTv.setText("视频保存成功");
                mSaveVideo.setClickable(false);
                new Handler().postDelayed(new Runnable(){
                    public void run() {
                        mSavingTv.setVisibility(View.GONE);
                    }
                }, 3000);
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

    @Override
    protected void onSaveInstanceState(Bundle savedInstanceState) {
        savedInstanceState.putBoolean("process_killed",true);
        super.onSaveInstanceState(savedInstanceState);
    }

    @Override
    protected void onResume() {
        LogUtils.i(TAG, "onResume");
        super.onResume();
        mAccelerometer.start();
        mSensorManager.registerListener(this,mRotation, SensorManager.SENSOR_DELAY_GAME);

        mCameraDisplay.onResume();
        mCameraDisplay.setShowOriginal(false);

        mStartVideoPlayer.setClickable(true);
        mStartVideoPlayer.setTextColor(Color.RED);

        resetTimer();
        mIsRecording = false;
//        startShowCpuInfo();
        mIsPaused = false;
    }

    private boolean mIsPaused = false;

    @Override
    protected void onPause() {
        super.onPause();
        LogUtils.i(TAG, "onPause");

        //if is recording, stop recording
        mIsPaused = true;
        if(mIsRecording){
            mHandler.removeMessages(MSG_STOP_RECORDING);
            stopRecording();
            mIsRecording = false;
        }

        if(mVideoFilePath != null){
            File file = new File(mVideoFilePath);
            if(file != null){
                file.delete();
            }
        }

        if (!mPermissionDialogShowing) {
            mAccelerometer.stop();
            mCameraDisplay.onPause();
        }
        mStartVideoPlayer.setVisibility(View.VISIBLE);
        mSaveVideo.setClickable(false);
        mBackCount = 0;
        enableShowLayouts();
        stopShowCpuInfo();
    }

    @Override
    protected void onDestroy() {

        super.onDestroy();
        mCameraDisplay.onDestroy();
        mStickerAdapters.clear();
        mStickerlists.clear();
        mFilterAdapters.clear();
        mFilterLists.clear();
        mObjectList.clear();
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

        if(totalCpuTime1 != totalCupTime2){
            float rate = (float) (100 * (processCpuTime2 - processCpuTime1) / (totalCupTime2 - totalCpuTime1));
            if(rate >= 0.0f || rate <= 100.0f){
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

            mHandler.sendEmptyMessage(VideoPlayerActivity.MSG_SAVED_IMG);
        }
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

            MediaScannerConnection.scanFile(this, new String[]{videoFilePath}, null, null);
        }
        mVideoFilePath = null;
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

        if(mIsStickerOptionsOpen || mIsBeautyOptionsOpen){
            closeTableView();
        }

        switch (eventAction) {
            case MotionEvent.ACTION_DOWN:
                if((int) event.getX() >= indexRect.left && (int) event.getX() <= indexRect.right &&
                        (int) event.getY() >= indexRect.top && (int) event.getY() <= indexRect.bottom){
                    mCanMove = true;
                    mCameraDisplay.disableObjectTracking();
                }
                break;

            case MotionEvent.ACTION_MOVE:
                if(mCanMove){
                    mIndexX = (int) event.getX();
                    mIndexY = (int) event.getY();
                    mCameraDisplay.setIndexRect(mIndexX - indexRect.width()/2, mIndexY -indexRect.width()/2, true);
                }

                break;

            case MotionEvent.ACTION_UP:

                if(mCanMove){
                    mIndexX = (int) event.getX();
                    mIndexY = (int) event.getY();
                    mCameraDisplay.setIndexRect(mIndexX - indexRect.width()/2, mIndexY - indexRect.width()/2, false);
                    mCameraDisplay.setObjectTrackRect();

                    mCanMove = false;
                }
                break;
        }

        return false;
    }


    private void drawObjectImage(final Rect rect, final boolean needDrawRect){
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
                if(needDrawRect){
                    canvas.drawRect(rect, mPaint);
                }
                canvas.drawBitmap(mGuideBitmap, new Rect(0, 0, mGuideBitmap.getWidth(), mGuideBitmap.getHeight()), rect, mPaint);

                mSurfaceViewOverlap.getHolder().unlockCanvasAndPost(canvas);
            }
        });
    }

    private void clearObjectImage(){
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

    private void drawFaceExtraPoints(final STPoint[] points){
        if(points == null || points.length == 0){
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

    /**
     * callback methods from encoder
     */
    private final MediaEncoder.MediaEncoderListener mMediaEncoderListener = new MediaEncoder.MediaEncoderListener() {
        @Override
        public void onPrepared(final MediaEncoder encoder) {
            if (encoder instanceof MediaVideoEncoder && mCameraDisplay != null)
                mCameraDisplay.setVideoEncoder((MediaVideoEncoder)encoder);
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
            mMuxer = new MediaMuxerWrapper(".mp4");	// if you record audio only, ".m4a" is also OK.

            int videoWidth = mCameraDisplay.getPreviewWidth();
            int videoHeight = mCameraDisplay.getPreviewHeight();

            if(Build.VERSION.SDK_INT < 20 && videoWidth >= 1080 && videoHeight >= 1080){
                videoWidth = videoWidth/2;
                videoHeight = videoHeight/2;
            }

            // for video capturing
            new MediaVideoEncoder(mMuxer, mMediaEncoderListener, videoWidth, videoHeight);

            if(mIsHasAudioPermission){
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

    private void updateTimer(){
        String timeInfo;
        mTimeSeconds++;

        if(mTimeSeconds >= 60){
            mTimeMinutes++;
            mTimeSeconds = 0;
        }

        if(mTimeSeconds < 10 && mTimeMinutes < 10){
            timeInfo = "00:0"+ mTimeMinutes + ":" + "0" + mTimeSeconds;
        }else if(mTimeSeconds < 10 && mTimeMinutes >= 10){
            timeInfo = "00:"+ mTimeMinutes + ":" + "0" + mTimeSeconds;
        }else if(mTimeSeconds >= 10 && mTimeMinutes < 10){
            timeInfo = "00:0"+ mTimeMinutes + ":" + mTimeSeconds;
        }else {
            timeInfo = "00:"+ mTimeMinutes + ":" + mTimeSeconds;
        }

        mShowShortVideoTime.setText(timeInfo);
    }

    private void resetTimer(){
        mTimeMinutes = 0;
        mTimeSeconds = 0;
        if(mTimer != null){
            mTimer.cancel();
        }
        if(mTimerTask != null){
            mTimerTask.cancel();
        }

        mShowShortVideoTime.setText("00:00:00");
        mShowShortVideoTime.setVisibility(View.INVISIBLE);
    }

    private void closeTableView(){
        mSelectOptions.setBackgroundColor(Color.parseColor("#00000000"));
        mStickerOptionsSwitch.setVisibility(View.VISIBLE);
        mBeautyOptionsSwitch.setVisibility(View.VISIBLE);
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

        mShowOriginBtn1.setVisibility(View.VISIBLE);
        mShowOriginBtn2.setVisibility(View.INVISIBLE);
        mShowOriginBtn3.setVisibility(View.INVISIBLE);
        mIndicatorSeekbar.setVisibility(View.INVISIBLE);
        mResetTextView.setVisibility(View.INVISIBLE);
    }

    private void disableShowLayouts(){
        mVideoProgress.setVisibility(View.VISIBLE);
        mBeautyOptionsSwitch.setVisibility(View.INVISIBLE);
        mStickerOptionsSwitch.setVisibility(View.INVISIBLE);
    }

    private void enableShowLayouts(){
        mVideoProgress.setVisibility(View.INVISIBLE);
        mBeautyOptionsSwitch.setVisibility(View.VISIBLE);
        mStickerOptionsSwitch.setVisibility(View.VISIBLE);
    }

    private void resetFilterView(){
        ((ImageView)findViewById(R.id.iv_filter_group_portrait)).setImageDrawable(getResources().getDrawable(R.drawable.icon_portrait_unselected));
        ((TextView) findViewById(R.id.tv_filter_group_portrait)).setTextColor(Color.parseColor("#ffffff"));

        ((ImageView)findViewById(R.id.iv_filter_group_scenery)).setImageDrawable(getResources().getDrawable(R.drawable.icon_scenery_unselected));
        ((TextView) findViewById(R.id.tv_filter_group_scenery)).setTextColor(Color.parseColor("#ffffff"));

        ((ImageView)findViewById(R.id.iv_filter_group_still_life)).setImageDrawable(getResources().getDrawable(R.drawable.icon_still_life_unselected));
        ((TextView) findViewById(R.id.tv_filter_group_still_life)).setTextColor(Color.parseColor("#ffffff"));

        ((ImageView)findViewById(R.id.iv_filter_group_food)).setImageDrawable(getResources().getDrawable(R.drawable.icon_food_unselected));
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
        mShowOriginBtn1.setVisibility(View.INVISIBLE);
        mShowOriginBtn2.setVisibility(View.INVISIBLE);
        mShowOriginBtn3.setVisibility(View.VISIBLE);
    }

    private int mColorBlue = Color.parseColor("#0a8dff");
    private void showHandActionInfo(long action){

        resetHandActionInfo();

        if((action & STMobileHumanActionNative.ST_MOBILE_HAND_PALM) > 0){
            findViewById(R.id.iv_palm).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_palm)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_palm_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_GOOD) > 0){
            findViewById(R.id.iv_thumb).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_thumb)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_thumb_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_OK) > 0){
            findViewById(R.id.iv_ok).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_ok)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_ok_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_PISTOL) > 0){
            findViewById(R.id.iv_pistol).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_pistol)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_pistol_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_INDEX) > 0){
            findViewById(R.id.iv_one_finger).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_one_finger)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_one_finger_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_FINGER_HEART) > 0){
            findViewById(R.id.iv_finger_heart).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_finger_heart)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_finger_heart_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_LOVE) > 0){
            findViewById(R.id.iv_heart_hand).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_heart_hand)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_heart_hand_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_SCISSOR) > 0){
            findViewById(R.id.iv_scissor).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_scissor)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_scissor_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_CONGRATULATE) > 0){
            findViewById(R.id.iv_congratulate).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_congratulate)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_congratulate_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_HOLDUP) > 0){
            findViewById(R.id.iv_palm_up).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_palm_up)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_palm_up_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_FIST) > 0){
            findViewById(R.id.iv_palm_up).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_palm_up)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_first_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_666) > 0){
            findViewById(R.id.iv_palm_up).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_palm_up)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_sixsixsix_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_BLESS) > 0){
            findViewById(R.id.iv_palm_up).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_palm_up)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_handbless_selected));
        }else if((action & STMobileHumanActionNative.ST_MOBILE_HAND_ILOVEYOU) > 0){
            findViewById(R.id.iv_palm_up).setBackgroundColor(mColorBlue);
            ((ImageView)findViewById(R.id.iv_palm_up)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_love_selected));
        }
    }

    private void resetHandActionInfo(){
        findViewById(R.id.iv_palm).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_palm)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_palm));

        findViewById(R.id.iv_thumb).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_thumb)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_thumb));

        findViewById(R.id.iv_ok).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_ok)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_ok));

        findViewById(R.id.iv_pistol).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_pistol)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_pistol));

        findViewById(R.id.iv_one_finger).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_one_finger)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_one_finger));

        findViewById(R.id.iv_finger_heart).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_finger_heart)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_finger_heart));

        findViewById(R.id.iv_heart_hand).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_heart_hand)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_heart_hand));

        findViewById(R.id.iv_scissor).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_scissor)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_scissor));

        findViewById(R.id.iv_congratulate).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_congratulate)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_congratulate));

        findViewById(R.id.iv_palm_up).setBackgroundColor(Color.parseColor("#00000000"));
        ((ImageView)findViewById(R.id.iv_palm_up)).setImageDrawable(getResources().getDrawable(R.drawable.ic_trigger_palm_up));
    }

    private void showBodyActionInfo(long action){
        TextView bodyActionView = (TextView)findViewById(R.id.tv_show_body_action);
        bodyActionView.setVisibility(View.VISIBLE);
        //for test body action
        if((action & STMobileHumanActionNative.ST_MOBILE_BODY_ACTION3) > 0){
            bodyActionView.setText("肢体动作：摊手");
        }else if((action & STMobileHumanActionNative.ST_MOBILE_BODY_ACTION2) > 0){
            bodyActionView.setText("肢体动作：一休");
        }else if((action & STMobileHumanActionNative.ST_MOBILE_BODY_ACTION1) > 0){
            bodyActionView.setText("肢体动作：龙拳");
        }else{
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
        }else {
            mAttributeText.setVisibility(View.INVISIBLE);
        }
    }

    private void showFaceExpressionInfo(boolean[] faceExpressionInfo){

        resetFaceExpression();

        if (faceExpressionInfo != null) {
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_HEAD_NORMAL.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_head_normal)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_normal_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_SIDE_FACE_LEFT.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_side_face_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_side_face_left_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_SIDE_FACE_RIGHT.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_side_face_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_side_face_right_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_TILTED_FACE_LEFT.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_tilted_face_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_tilted_face_left_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_TILTED_FACE_RIGHT.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_tilted_face_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_tilted_face_right_selected));
            }

            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_HEAD_RISE.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_head_rise)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_rise_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_HEAD_LOWER.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_head_lower)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_lower_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_TWO_EYE_OPEN.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_two_eye_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_two_eye_open_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_TWO_EYE_CLOSE.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_two_eye_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_two_eye_close_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_LEFTEYE_CLOSE_RIGHTEYE_OPEN.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_lefteye_close_righteye_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lefteye_close_righteye_open_selected));
            }

            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_LEFTEYE_OPEN_RIGHTEYE_CLOSE.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_lefteye_open_righteye_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lefteye_open_righteye_close_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_MOUTH_OPEN.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_mouth_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_mouth_open_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_MOUTH_CLOSE.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_mouth_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_mouth_close_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_FACE_LIPS_POUTED.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_face_lips_pouted)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_face_lips_pouted_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_FACE_LIPS_UPWARD.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_face_lips_upward)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_face_lips_upward_selected));
            }

            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_FACE_LIPS_CURL_LEFT.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_lips_curl_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lips_curl_left_selected));
            }
            if(faceExpressionInfo[STMobileHumanActionNative.STMobileExpression.ST_MOBILE_EXPRESSION_FACE_LIPS_CURL_RIGHT.getExpressionCode()]){
                ((ImageView)findViewById(R.id.iv_face_expression_lips_curl_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lips_curl_right_selected));
            }
        }
    }

    private void resetFaceExpression(){
        ((ImageView)findViewById(R.id.iv_face_expression_head_normal)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_normal));
        ((ImageView)findViewById(R.id.iv_face_expression_side_face_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_side_face_left));
        ((ImageView)findViewById(R.id.iv_face_expression_side_face_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_side_face_right));
        ((ImageView)findViewById(R.id.iv_face_expression_tilted_face_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_tilted_face_left));
        ((ImageView)findViewById(R.id.iv_face_expression_tilted_face_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_tilted_face_right));

        ((ImageView)findViewById(R.id.iv_face_expression_head_rise)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_rise));
        ((ImageView)findViewById(R.id.iv_face_expression_head_lower)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_head_lower));
        ((ImageView)findViewById(R.id.iv_face_expression_two_eye_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_two_eye_open));
        ((ImageView)findViewById(R.id.iv_face_expression_two_eye_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_two_eye_close));
        ((ImageView)findViewById(R.id.iv_face_expression_lefteye_close_righteye_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lefteye_close_righteye_open));

        ((ImageView)findViewById(R.id.iv_face_expression_lefteye_open_righteye_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lefteye_open_righteye_close));
        ((ImageView)findViewById(R.id.iv_face_expression_mouth_open)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_mouth_open));
        ((ImageView)findViewById(R.id.iv_face_expression_mouth_close)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_mouth_close));
        ((ImageView)findViewById(R.id.iv_face_expression_face_lips_pouted)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_face_lips_pouted));
        ((ImageView)findViewById(R.id.iv_face_expression_face_lips_upward)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_face_lips_upward));

        ((ImageView)findViewById(R.id.iv_face_expression_lips_curl_left)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lips_curl_left));
        ((ImageView)findViewById(R.id.iv_face_expression_lips_curl_right)).setImageDrawable(getResources().getDrawable(R.drawable.face_expression_lips_curl_right));
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
        SenseArMaterialService.shareInstance().initialize(getApplicationContext());
        SenseArMaterialService.shareInstance().authorizeWithAppId(this, APPID, APPKEY, new SenseArMaterialService.OnAuthorizedListener() {
            @Override
            public void onSuccess() {
                LogUtils.d(TAG, "鉴权成功！");
                fetchGroupMaterialList(mStickerOptionsList);
            }

            @Override
            public void onFailure(SenseArMaterialService.AuthorizeErrorCode errorCode, String errorMsg) {
                LogUtils.d(TAG, String.format(Locale.getDefault(), "鉴权失败！%d, %s", errorCode, errorMsg));
            }
        });
    }

    //初始化tab 点击
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
                if(selectedItem.name.equals("object_track")){
                    selectedAdapter = mObjectAdapter;
                }else{
                    selectedAdapter = mStickerAdapters.get(selectedItem.name);
                }
                if (selectedAdapter == null) {
                    LogUtils.e(TAG, "贴纸adapter 不能为空");
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
        for (final StickerOptionsItem groupId : groups) {
            if (groupId.name.equals("object_track")) {
                //使用本地object 追踪模型
            } else {
                SenseArMaterialService.shareInstance().fetchMaterialsFromGroupId("",groupId.name, SenseArMaterialType.Effect, new SenseArMaterialService.FetchMaterialListener() {
                    @Override
                    public void onSuccess(final List<SenseArMaterial> materials) {
                        fetchGroupMaterialInfo(groupId.name, materials);
                    }

                    @Override
                    public void onFailure(int code, String message) {
                        LogUtils.e(TAG, String.format(Locale.getDefault(), "下载素材信息失败！%d, %s", code, message));
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
                    mCameraDisplay.setShowSticker(null);
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
                    SenseArMaterialService.shareInstance().downloadMaterial(VideoPlayerActivity.this, sarm, new SenseArMaterialService.DownloadMaterialListener() {
                        @Override
                        public void onSuccess(final SenseArMaterial material) {
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    stickerItem.path = material.cachedPath;
                                    stickerItem.state = StickerState.DONE_STATE;
                                    //如果本次下载是用户用户最后一次选中项，则直接应用
                                    if (preMaterialId.equals(material.id)) {
                                        resetStickerAdapter();
                                        mCurrentStickerOptionsIndex = index;
                                        mCurrentStickerPosition = position;
                                        findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));

                                        mStickerAdapters.get(groupId).setSelectedPosition(position);
                                        mCameraDisplay.enableSticker(true);
                                        mCameraDisplay.setShowSticker(stickerItem.path);
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
                    resetStickerAdapter();
                    mCurrentStickerOptionsIndex = index;
                    mCurrentStickerPosition = position;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));

                    mStickerAdapters.get(groupId).setSelectedPosition(position);
                    mCameraDisplay.enableSticker(true);
                    mCameraDisplay.setShowSticker(mStickerlists.get(groupId).get(position).path);
                }
            }
        });
    }

    /**
     * 初始化素材的基本信息，如缩略图，是否已经缓存
     *
     * @param groupId   组id
     * @param materials 服务器返回的素材list
     */
    private void fetchGroupMaterialInfo(final String groupId, final List<SenseArMaterial> materials) {

        ArrayList<StickerItem> stickerList = new ArrayList<>();
        mStickerlists.put(groupId, stickerList);
        mStickerAdapters.put(groupId, new StickerAdapter(mStickerlists.get(groupId), getApplicationContext()));
        int i = 0;
        initStickerListener(groupId, i, materials);
        for (SenseArMaterial sarm : materials) {
            LogUtils.d(TAG, sarm.thumbnail);
            i++;
            LogUtils.d(TAG, sarm);
            Bitmap bitmap = null;
            try {
                bitmap = ImageUtils.getImageSync(sarm.thumbnail, VideoPlayerActivity.this);

            } catch (Exception e) {
                e.printStackTrace();
            }
            if (bitmap == null) {
                bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.none);
            }
            String path = "";
            //如果已经下载则传入路径地址
            if (SenseArMaterialService.shareInstance().isMaterialDownloaded(VideoPlayerActivity.this, sarm)) {
                path = SenseArMaterialService.shareInstance().getMaterialCachedPath(VideoPlayerActivity.this, sarm);
            }
            sarm.cachedPath = path;
            stickerList.add(new StickerItem(sarm.name, bitmap, path));
        }

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (mStickersRecycleView.getAdapter() == null) {
                    mStickerOptionsAdapter.setSelectedPosition(0);
                    String id = mStickerOptionsAdapter.getPositionItem(0).name;
                    mStickerOptionsAdapter.notifyDataSetChanged();
                    mStickersRecycleView.setAdapter(mStickerAdapters.get(id));

                    if(mStickerAdapters != null && mStickerAdapters.size() > 0 && mStickerAdapters.get(id) != null){
                        mStickerAdapters.get(id).setSelectedPosition(-1);
                    }
                }

                if(mStickerAdapters != null || mStickerAdapters.size() > 0 ){
                    mStickerAdapters.get(groupId).notifyDataSetChanged();
                }
            }
        });
    }

    private void resetStickerAdapter() {

        if (mCurrentStickerPosition != -1) {
            mCameraDisplay.setShowSticker(null);
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

    private boolean checkMicroType(){
        int type = mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition);
        boolean ans = ((type != 0) && (type != 4) && (type != 6) && (type != 11) && (type != 12) && (type != 13) && (type != 14) && (type != 15) && (type != 3));
        return ans && (2 == mBeautyOptionsPosition);
    }
}
