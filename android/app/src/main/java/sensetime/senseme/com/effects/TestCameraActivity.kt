package sensetime.senseme.com.effects

import android.animation.Animator
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.PixelFormat
import android.media.MediaScannerConnection
import android.net.Uri
import android.opengl.GLSurfaceView
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Message
import android.support.v7.app.AppCompatActivity
import android.support.v7.widget.LinearLayoutManager
import android.util.Log
import android.view.SurfaceView
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.Toast
import com.example.gengmei_app_face.CameraActivity
import com.example.gengmei_app_face.R
import com.example.gengmei_app_face.util.StatusBarUtil
import com.example.gengmei_app_face.util.addTo
import com.sensetime.sensearsourcemanager.SenseArMaterialService
import com.sensetime.stmobile.STBeautyParamsType
import io.alterac.blurkit.BlurKit
import io.alterac.blurkit.BlurLayout
import io.reactivex.Observable
import io.reactivex.ObservableOnSubscribe
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import kotlinx.android.synthetic.main.camera_main.camera_back
import kotlinx.android.synthetic.main.test_main.recycle
import kotlinx.android.synthetic.main.test_main_camera.*
import sensetime.senseme.com.effects.CameraActivity.*
import sensetime.senseme.com.effects.display.CameraDisplayDoubleInputMultithread
import sensetime.senseme.com.effects.display.ChangePreviewSizeListener
import sensetime.senseme.com.effects.utils.*
import sensetime.senseme.com.effects.view.StickerOptionsItem
import java.io.*
import java.lang.ref.WeakReference
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.*

/**
 * @author lsy
 * @date   2019-12-31
 */
class TestCameraActivity : AppCompatActivity() {

    private val TAG = "CameraActivity"
    //正式服appid appkey
    val APPID = "6dc0af51b69247d0af4b0a676e11b5ee"//正式服
    val APPKEY = "e4156e4d61b040d2bcbf896c798d06e3"//正式服
    val GROUP_2D = "3cd2dae0f6c211e8877702f2beb67403"
    val GROUP_3D = "4e869010f6c211e888ea020d88863a42"
    val GROUP_HAND = "5aea6840f6c211e899f602f2be7c2171"
    val GROUP_BG = "65365cf0f6c211e8877702f2beb67403"
    val GROUP_FACE = "6d036ef0f6c211e899f602f2be7c2171"
    val GROUP_AVATAR = "46028a20f6c211e888ea020d88863a42"
    val GROUP_BEAUTY = "73bffb50f6c211e899f602f2be7c2171"
    val GROUP_PARTICLE = "7c6089f0f6c211e8877702f2beb67403"
    var changePic = ""

    private val mStickerOptionsList = ArrayList<StickerOptionsItem>()


    private var mAccelerometer: Accelerometer? = null
    private var mSurfaceViewOverlap: SurfaceView? = null
    private var mPreviewFrameLayout: FrameLayout? = null
    var reference: WeakReference<Activity>? = null
    lateinit var mCameraDisplay: CameraDisplayDoubleInputMultithread

