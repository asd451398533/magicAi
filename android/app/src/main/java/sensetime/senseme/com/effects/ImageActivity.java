package sensetime.senseme.com.effects;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Rect;
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
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.example.gengmei_app_face.R;
import com.sensetime.sensearsourcemanager.SenseArMaterial;
import com.sensetime.sensearsourcemanager.SenseArMaterialService;
import com.sensetime.sensearsourcemanager.SenseArMaterialType;
import com.sensetime.stmobile.model.STMobileType;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import sensetime.senseme.com.effects.adapter.BeautyItemAdapter;
import sensetime.senseme.com.effects.adapter.BeautyOptionsAdapter;
import sensetime.senseme.com.effects.adapter.FilterAdapter;
import sensetime.senseme.com.effects.adapter.MakeupAdapter;
import sensetime.senseme.com.effects.adapter.NativeStickerAdapter;
import sensetime.senseme.com.effects.adapter.StickerAdapter;
import sensetime.senseme.com.effects.adapter.StickerOptionsAdapter;
import sensetime.senseme.com.effects.display.ImageDisplay;
import sensetime.senseme.com.effects.glutils.STUtils;
import sensetime.senseme.com.effects.utils.Accelerometer;
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

public class ImageActivity extends Activity implements View.OnClickListener {
    private final static String TAG = "ImageActivity";
    private Accelerometer mAccelerometer = null;
    private ImageDisplay mImageDisplay;
    private FrameLayout mPreviewFrameLayout;

    private RecyclerView mStickersRecycleView;
    private RecyclerView mStickerOptionsRecycleView, mFilterOptionsRecycleView, mMakeupOptionsRecycleView;
    private RecyclerView mBeautyBaseRecycleView;
    private StickerOptionsAdapter mStickerOptionsAdapter;
    private BeautyOptionsAdapter mBeautyOptionsAdapter;
    private BeautyItemAdapter mBeautyBaseAdapter, mBeautyProfessionalAdapter, mAdjustAdapter, mMicroAdapter;
    private ArrayList<StickerOptionsItem> mStickerOptionsList = new ArrayList<>();
    private ArrayList<StickerItem> mNewStickers;
    private ArrayList<BeautyOptionsItem> mBeautyOptionsList;

    private HashMap<String, StickerAdapter> mStickerAdapters = new HashMap<>();
//    private HashMap<String, NewStickerAdapter> mNewStickerAdapters = new HashMap<>();
    private HashMap<String, NativeStickerAdapter> mNativeStickerAdapters = new HashMap<>();
    private HashMap<String, BeautyItemAdapter> mBeautyItemAdapters = new HashMap<>();
    private HashMap<String, ArrayList<StickerItem>> mStickerlists = new HashMap<>();
    private HashMap<String, ArrayList<BeautyItem>> mBeautylists = new HashMap<>();
    private HashMap<Integer, String> mBeautyOption = new HashMap<>();
    private HashMap<Integer, Integer> mBeautyOptionSelectedIndex = new HashMap<>();
    private Map<Integer, Integer> mStickerPackageMap;
    private int mCurrentNewStickerPosition = -1;

    private HashMap<String, MakeupAdapter> mMakeupAdapters = new HashMap<>();
    private HashMap<String, ArrayList<MakeupItem>> mMakeupLists = new HashMap<>();
    private HashMap<String, Integer> mMakeupOptionIndex = new HashMap<>();
    private HashMap<Integer, Integer> mMakeupOptionSelectedIndex = new HashMap<>();
    private HashMap<Integer, Integer> mMakeupStrength = new HashMap<>();

    private HashMap<String, FilterAdapter> mFilterAdapters = new HashMap<>();
    private HashMap<String, ArrayList<FilterItem>> mFilterLists = new HashMap<>();

    private TextView mSavingTv, mResetTextView;
    private TextView mAttributeText;
    private TextView mShowOriginBtn1, mShowOriginBtn2, mShowOriginBtn3;
    private IndicatorSeekBar mIndicatorSeekbar;