    private val mChangePreviewSizeListener = ChangePreviewSizeListener { previewW, previewH -> this@TestCameraActivity.runOnUiThread(Runnable { mPreviewFrameLayout!!.requestLayout() }) }
    lateinit var myHandler: MyHandler
    private var mIsHasAudioPermission = false
    lateinit var mMeteringArea: ImageView
    lateinit var adapter: TestAdapter
    private val disposable = CompositeDisposable()
    var hideBitmap: Bitmap? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme)
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        reference = WeakReference(this@TestCameraActivity);
        myHandler = MyHandler(reference);
        //进程后台时被系统强制kill，需重新checkLicense
        if (savedInstanceState != null && savedInstanceState.getBoolean("process_killed")) {
            if (!STLicenseUtils.checkLicense(this)) {
                runOnUiThread { Toast.makeText(applicationContext, "请检查License授权！", Toast.LENGTH_SHORT).show() }
            }
        }
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContentView(R.layout.test_main_camera)
        FileUtils.copyModelFiles(this)
        initView()
        initVieww()
        BlurKit.init(this);
        switch_camera.setOnClickListener { mCameraDisplay.switchCamera() }

    }

    fun initVieww() {
        findViewById<ImageView>(R.id.back).setOnClickListener {
            finish();
        }
        val list = ListHelper.getMakeList()

        val linearLayoutManager = LinearLayoutManager(this)
        linearLayoutManager.orientation = LinearLayoutManager.HORIZONTAL
        recycle.layoutManager = linearLayoutManager
        adapter = TestAdapter(
                this, list, object : TestAdapter.TextClickListener {
            override fun onClick(data: ArrayList<Float>) {
                makeFace(data)
            }
        })
        recycle.adapter = adapter

        recycle.post {
            val iterator = adapter.list.iterator();
            while (iterator.hasNext()) {
                val next = iterator.next()
                next.check = false;
            }
            adapter.list.get(1).check = true
            makeFace(list.get(1).list);
            adapter.notifyDataSetChanged()
        }
    }

    fun saveToSDCard(file: File?, bmp: Bitmap) {
        var bos: BufferedOutputStream? = null
        try {
            bos = BufferedOutputStream(FileOutputStream(file!!))
            bmp.compress(Bitmap.CompressFormat.JPEG, 100, bos)
        } catch (e: FileNotFoundException) {
            e.printStackTrace()
        } finally {
            if (bos != null)
                try {
                    bos.close()
                } catch (e: IOException) {
                    e.printStackTrace()
                }

        }

        val path = file!!.absolutePath
        val mediaScanIntent = Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE)
        val contentUri = Uri.fromFile(file)
        mediaScanIntent.data = contentUri
        this@TestCameraActivity.sendBroadcast(mediaScanIntent)
        if (Build.VERSION.SDK_INT >= 19) {
            MediaScannerConnection.scanFile(this@TestCameraActivity, arrayOf(path), null, null)
        }

    }

    fun initView() {

        mAccelerometer = Accelerometer(applicationContext)
        val glSurfaceView = findViewById<View>(R.id.id_gl_sv) as GLSurfaceView
        mSurfaceViewOverlap = findViewById<View>(R.id.surfaceViewOverlap) as SurfaceView
        mPreviewFrameLayout = findViewById<View>(R.id.id_preview_layout) as FrameLayout
        mCameraDisplay = CameraDisplayDoubleInputMultithread(applicationContext, mChangePreviewSizeListener, glSurfaceView)
        mCameraDisplay!!.setHandler(myHandler)
        mCameraDisplay!!.enableBeautify(true)
        mIsHasAudioPermission = CheckAudioPermission.isHasPermission(this@TestCameraActivity)
        mSurfaceViewOverlap!!.setZOrderOnTop(true)
        mSurfaceViewOverlap!!.setZOrderMediaOverlay(true)
        mSurfaceViewOverlap!!.getHolder().setFormat(PixelFormat.TRANSLUCENT)
        camera_back.setOnClickListener {
            //            val view = findViewById<FrameLayout>(R.id.id_preview_layout)
//            view.isDrawingCacheEnabled=true
//            val blur = BlurKit.getInstance().blur(view.getDrawingCache(), 25)
//            if (blur != null) {
//                hideImage.visibility = View.VISIBLE
//                hideImage.setImageBitmap(blur)
//            } else {
//                loadingView.visibility = View.VISIBLE
//            }
            mCameraDisplay.toBlur();

        }

        //new
        //使用本地模型加载
        mStickerOptionsList.add(0, StickerOptionsItem("sticker_new_engine", BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_local_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_local_selected)))
        //2d
        mStickerOptionsList.add(1, StickerOptionsItem(GROUP_2D, BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_2d_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_2d_selected)))
        //3d
        mStickerOptionsList.add(2, StickerOptionsItem(GROUP_3D, BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_3d_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_3d_selected)))
        //手势贴纸
        mStickerOptionsList.add(3, StickerOptionsItem(GROUP_HAND, BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_hand_action_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_hand_action_selected)))
        //背景贴纸
        mStickerOptionsList.add(4, StickerOptionsItem(GROUP_BG, BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_bg_segment_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_bg_segment_selected)))
        //脸部变形贴纸
        mStickerOptionsList.add(5, StickerOptionsItem(GROUP_FACE, BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_dedormation_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_dedormation_selected)))
        //avatar
        mStickerOptionsList.add(6, StickerOptionsItem(GROUP_AVATAR, BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_avatar_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_avatar_selected)))
        //美妆贴纸
        mStickerOptionsList.add(7, StickerOptionsItem(GROUP_BEAUTY, BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_face_morph_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.sticker_face_morph_selected)))
        //粒子贴纸
        mStickerOptionsList.add(8, StickerOptionsItem(GROUP_PARTICLE, BitmapFactory.decodeResource(this.getResources(), R.drawable.particles_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.particles_selected)))
        //通用物体跟踪
        mStickerOptionsList.add(9, StickerOptionsItem("object_track", BitmapFactory.decodeResource(this.getResources(), R.drawable.object_track_unselected), BitmapFactory.decodeResource(this.getResources(), R.drawable.object_track_selected)))

        mMeteringArea = ImageView(this)
        mMeteringArea.setImageResource(R.drawable.choose)
        val layoutParams = FrameLayout.LayoutParams(80, 80)
        mMeteringArea.setLayoutParams(layoutParams)
        mPreviewFrameLayout!!.addView(mMeteringArea)
        mMeteringArea.setVisibility(View.INVISIBLE)
    }

    private fun perFormSetMeteringArea(touchX: Float, touchY: Float) {
        mCameraDisplay.setMeteringArea(touchX, touchY)
        val params = mMeteringArea.layoutParams as FrameLayout.LayoutParams
        params.setMargins(touchX.toInt() - 50, touchY.toInt() - 50, 0, 0)
        mMeteringArea.layoutParams = params
        mMeteringArea.visibility = View.VISIBLE
        val animatorSet = AnimatorSet()
        val animX = ObjectAnimator.ofFloat(mMeteringArea, "scaleX", 1.5f, 1.2f)
        val animY = ObjectAnimator.ofFloat(mMeteringArea, "scaleY", 1.5f, 1.2f)
        animatorSet.duration = 500
        animatorSet.play(animX).with(animY)
        animatorSet.start()
        animatorSet.addListener(object : Animator.AnimatorListener {
            override fun onAnimationStart(animation: Animator) {

            }

            override fun onAnimationEnd(animation: Animator) {
                mMeteringArea.visibility = View.INVISIBLE
            }

            override fun onAnimationCancel(animation: Animator) {

            }

            override fun onAnimationRepeat(animation: Animator) {

            }
        })
    }

    override fun onResume() {
        LogUtils.i(TAG, "onResume")
        super.onResume()
        mAccelerometer!!.start()
        mCameraDisplay!!.onResume()
        mCameraDisplay!!.setShowOriginal(false)


        mIsPaused = false
        for (i in 0..adapter.list.size - 1) {
            makeFace(adapter.list.get(i).list)
        }
    }

    private var mIsPaused = false

    override fun onPause() {
        super.onPause()
        LogUtils.i(TAG, "onPause")
        mIsPaused = true
        mAccelerometer!!.stop()
        mCameraDisplay!!.onPause()
    }


    override fun onDestroy() {
        mCameraDisplay.onDestroy()
        disposable.dispose();
        myHandler.removeCallbacksAndMessages(null)
        super.onDestroy()
//        mStickerAdapters.clear()
//        mNativeStickerAdapters.clear()
//        mStickerlists.clear()
//        mBeautyParamsSeekBarList.clear()
//        mFilterAdapters.clear()
//        mFilterLists.clear()
//        mObjectList.clear()
//        mStickerOptionsList.clear()
//        mBeautyOptionsList.clear()
//        if (mStickerPackageMap != null) {
//            mStickerPackageMap.clear()
//            mStickerPackageMap = null
//        }
    }

    private fun initStickerListFromNet() {
        SenseArMaterialService.shareInstance().authorizeWithAppId(this, APPID, APPKEY, object : SenseArMaterialService.OnAuthorizedListener {
            override fun onSuccess() {
                LogUtils.d(TAG, "鉴权成功！")
            }

            override fun onFailure(errorCode: SenseArMaterialService.AuthorizeErrorCode, errorMsg: String) {
                LogUtils.d(TAG, String.format(Locale.getDefault(), "鉴权失败！%d, %s", errorCode, errorMsg))
            }
        })
    }


    fun makeFace(list: ArrayList<Float>) {
        mCameraDisplay.enableBeautify(true)
        mCameraDisplay.enableMakeUp(true)

        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_FACE_RATIO, list[0])  /// 瘦脸比例, [0,1.0], 0.0不做瘦脸效果
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_ENLARGE_EYE_RATIO, list[1])  /// 大眼比例, [0,1.0], 0.0不做大眼效果
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_JAW_RATIO, list[2])  /// 小脸比例, [0,1.0], 0.0不做小脸效果
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_NARROW_FACE_STRENGTH, list[3])   // 窄脸强度, [0,1.0], 默认值0, 0.0不做窄脸
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_ROUND_EYE_RATIO, list[4])  /// 圆眼比例, [0,1.0], 默认值0.0, 0.0不做圆眼
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, list[5])  ///  瘦脸型比例， [0,1.0], 默认值0.0, 0.0不做瘦脸型效果
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, list[6])   // 下巴长短比例，[-1, 1], 默认值为0.0，[-1, 0]为短下巴，[0, 1]为长下巴
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, list[7])  // 发际线高低比例，[-1, 1], 默认值为0.0，[-1, 0]为高发际线，[0, 1]为低发际线
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, list[8])    /// 苹果肌比例，[0, 1.0]，默认值为0.0，0.0不做苹果肌
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, list[9])  // 瘦鼻比例，[0, 1.0], 默认值为0.0，0.0不做瘦鼻
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, list[10])  // 鼻子长短比例，[-1, 1], 默认值为0.0, [-1, 0]为短鼻，[0, 1]为长鼻
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, list[11])   // 嘴型比例，[-1, 1]，默认值为0.0，[-1, 0]为放大嘴巴，[0, 1]为缩小嘴巴
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, list[12])   // 人中长短比例，[-1, 1], 默认值为0.0，[-1, 0]为短人中，[0, 1]为长人中
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, list[13])   /// 眼距比例，[-1, 1]，默认值为0.0，[-1, 0]为减小眼距，[0, 1]为增加眼距
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, list[14])   /// 眼睛角度调整比例，[-1, 1]，默认值为0.0，[-1, 0]为左眼逆时针旋转，[0, 1]为左眼顺时针旋转，右眼与左眼相对
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, list[15])   /// 开眼角比例，[0, 1.0]，默认值为0.0， 0.0不做开眼角
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, list[16])   /// 去黑眼圈比例，[0, 1.0]，默认值为0.0，0.0不做去黑眼圈
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, list[17])    /// 去法令纹比例，[0, 1.0]，默认值为0.0，0.0不做去法令纹
//        mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_REDDEN_STRENGTH, 1.0f)// 红润强度, [0,1.0], 0.0不做红润
//        mImageDisplay.setBeautyParam(ST_BEAUTIFY_SMOOTH_MODE, 1.0f) /// 磨皮模式, 默认值1.0, 1.0表示对全图磨皮, 0.0表示只对人脸磨皮
//        mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SMOOTH_STRENGTH, 1.0f)  // 磨皮强度, [0,1.0], 0.0不做磨皮
//        mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_WHITEN_STRENGTH, 1.0f)  /// 美白强度, [0,1.0], 0.0不做美白
//        mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_CONSTRACT_STRENGTH, 1.0f)  // 对比度
//        mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SATURATION_STRENGTH, 1.0f)  // 饱和度
//        mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_DEHIGHLIGHT_STRENGTH, 1.0f)  // 去高光强度, [0,1.0], 默认值1, 0.0不做高光
//        mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_PROFILE_RHINOPLASTY_RATIO, 1.0f)   /// 侧脸隆鼻比例，[0, 1.0]，默认值为0.0，0.0不做侧脸隆鼻效果
//        mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_BRIGHT_EYE_RATIO, 1.0f)   /// 亮眼比例，[0, 1.0]，默认值为0.0，0.0不做亮眼
//        mImageDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_WHITE_TEETH_RATIO, 1.0f)    /// 白牙比例，[0, 1.0]，默认值为0.0，0.0不做白牙
    }


    fun reset() {
        mCameraDisplay.enableBeautify(true)
        mCameraDisplay.enableMakeUp(true)
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_REDDEN_STRENGTH, 0.0f)// 红润强度, [0,1.0], 0.0不做红润
        mCameraDisplay.setBeautyParam(STBeautyParamsType.ST_BEAUTIFY_SMOOTH_MODE, 0.0f) /// 磨皮模式, 默认值1.0, 1.0表示对全图磨皮, 0.0表示只对人脸磨皮
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SMOOTH_STRENGTH, 0.0f)  // 磨皮强度, [0,1.0], 0.0不做磨皮
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_WHITEN_STRENGTH, 0.0f)  /// 美白强度, [0,1.0], 0.0不做美白
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_ENLARGE_EYE_RATIO, 0.0f)  /// 大眼比例, [0,1.0], 0.0不做大眼效果
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_FACE_RATIO, 0.0f)  /// 瘦脸比例, [0,1.0], 0.0不做瘦脸效果
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_JAW_RATIO, 0.0f)  /// 小脸比例, [0,1.0], 0.0不做小脸效果
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_CONSTRACT_STRENGTH, 0.0f)  // 对比度
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_SATURATION_STRENGTH, 0.0f)  // 饱和度
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_DEHIGHLIGHT_STRENGTH, 0.0f)  // 去高光强度, [0,1.0], 默认值1, 0.0不做高光
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_NARROW_FACE_STRENGTH, 0.0f)   // 窄脸强度, [0,1.0], 默认值0, 0.0不做窄脸
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_ROUND_EYE_RATIO, 0.0f)  /// 圆眼比例, [0,1.0], 默认值0.0, 0.0不做圆眼
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, 0.0f)  // 瘦鼻比例，[0, 1.0], 默认值为0.0，0.0不做瘦鼻
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, 0.0f)  // 鼻子长短比例，[-1, 1], 默认值为0.0, [-1, 0]为短鼻，[0, 1]为长鼻
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, 0.0f)   // 下巴长短比例，[-1, 1], 默认值为0.0，[-1, 0]为短下巴，[0, 1]为长下巴
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, 0.0f)   // 嘴型比例，[-1, 1]，默认值为0.0，[-1, 0]为放大嘴巴，[0, 1]为缩小嘴巴
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, 0.0f)   // 人中长短比例，[-1, 1], 默认值为0.0，[-1, 0]为短人中，[0, 1]为长人中
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, 0.0f)  // 发际线高低比例，[-1, 1], 默认值为0.0，[-1, 0]为高发际线，[0, 1]为低发际线
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, 0.0f)  ///  瘦脸型比例， [0,1.0], 默认值0.0, 0.0不做瘦脸型效果
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, 0.0f)   /// 眼距比例，[-1, 1]，默认值为0.0，[-1, 0]为减小眼距，[0, 1]为增加眼距
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, 0.0f)   /// 眼睛角度调整比例，[-1, 1]，默认值为0.0，[-1, 0]为左眼逆时针旋转，[0, 1]为左眼顺时针旋转，右眼与左眼相对
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, 0.0f)   /// 开眼角比例，[0, 1.0]，默认值为0.0， 0.0不做开眼角
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_PROFILE_RHINOPLASTY_RATIO, 0.0f)   /// 侧脸隆鼻比例，[0, 1.0]，默认值为0.0，0.0不做侧脸隆鼻效果
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_BRIGHT_EYE_RATIO, 0.0f)   /// 亮眼比例，[0, 1.0]，默认值为0.0，0.0不做亮眼
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, 0.0f)   /// 去黑眼圈比例，[0, 1.0]，默认值为0.0，0.0不做去黑眼圈
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, 0.0f)    /// 去法令纹比例，[0, 1.0]，默认值为0.0，0.0不做去法令纹
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_WHITE_TEETH_RATIO, 0.0f)    /// 白牙比例，[0, 1.0]，默认值为0.0，0.0不做白牙
        mCameraDisplay.setBeautyParam(Constants.ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, 0.0f)    /// 苹果肌比例，[0, 1.0]，默认值为0.0，0.0不做苹果肌

    }

    var taked: Boolean = false
    private fun onPictureTaken(data: ByteBuffer, file: File?, mImageWidth: Int, mImageHeight: Int) {
        if (mImageWidth <= 0 || mImageHeight <= 0)
            return
        Observable.create(ObservableOnSubscribe<String> {
            val srcBitmap = Bitmap.createBitmap(mImageWidth, mImageHeight, Bitmap.Config.ARGB_8888)
            data.position(0)
            srcBitmap.copyPixelsFromBuffer(data)
            saveToSDCard(file, srcBitmap)
            srcBitmap.recycle()
            it.onNext(file!!.absolutePath);
        }).subscribeOn(Schedulers.computation())
                .observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    val intent1 = Intent(applicationContext, sensetime.senseme.com.effects.TestImageActivity::class.java)
                    var index = 0
                    for (i in 0..adapter.list.size - 1) {
                        if (adapter.list.get(i).check) {
                            index = i;
                            break
                        }
                    }
                    Log.e("lsy", "  INDEX ${index}")
                    intent1.putExtra("INDEX", index)
                    intent1.putExtra("PATH", file!!.absolutePath)
                    startActivityForResult(intent1, 12312)
                }, {
                    it.printStackTrace()
                }).addTo(disposable);

//        if (!taked) {
//            val intent1 = Intent(applicationContext, sensetime.senseme.com.effects.TestImageActivity::class.java)
//            intent1.putExtra("ORI_PATH", file!!.absolutePath)
//            intent1.putExtra("PATH", file!!.absolutePath)
//            startActivity(intent1)
//            finish()
//        }
//        changePic=file!!.absolutePath;
//
//        taked = true
//        mCameraDisplay.setSaveImage()

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        loadingView.visibility = View.GONE
        hideImage.visibility = View.GONE
        if (requestCode == 12312) {
            if (data != null) {
                val intent = Intent()
                intent.putExtra(CameraActivity.CAMERA_RESULT, data.getStringExtra(CameraActivity.CAMERA_RESULT))
                intent.putExtra(CameraActivity.CAMERA_INDEX, adapter.nowText)
                intent.putExtra(CameraActivity.CAMERA_ORIAL, data.getStringExtra(CameraActivity.CAMERA_ORIAL));
                setResult(100456, intent)
                finish()
            }
        }
    }

    inner class MyHandler(var ref: WeakReference<Activity>?) : Handler() {
        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)
            if (ref == null || ref!!.get() == null) {
                return;
            }
            when (msg.what) {
                MSG_SAVING_IMG -> {
                    val data = msg.obj as ByteBuffer
                    val bundle = msg.data
                    val imageWidth = bundle.getInt("imageWidth")
                    val imageHeight = bundle.getInt("imageHeight")
                    onPictureTaken(data, FileUtils.getOutputMediaFile(), imageWidth, imageHeight)
                }
                MSG_BITMAP -> {

                    val data = msg.obj as ByteBuffer
                    val bundle = msg.data
                    val imageWidth = bundle.getInt("imageWidth")
                    val imageHeight = bundle.getInt("imageHeight")
                    val srcBitmap = Bitmap.createBitmap(imageWidth, imageHeight, Bitmap.Config.ARGB_8888)
                    data.position(0)
                    srcBitmap.copyPixelsFromBuffer(data)
                    val newBitmap = BlurKit.getInstance().blur(srcBitmap, 25);
//                    srcBitmap.recycle()
//                    Log.e("lsy"," ${newBitmap}")
                    hideImage.visibility = View.VISIBLE
//                    hideImage.bringToFront()
                    hideImage.setImageBitmap(newBitmap)
                    myHandler.postDelayed({
                        reset()
                        myHandler.postDelayed({
                            mCameraDisplay.setSaveImage()
                        }, 360)
                    }, 100)
                }
                MSG_SAVED_IMG -> {
                    Log.e("lsy", "  HHHH  图片保存成功")
                }

                TestImageActivity.MSG_SAVING_IMG -> {
                    Log.e("lsy", "  SAVEEEEEE  ")
//                    mImageBitmap = mImageDisplay.getBitmap()
//                    saveToSDCard(FileUtils.getOutputMediaFile(), mImageBitmap!!)
                }
                //                case MSG_NEED_UPDATE_STICKER_MAP:
                //                    int packageId = msg.arg1;
                //                    mStickerPackageMap.put(mCurrentNewStickerPosition, packageId);
                //                    break;

                TestImageActivity.MSG_NEED_REPLACE_STICKER_MAP -> {
                    val oldPackageId = msg.arg1
                    val newPackageId = msg.arg2

                }

                TestImageActivity.MSG_NEED_SHOW_TOO_MUCH_STICKER_TIPS -> runOnUiThread { Toast.makeText(this@TestCameraActivity, "添加太多贴纸了", Toast.LENGTH_SHORT).show() }
            }
        }
    }
}