    private LinearLayout mFilterGroupsLinearLayout, mFilterGroupPortrait, mFilterGroupStillLife, mFilterGroupScenery, mFilterGroupFood;
    private LinearLayout mMakeupGroupLip, mMakeupGroupCheeks, mMakeupGroupFace, mMakeupGroupBrow, mMakeupGroupEye,mMakeupGroupEyeLiner, mMakeupGroupEyeLash, mMakeupGroupEyeBall;
    private RelativeLayout mFilterIconsRelativeLayout, mFilterStrengthLayout, mMakeupIconsRelativeLayout, mMakeupGroupsRelativeLayout;
    private ImageView mFilterGroupBack, mMakeupGroupBack;
    private TextView mFilterGroupName, mFilterStrengthText;
    private TextView mMakeupGroupName;
    private SeekBar mFilterStrengthBar;
    private int mCurrentFilterGroupIndex = -1;
    private int mCurrentFilterIndex = -1;
    private int mCurrentMakeupGroupIndex = -1;
    private int mCurrentBeautyIndex = Constants.ST_BEAUTIFY_WHITEN_STRENGTH;

    private Context mContext;
    private Bitmap mImageBitmap;
    public static float[] DEFAULT_BEAUTIFY_PARAMS = {0.36f, 0.74f, 0.02f, 0.13f, 0.11f, 0.1f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f, 0f};

    public static final int MSG_SAVING_IMG = 1;
    public static final int MSG_SAVED_IMG = 2;
    //    public final static int MSG_NEED_UPDATE_STICKER_MAP = 105;
    public final static int MSG_NEED_REPLACE_STICKER_MAP = 106;
    public final static int MSG_NEED_SHOW_TOO_MUCH_STICKER_TIPS = 107;

    private static final int PERMISSION_REQUEST_WRITE_PERMISSION = 101;
    private boolean mPermissionDialogShowing = false;
    private final int REQUEST_PICK_IMAGE = 1;

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
    private ArrayList<SeekBar> mBeautyParamsSeekBarList = new ArrayList<SeekBar>();

    private ImageView mBeautyOptionsSwitchIcon, mStickerOptionsSwitchIcon;
    private TextView mBeautyOptionsSwitchText, mStickerOptionsSwitchText;
    private RelativeLayout mFilterAndBeautyOptionView;
    private LinearLayout mSelectOptions;
    //记录用户最后一次点击的素材id ,包括还未下载的，方便下载完成后，直接应用素材
    private String preMaterialId = "";
    private Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);

            switch (msg.what) {
                case MSG_SAVING_IMG:
                    mImageBitmap = mImageDisplay.getBitmap();
                    saveToSDCard(FileUtils.getOutputMediaFile(), mImageBitmap);
                    break;
                case MSG_SAVED_IMG:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            try {
                                Thread.sleep(1000);
                            } catch (InterruptedException e) {
                                e.printStackTrace();
                            }
                            mSavingTv.setVisibility(View.GONE);
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

                case MSG_NEED_SHOW_TOO_MUCH_STICKER_TIPS:
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            Toast.makeText(mContext, "添加太多贴纸了", Toast.LENGTH_SHORT).show();
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

        resetFilterView();
        mShowOriginBtn1.setVisibility(View.VISIBLE);
        mShowOriginBtn2.setVisibility(View.INVISIBLE);
        mShowOriginBtn3.setVisibility(View.INVISIBLE);

        //滤镜默认选中babypink效果
        setDefaultFilter();
    }

    private void initView() {

        //copy model file to sdcard
        FileUtils.copyModelFiles(this);

        mAccelerometer = new Accelerometer(getApplicationContext());
        GLSurfaceView glSurfaceView = (GLSurfaceView) findViewById(R.id.id_gl_sv);
        mPreviewFrameLayout = (FrameLayout) findViewById(R.id.id_preview_layout);
        mImageDisplay = new ImageDisplay(getApplicationContext(), glSurfaceView, mHandler);

        mIndicatorSeekbar = (IndicatorSeekBar) findViewById(R.id.beauty_item_seekbar);
        mIndicatorSeekbar.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                if (fromUser) {
                    if (checkMicroType()) {
                        mIndicatorSeekbar.updateTextview(STUtils.convertToDisplay(progress));
                        mImageDisplay.setBeautyParam(mCurrentBeautyIndex, (float) STUtils.convertToDisplay(progress) / 100f);
                        mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(mBeautyOptionSelectedIndex.get(mBeautyOptionsPosition)).setProgress(STUtils.convertToDisplay(progress));
                    } else {
                        mIndicatorSeekbar.updateTextview(progress);
                        mImageDisplay.setBeautyParam(mCurrentBeautyIndex, (float) progress / 100f);
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

        ArrayList mBeautyBaseItem = new ArrayList<>();
        mBeautyBaseItem.add(new BeautyItem("美白", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_whiten_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_whiten_selected)));
        mBeautyBaseItem.add(new BeautyItem("红润", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_redden_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_redden_selected)));
        mBeautyBaseItem.add(new BeautyItem("磨皮", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_smooth_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_smooth_selected)));
        mBeautyBaseItem.add(new BeautyItem("去高光", BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_dehighlight_unselected), BitmapFactory.decodeResource(mContext.getResources(), R.drawable.beauty_dehighlight_selected)));
        ((BeautyItem) mBeautyBaseItem.get(0)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[2] * 100));
        ((BeautyItem) mBeautyBaseItem.get(1)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[0] * 100));
        ((BeautyItem) mBeautyBaseItem.get(2)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[1] * 100));
        ((BeautyItem) mBeautyBaseItem.get(3)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[8] * 100));

        mIndicatorSeekbar.getSeekBar().setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[2] * 100));
        mIndicatorSeekbar.updateTextview((int) (DEFAULT_BEAUTIFY_PARAMS[2] * 100));

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

        ((BeautyItem) mProfessionalBeautyItem.get(0)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[4] * 100));
        ((BeautyItem) mProfessionalBeautyItem.get(1)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[3] * 100));
        ((BeautyItem) mProfessionalBeautyItem.get(2)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[5] * 100));
        ((BeautyItem) mProfessionalBeautyItem.get(3)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[9] * 100));
        ((BeautyItem) mProfessionalBeautyItem.get(4)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[26] * 100));

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
            ((BeautyItem)mMicroBeautyItem.get(i)).setProgress((int)(DEFAULT_BEAUTIFY_PARAMS[i+10]* 100));
        }
        mBeautylists.put("microBeauty", mMicroBeautyItem);
        mMicroAdapter = new BeautyItemAdapter(this, mMicroBeautyItem);
        mBeautyItemAdapters.put("microBeauty", mMicroAdapter);
        mBeautyOption.put(2, "microBeauty");

        mMakeupOptionsRecycleView = (RecyclerView) findViewById(R.id.rv_makeup_icons);
        mMakeupOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
        mMakeupOptionsRecycleView.addItemDecoration(new ImageActivity.SpaceItemDecoration(0));

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
        mMakeupGroupsRelativeLayout = ((RelativeLayout) findViewById(R.id.rl_makeup_groups));
        mMakeupGroupLip = (LinearLayout) findViewById(R.id.ll_makeup_group_lip);
        mMakeupGroupLip.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
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
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
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
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
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
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
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
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
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
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
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
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
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
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.VISIBLE);
                mCurrentMakeupGroupIndex = Constants.ST_MAKEUP_EYEBALL;
                if(mMakeupOptionSelectedIndex.get(7) != 0){
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
                mMakeupGroupsRelativeLayout.setVisibility(View.VISIBLE);
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
        ((BeautyItem) mAdjustBeautyItem.get(0)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[6] * 100));
        ((BeautyItem) mAdjustBeautyItem.get(1)).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[7] * 100));
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

        //layout elements
        mStickersRecycleView = (RecyclerView) findViewById(R.id.rv_sticker_icons);

        mStickersRecycleView.setLayoutManager(new GridLayoutManager(this, 6));
        mStickersRecycleView.addItemDecoration(new SpaceItemDecoration(0));

        mNewStickers = FileUtils.getStickerFiles(this, "newEngine");
        mStickerOptionsList = new ArrayList<>();

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

        mNativeStickerAdapters.put("sticker_new_engine", new NativeStickerAdapter(mNewStickers, this));

        mStickersRecycleView.setAdapter(mNativeStickerAdapters.get("sticker_new_engine"));
        mNativeStickerAdapters.get("sticker_new_engine").notifyDataSetChanged();
        initNativeStickerAdapter("sticker_new_engine", 0);
        mStickerOptionsAdapter = new StickerOptionsAdapter(mStickerOptionsList, this);
        mStickerOptionsAdapter.setSelectedPosition(0);
        mStickerOptionsAdapter.notifyDataSetChanged();

        findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));

        mStickerOptionsSwitch = (LinearLayout) findViewById(R.id.ll_sticker_options_switch);
        mStickerOptionsSwitch.setOnClickListener(this);
        mStickerOptions = (RelativeLayout) findViewById(R.id.rl_sticker_options);
        mStickerIcons = (RecyclerView) findViewById(R.id.rv_sticker_icons);
        mIsStickerOptionsOpen = false;

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

        mBeautyOptionsSwitch = (LinearLayout) findViewById(R.id.ll_beauty_options_switch);
        mBeautyOptionsSwitch.setOnClickListener(this);

        mBaseBeautyOptions = (LinearLayout) findViewById(R.id.ll_base_beauty_options);
        mBaseBeautyOptions.setOnClickListener(null);
        mIsBeautyOptionsOpen = false;

        mFilterOptionsRecycleView = (RecyclerView) findViewById(R.id.rv_filter_icons);
        mFilterOptionsRecycleView.setLayoutManager(new StaggeredGridLayoutManager(1, StaggeredGridLayoutManager.HORIZONTAL));
        mFilterOptionsRecycleView.addItemDecoration(new SpaceItemDecoration(0));

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
                    mImageDisplay.setFilterStrength((float) progress / 100);
                    mFilterStrengthText.setText(progress + "");
                }else if(mBeautyOptionsPosition == 3){
                    mImageDisplay.setStrengthForType(mCurrentMakeupGroupIndex, (float)progress / 100);
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

        mStickerOptionsRecycleView.setAdapter(mStickerOptionsAdapter);
        mFilterOptionsRecycleView.setAdapter(mFilterAdapters.get("filter_portrait"));
        mFilterIcons = (RecyclerView) findViewById(R.id.rv_filter_icons);

        mAttributeText = (TextView) findViewById(R.id.tv_face_attribute);
        mAttributeText.setVisibility(View.VISIBLE);
        mSavingTv = (TextView) findViewById(R.id.tv_saving_image);

        findViewById(R.id.iv_setting_options_switch).setVisibility(View.INVISIBLE);
        findViewById(R.id.iv_mode_picture).setVisibility(View.INVISIBLE);
        findViewById(R.id.btn_capture_picture).setVisibility(View.INVISIBLE);
        findViewById(R.id.ll_blank_view).setVisibility(View.GONE);

        mSelectOptions = (LinearLayout) findViewById(R.id.ll_select_options);
        mSelectOptions.setBackgroundColor(Color.parseColor("#00000000"));
        mResetTextView = (TextView) findViewById(R.id.reset);
    }

    private void initEvents() {
        int mode = 0;
        mode = this.getIntent().getBundleExtra("bundle").getInt("mode");

        switch (mode) {
            case LoadImageActivity.MODE_GALLERY_IMAGE:

                Uri imageUri = this.getIntent().getParcelableExtra("imageUri");
                if ("file".equals(imageUri.getScheme())) {
                    mImageBitmap = STUtils.getBitmapFromFile(imageUri);
                } else {
                    mImageBitmap = STUtils.getBitmapAfterRotate(imageUri, mContext);
                }
                break;

            case LoadImageActivity.MODE_TAKE_PHOTO:
                Uri photoUri = this.getIntent().getParcelableExtra("imageUri");
                mImageBitmap = STUtils.getBitmapFromFileAfterRotate(photoUri);
                break;
        }

        mImageDisplay.setImageBitmap(mImageBitmap);
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
                    mImageDisplay.enableFilter(false);
                } else {
                    mImageDisplay.setFilterStyle(mFilterLists.get("filter_portrait").get(position).model);
                    mImageDisplay.enableFilter(true);

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
                    mImageDisplay.enableFilter(false);
                } else {
                    mImageDisplay.setFilterStyle(mFilterLists.get("filter_scenery").get(position).model);
                    mImageDisplay.enableFilter(true);
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
                    mImageDisplay.enableFilter(false);
                } else {
                    mImageDisplay.setFilterStyle(mFilterLists.get("filter_still_life").get(position).model);
                    mImageDisplay.enableFilter(true);
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
                    mImageDisplay.enableFilter(false);
                } else {
                    mImageDisplay.setFilterStyle(mFilterLists.get("filter_food").get(position).model);
                    mImageDisplay.enableFilter(true);
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
                        mImageDisplay.removeMakeupByType(mCurrentMakeupGroupIndex);
                        updateMakeupOptions(mCurrentMakeupGroupIndex, false);
                    }else if(position == mMakeupOptionSelectedIndex.get(mMakeupOptionIndex.get(entry.getKey()))){
                        entry.getValue().setSelectedPosition(0);
                        mMakeupOptionSelectedIndex.put(mMakeupOptionIndex.get(entry.getKey()), 0);

                        mFilterStrengthLayout.setVisibility(View.INVISIBLE);
                        mImageDisplay.removeMakeupByType(mCurrentMakeupGroupIndex);
                        updateMakeupOptions(mCurrentMakeupGroupIndex, false);
                    }else{
                        entry.getValue().setSelectedPosition(position);
                        mMakeupOptionSelectedIndex.put(mMakeupOptionIndex.get(entry.getKey()), position);

                        mImageDisplay.setMakeupForType(mCurrentMakeupGroupIndex, mMakeupLists.get(getMakeupNameOfType(mCurrentMakeupGroupIndex)).get(position).path);
                        mImageDisplay.setStrengthForType(mCurrentMakeupGroupIndex, (float)mMakeupStrength.get(mCurrentMakeupGroupIndex)/100.f);
                        mFilterStrengthLayout.setVisibility(View.VISIBLE);
                        mFilterStrengthBar.setProgress(mMakeupStrength.get(mCurrentMakeupGroupIndex));
                        updateMakeupOptions(mCurrentMakeupGroupIndex, true);
                    }

                    if(checkMakeUpSelect()){
                        mImageDisplay.enableMakeUp(true);
                    }else{
                        mImageDisplay.enableMakeUp(false);
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
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
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
                } else if (position == 1) {
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("professionalBeauty"));
                } else if (position == 2) {
                    mBeautyBaseRecycleView.setAdapter(mBeautyItemAdapters.get("microBeauty"));
                } else if (position == 3) {
                    mMakeupGroupsRelativeLayout.setVisibility(View.VISIBLE);
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
                    mImageDisplay.setShowOriginal(true);
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mImageDisplay.setShowOriginal(false);
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
                    mImageDisplay.setShowOriginal(true);
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mImageDisplay.setShowOriginal(false);
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
                    mImageDisplay.setShowOriginal(true);
                } else if (event.getAction() == MotionEvent.ACTION_UP) {
                    mImageDisplay.setShowOriginal(false);
                }
                return true;
            }
        });
        mShowOriginBtn3.setVisibility(View.INVISIBLE);

        mImageDisplay.setCostChangeListener(new ImageDisplay.CostChangeListener() {
            @Override
            public void onCostChanged(final int value) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        ((TextView) findViewById(R.id.tv_frame_radio)).setText(String.valueOf(value));
                    }
                });
            }
        });

        findViewById(R.id.ll_cpu_radio).setVisibility(View.GONE);
        findViewById(R.id.tv_layout_tips).setVisibility(View.GONE);
        findViewById(R.id.tv_capture).setOnClickListener(this);
        findViewById(R.id.tv_cancel).setOnClickListener(this);
        findViewById(R.id.id_gl_sv).setOnClickListener(this);

        findViewById(R.id.rv_close_sticker).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //重置所有状态为为选中状态
                resetStickerAdapter();
                resetNewStickerAdapter();
                mCurrentStickerPosition = -1;
                mCurrentNewStickerPosition = -1;
                mImageDisplay.enableSticker(false);

                mImageDisplay.removeAllStickers();

                findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));
            }
        });

        mImageDisplay.enableBeautify(true);
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
                mImageDisplay.setFilterStyle(mFilterLists.get("filter_portrait").get(mCurrentFilterIndex).model);
                mImageDisplay.enableFilter(true);

                ((ImageView) findViewById(R.id.iv_filter_group_portrait)).setImageDrawable(getResources().getDrawable(R.drawable.icon_portrait_selected));
                ((TextView) findViewById(R.id.tv_filter_group_portrait)).setTextColor(Color.parseColor("#c460e1"));
                mFilterAdapters.get("filter_portrait").notifyDataSetChanged();
            }
        }
    }

    private void resetSetBeautyParam(int beautyOptionsPosition) {
        switch (beautyOptionsPosition) {
            case 0:
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_WHITEN_STRENGTH, (DEFAULT_BEAUTIFY_PARAMS[2]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_REDDEN_STRENGTH, (DEFAULT_BEAUTIFY_PARAMS[0]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SMOOTH_STRENGTH, (DEFAULT_BEAUTIFY_PARAMS[1]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_DEHIGHLIGHT_STRENGTH, (DEFAULT_BEAUTIFY_PARAMS[8]));
                break;
            case 1:
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_FACE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[4]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_ENLARGE_EYE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[3]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_JAW_RATIO, (DEFAULT_BEAUTIFY_PARAMS[5]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_NARROW_FACE_STRENGTH, (DEFAULT_BEAUTIFY_PARAMS[9]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_ROUND_EYE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[26]));
                break;
            case 2:
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[10]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, (DEFAULT_BEAUTIFY_PARAMS[11]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, (DEFAULT_BEAUTIFY_PARAMS[12]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[13]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, (DEFAULT_BEAUTIFY_PARAMS[14]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, (DEFAULT_BEAUTIFY_PARAMS[15]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[16]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[17]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[18]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, (DEFAULT_BEAUTIFY_PARAMS[19]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_PROFILE_RHINOPLASTY_RATIO, (DEFAULT_BEAUTIFY_PARAMS[20]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_BRIGHT_EYE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[21]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, (DEFAULT_BEAUTIFY_PARAMS[22]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, (DEFAULT_BEAUTIFY_PARAMS[23]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_WHITE_TEETH_RATIO, (DEFAULT_BEAUTIFY_PARAMS[24]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, (DEFAULT_BEAUTIFY_PARAMS[25]));
                break;
            case 5:
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_CONSTRACT_STRENGTH, (DEFAULT_BEAUTIFY_PARAMS[6]));
                mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SATURATION_STRENGTH, (DEFAULT_BEAUTIFY_PARAMS[7]));
                break;
        }
    }

    private void resetBeautyLists(int beautyOptionsPosition) {
        switch (beautyOptionsPosition) {
            case 0:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[2] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[0] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(2).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[1] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(3).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[8] * 100));
                break;
            case 1:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[4] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[3] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(2).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[5] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(3).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[9] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(4).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[26] * 100));
                break;
            case 2:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[10] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[11] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(2).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[12] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(3).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[13] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(4).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[14] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(5).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[15] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(6).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[16] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(7).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[17] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(8).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[18] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(9).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[19] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(10).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[20] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(11).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[21] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(12).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[22] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(13).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[23] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(14).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[24] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(15).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[25] * 100));
                break;
            case 5:
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(0).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[6] * 100));
                mBeautylists.get(mBeautyOption.get(mBeautyOptionsPosition)).get(1).setProgress((int) (DEFAULT_BEAUTIFY_PARAMS[7] * 100));
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

    private void initStickerAdapter(final String stickerClassName, final int index) {

        mStickerAdapters.get(stickerClassName).setClickStickerListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int position = Integer.parseInt(v.getTag().toString());

                resetNewStickerAdapter();

                if (mCurrentStickerOptionsIndex == index && mCurrentStickerPosition == position) {
                    mStickerAdapters.get(stickerClassName).setSelectedPosition(-1);
                    mCurrentStickerOptionsIndex = -1;
                    mCurrentStickerPosition = -1;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));
                    mImageDisplay.enableSticker(false);
                    mImageDisplay.removeAllStickers();

                } else {
                    mCurrentStickerOptionsIndex = index;
                    mCurrentStickerPosition = position;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));

                    mStickerAdapters.get(stickerClassName).setSelectedPosition(position);
                    mImageDisplay.enableSticker(true);
                    mImageDisplay.changeSticker(mStickerlists.get(stickerClassName).get(position).path);
                }

                mStickerAdapters.get(stickerClassName).notifyDataSetChanged();
            }
        });
    }

    private void resetStickerAdapter() {

        if (mCurrentStickerPosition != -1) {
            mImageDisplay.removeAllStickers();
            mCurrentStickerPosition = -1;
        }

        //重置所有状态为为选中状态
        for (StickerOptionsItem optionsItem : mStickerOptionsList) {
            if (optionsItem.name.equals("sticker_new_engine")) {
                continue;
            } else {
                if (mStickerAdapters.get(optionsItem.name) != null) {
                    mStickerAdapters.get(optionsItem.name).setSelectedPosition(-1);
                    mStickerAdapters.get(optionsItem.name).notifyDataSetChanged();
                }
            }
        }
    }

    private void resetNewStickerAdapter() {
        if (mCurrentNewStickerPosition != -1) {
            mImageDisplay.removeAllStickers();
            mCurrentNewStickerPosition = -1;
        }

        if (mStickerPackageMap != null) {
            mStickerPackageMap.clear();
        }

        if (mNativeStickerAdapters.get("sticker_new_engine") != null) {
            mNativeStickerAdapters.get("sticker_new_engine").setSelectedPosition(-1);
            mNativeStickerAdapters.get("sticker_new_engine").notifyDataSetChanged();
        }
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
                mSelectOptions.setBackgroundColor(Color.parseColor("#80000000"));
                mBaseBeautyOptions.setVisibility(View.VISIBLE);
                mIndicatorSeekbar.setVisibility(View.VISIBLE);
                if (mBeautyOptionsPosition == 3){
                    mBaseBeautyOptions.setVisibility(View.INVISIBLE);
                    mMakeupGroupsRelativeLayout.setVisibility(View.VISIBLE);
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
                break;

            case R.id.id_gl_sv:
                mStickerOptionsSwitch.setVisibility(View.VISIBLE);
                mBeautyOptionsSwitch.setVisibility(View.VISIBLE);
                mSelectOptions.setBackgroundColor(Color.parseColor("#00000000"));
                mStickerOptionsSwitchIcon = (ImageView) findViewById(R.id.iv_sticker_options_switch);
                mBeautyOptionsSwitchIcon = (ImageView) findViewById(R.id.iv_beauty_options_switch);
                mStickerOptionsSwitchText = (TextView) findViewById(R.id.tv_sticker_options_switch);
                mBeautyOptionsSwitchText = (TextView) findViewById(R.id.tv_beauty_options_switch);

                mStickerOptions.setVisibility(View.INVISIBLE);
                mStickerIcons.setVisibility(View.INVISIBLE);
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
                mMakeupGroupsRelativeLayout.setVisibility(View.INVISIBLE);
                mMakeupIconsRelativeLayout.setVisibility(View.INVISIBLE);
                break;

            case R.id.tv_capture:
                if (this.isWritePermissionAllowed()) {
                    mSavingTv.setVisibility(View.VISIBLE);
                    mImageDisplay.setHandler(mHandler);
                    mImageDisplay.enableSave(true);
                } else {
                    requestWritePermission();
                }
                break;
            case R.id.tv_cancel:
                // back to welcome page
                finish();
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
        savedInstanceState.putBoolean("process_killed", true);
        super.onSaveInstanceState(savedInstanceState);
    }

    @Override
    protected void onResume() {
        LogUtils.i(TAG, "onResume");
        super.onResume();
        mAccelerometer.start();
        mImageDisplay.onResume();
    }

    @Override
    protected void onPause() {
        LogUtils.i(TAG, "onPause");
        super.onPause();
        if (!mPermissionDialogShowing) {
            mAccelerometer.stop();
            mImageDisplay.onPause();
            //finish();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mImageDisplay.onDestroy();
        mStickerAdapters.clear();
        mStickerlists.clear();
        mFilterAdapters.clear();
        mFilterLists.clear();
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

            mHandler.sendEmptyMessage(this.MSG_SAVED_IMG);
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
                if (selectedItem.name.equals("sticker_new_engine")) {
                    selectedAdapter = mNativeStickerAdapters.get(selectedItem.name);
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
            }else {
                //使用网络下载
                final int j = i;
                SenseArMaterialService.shareInstance().fetchMaterialsFromGroupId("",groupId.name, SenseArMaterialType.Effect, new SenseArMaterialService.FetchMaterialListener() {
                    @Override
                    public void onSuccess(final List<SenseArMaterial> materials) {
                        fetchGroupMaterialInfo(groupId.name, materials, j);
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
                    mImageDisplay.enableSticker(false);
                    mImageDisplay.removeAllStickers();
                    mStickerAdapters.get(groupId).notifyDataSetChanged();
                    return;
                }
                final SenseArMaterial sarm = materials.get(position);
                preMaterialId = sarm.id;
                preMaterialId = sarm.id;
                //如果素材还未下载，点击时需要下载
                if (stickerItem.state == StickerState.NORMAL_STATE) {
                    stickerItem.state = StickerState.LOADING_STATE;
                    notifyStickerViewState(stickerItem, position, groupId);
//                    mStickerAdapters.get(groupId).notifyDataSetChanged();
                    SenseArMaterialService.shareInstance().downloadMaterial(ImageActivity.this, sarm, new SenseArMaterialService.DownloadMaterialListener() {
                        @Override
                        public void onSuccess(final SenseArMaterial material) {
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    stickerItem.path = material.cachedPath;
                                    stickerItem.state = StickerState.DONE_STATE;
                                    //如果本次下载是用户用户最后一次选中项，则直接应用
                                    if (preMaterialId.equals(sarm.id)) {
                                        resetNewStickerAdapter();
                                        resetStickerAdapter();
                                        mCurrentStickerOptionsIndex = index;
                                        mCurrentStickerPosition = position;
                                        findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));

                                        mStickerAdapters.get(groupId).setSelectedPosition(position);
                                        mImageDisplay.enableSticker(true);
                                        mImageDisplay.changeSticker(stickerItem.path);
                                    }
                                    notifyStickerViewState(stickerItem, position, groupId);
//                                    mStickerAdapters.get(groupId).notifyDataSetChanged();
                                }
                            });
                            LogUtils.d(TAG, String.format(Locale.getDefault(), "素材下载成功:%s,cached path is %s", material.materials, material.cachedPath));
                        }

                        @Override
                        public void onFailure(SenseArMaterial material, int code, String message) {
                            LogUtils.d(TAG, String.format(Locale.getDefault(), "素材下载失败:%s", material.materials));
                            runOnUiThread(new Runnable() {
                                @Override
                                public void run() {
                                    stickerItem.state = StickerState.NORMAL_STATE;
                                    notifyStickerViewState(stickerItem, position, groupId);
//                                    mStickerAdapters.get(groupId).notifyDataSetChanged();
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
                    mImageDisplay.enableSticker(true);
                    mImageDisplay.changeSticker(mStickerlists.get(groupId).get(position).path);
                }
            }
        });
    }

    private void initNativeStickerAdapter(final String stickerClassName, final int index){
        mNativeStickerAdapters.get(stickerClassName).setSelectedPosition(-1);
        mNativeStickerAdapters.get(stickerClassName).setClickStickerListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                resetNewStickerAdapter();
                resetStickerAdapter();
                int position = Integer.parseInt(v.getTag().toString());

                if(mCurrentStickerOptionsIndex == index && mCurrentStickerPosition == position){
                    mNativeStickerAdapters.get(stickerClassName).setSelectedPosition(-1);
                    mCurrentStickerOptionsIndex = -1;
                    mCurrentStickerPosition = -1;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker_selected));
                    mImageDisplay.enableSticker(false);
                    mImageDisplay.changeSticker(null);

                }else{
                    mCurrentStickerOptionsIndex = index;
                    mCurrentStickerPosition = position;

                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));

                    mNativeStickerAdapters.get(stickerClassName).setSelectedPosition(position);
                    mImageDisplay.enableSticker(true);
                    mImageDisplay.changeSticker(mNewStickers.get(position).path);
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
//                        mImageDisplay.enableSticker(false);
//                    }
//
//                    if (mStickerPackageMap != null && mStickerPackageMap.get(position) != null) {
//                        mImageDisplay.removeSticker(mStickerPackageMap.get(position));
//                        mStickerPackageMap.remove(position);
//                    }
//                } else {
//                    mCurrentStickerOptionsIndex = index;
//                    mCurrentNewStickerPosition = position;
//
//                    findViewById(R.id.iv_close_sticker).setBackground(getResources().getDrawable(R.drawable.close_sticker));
//
//                    mImageDisplay.enableSticker(true);
//                    int packageId = mImageDisplay.addSticker(mNewStickers.get(position).path);
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
        final ArrayList<StickerItem> stickerList = new ArrayList<>();
        LogUtils.e(TAG, "group id is " + groupId + " materials size is " + materials.size());
        mStickerlists.put(groupId, stickerList);
        mStickerAdapters.put(groupId, new StickerAdapter(mStickerlists.get(groupId), getApplicationContext()));
        mStickerAdapters.get(groupId).setSelectedPosition(-1);
        initStickerListener(groupId, index, materials);
        for (int i = 0; i < materials.size(); i++) {
            SenseArMaterial sarm = materials.get(i);
            Bitmap bitmap = null;
            try {
                bitmap = ImageUtils.getImageSync(sarm.thumbnail, ImageActivity.this);

            } catch (Exception e) {
                e.printStackTrace();
            }
            if (bitmap == null) {
                bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.none);
            }
            String path = "";
            //如果已经下载则传入路径地址
            if (SenseArMaterialService.shareInstance().isMaterialDownloaded(ImageActivity.this, sarm)) {
                path = SenseArMaterialService.shareInstance().getMaterialCachedPath(ImageActivity.this, sarm);
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
        for(int i = 0; i < Constants.MAKEUP_TYPE_COUNT; i++){
            mImageDisplay.removeMakeupByType(i);
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
