package sensetime.senseme.com.effects

import android.app.Activity
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaScannerConnection
import android.net.Uri
import android.opengl.GLSurfaceView
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Message
import android.support.v7.app.AppCompatActivity
import android.support.v7.widget.LinearLayoutManager
import android.text.TextUtils
import android.util.Log
import android.view.View
import android.view.Window
import android.view.WindowManager
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import com.example.gengmei_app_face.CameraActivity
import com.example.gengmei_app_face.R
import com.example.gengmei_app_face.util.StatusBarUtil
import com.sensetime.sensearsourcemanager.SenseArMaterialService
import com.sensetime.stmobile.STBeautyParamsType.ST_BEAUTIFY_SMOOTH_MODE
import com.sensetime.stmobile.STBeautyParamsType.ST_BEAUTIFY_SMOOTH_STRENGTH
import kotlinx.android.synthetic.main.test_main.*
import sensetime.senseme.com.effects.display.ImageDisplay
import sensetime.senseme.com.effects.glutils.STUtils
import sensetime.senseme.com.effects.utils.Constants
import sensetime.senseme.com.effects.utils.FileUtils
import sensetime.senseme.com.effects.utils.LogUtils
import java.io.*
import java.lang.ref.WeakReference
import java.util.*
import kotlin.collections.ArrayList

/**
 * @author lsy
 * @date   2019-12-17
 */
class TestImageActivity : Activity() {

    var reference: WeakReference<Activity>? = null
    lateinit var myHandler: MyHandler
    lateinit var mImageDisplay: ImageDisplay
    private var mImageBitmap: Bitmap? = null
    var index = -1
    lateinit var adapter: TestAdapter
    var oriPath: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        setTheme(R.style.AppTheme)
        super.onCreate(savedInstanceState)
        StatusBarUtil.transparencyBar(this)
        setContentView(R.layout.test_main)
        reference = WeakReference(this@TestImageActivity);
        myHandler = MyHandler(reference);
        oriPath = intent.getStringExtra("PATH")
        index = intent.getIntExtra("INDEX", -1)
        if (TextUtils.isEmpty(oriPath)) {
            Toast.makeText(this, "路径为空", Toast.LENGTH_SHORT).show();
        }
        mImageBitmap = BitmapFactory.decodeFile(oriPath)
        initView()


    }

    override fun onResume() {
        super.onResume()
        mImageDisplay?.run {
            this.onResume()
        }
    }

    override fun onPause() {
        super.onPause()
        mImageDisplay?.run {
            this.onPause()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        myHandler.removeCallbacksAndMessages(null);
        reference = null
        mImageDisplay?.run {
            this.onDestroy()
        }
    }


    private fun initView() {
        re_pic.setOnClickListener {
            finish()
        }

        findViewById<Button>(R.id.saveImg).setOnClickListener {
            mImageDisplay?.run {
                val MBT = this.getBitmap()
                if (MBT != null) {
                    saveToSDCard(FileUtils.getOutputMediaFile(), MBT!!)
                }
            }

        }
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
        val t1 = System.currentTimeMillis()
        val glSurfaceView = findViewById<View>(R.id.id_gl_sv) as GLSurfaceView
        mImageDisplay = ImageDisplay(applicationContext, glSurfaceView, myHandler)
        Log.e("lsy", "  TIMEMEEE ${System.currentTimeMillis() - t1}");
        recycle.adapter = adapter
        recycle.postDelayed({
            FileUtils.copyModelFiles(this)
            mImageDisplay!!.enableSave(true)
            mImageDisplay!!.setImageBitmap(mImageBitmap)
            if (index != -1) {
                for (i in 0..adapter.list.size - 1) {
                    if (i == index) {
                        adapter.list.get(i).check = true
                        makeFace(adapter.list.get(i).list)
                    } else {
                        adapter.list.get(i).check = false
                    }
                }
                adapter.notifyDataSetChanged()
            } else {
                re_pic.visibility = View.GONE
            }
        }, 200)
    }


    inner class MyHandler(var ref: WeakReference<Activity>?) : Handler() {
        override fun handleMessage(msg: Message) {
            super.handleMessage(msg)
            if (ref == null || ref!!.get() == null) {
                return;
            }
            when (msg.what) {
                MSG_SAVING_IMG -> {
                    Log.e("lsy", "  SAVEEEEEE  ")
//                    mImageBitmap = mImageDisplay.getBitmap()
//                    saveToSDCard(FileUtils.getOutputMediaFile(), mImageBitmap!!)
                }
                //                case MSG_NEED_UPDATE_STICKER_MAP:
                //                    int packageId = msg.arg1;
                //                    mStickerPackageMap.put(mCurrentNewStickerPosition, packageId);
                //                    break;

                MSG_NEED_REPLACE_STICKER_MAP -> {
                    val oldPackageId = msg.arg1
                    val newPackageId = msg.arg2

//                    for (index in mStickerPackageMap.keys) {
//                        val stickerId = mStickerPackageMap.get(index)!!//得到每个key多对用value的值
//
//                        if (stickerId == oldPackageId) {
//                            mStickerPackageMap.put(index!!, newPackageId)
//                        }
//                    }
                }

                MSG_NEED_SHOW_TOO_MUCH_STICKER_TIPS -> runOnUiThread { Toast.makeText(this@TestImageActivity, "添加太多贴纸了", Toast.LENGTH_SHORT).show() }
            }
        }


    }

    fun saveToSDCard(file: File?, bmp: Bitmap) {

        var bos: BufferedOutputStream? = null
        try {
            bos = BufferedOutputStream(FileOutputStream(file!!))
            bmp.compress(Bitmap.CompressFormat.JPEG, 90, bos)
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
        this@TestImageActivity.sendBroadcast(mediaScanIntent)
        if (Build.VERSION.SDK_INT >= 19) {
            MediaScannerConnection.scanFile(this@TestImageActivity, arrayOf(path), null, null)
        }
        if (index != -1) {
            val intent = Intent()
            intent.putExtra(CameraActivity.CAMERA_RESULT, file.absolutePath)
            intent.putExtra(CameraActivity.CAMERA_INDEX, adapter.nowText)
            intent.putExtra(CameraActivity.CAMERA_ORIAL, oriPath);
            setResult(100456, intent)
            finish()
        } else {
            Toast.makeText(this, "保存成功", Toast.LENGTH_SHORT).show();
        }

    }

    fun makeFace(list: ArrayList<Float>) {
        mImageDisplay?.run {
            this.enableBeautify(true)
            this.enableMakeUp(true)
            this.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_FACE_RATIO, list[0])  /// 瘦脸比例, [0,1.0], 0.0不做瘦脸效果
            this.setBeautyParam(Constants.ST_BEAUTIFY_ENLARGE_EYE_RATIO, list[1])  /// 大眼比例, [0,1.0], 0.0不做大眼效果
            this.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_JAW_RATIO, list[2])  /// 小脸比例, [0,1.0], 0.0不做小脸效果
            this.setBeautyParam(Constants.ST_BEAUTIFY_NARROW_FACE_STRENGTH, list[3])   // 窄脸强度, [0,1.0], 默认值0, 0.0不做窄脸
            this.setBeautyParam(Constants.ST_BEAUTIFY_ROUND_EYE_RATIO, list[4])  /// 圆眼比例, [0,1.0], 默认值0.0, 0.0不做圆眼
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, list[5])  ///  瘦脸型比例， [0,1.0], 默认值0.0, 0.0不做瘦脸型效果
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, list[6])   // 下巴长短比例，[-1, 1], 默认值为0.0，[-1, 0]为短下巴，[0, 1]为长下巴
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, list[7])  // 发际线高低比例，[-1, 1], 默认值为0.0，[-1, 0]为高发际线，[0, 1]为低发际线
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, list[8])    /// 苹果肌比例，[0, 1.0]，默认值为0.0，0.0不做苹果肌
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, list[9])  // 瘦鼻比例，[0, 1.0], 默认值为0.0，0.0不做瘦鼻
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, list[10])  // 鼻子长短比例，[-1, 1], 默认值为0.0, [-1, 0]为短鼻，[0, 1]为长鼻
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, list[11])   // 嘴型比例，[-1, 1]，默认值为0.0，[-1, 0]为放大嘴巴，[0, 1]为缩小嘴巴
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, list[12])   // 人中长短比例，[-1, 1], 默认值为0.0，[-1, 0]为短人中，[0, 1]为长人中
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, list[13])   /// 眼距比例，[-1, 1]，默认值为0.0，[-1, 0]为减小眼距，[0, 1]为增加眼距
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, list[14])   /// 眼睛角度调整比例，[-1, 1]，默认值为0.0，[-1, 0]为左眼逆时针旋转，[0, 1]为左眼顺时针旋转，右眼与左眼相对
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, list[15])   /// 开眼角比例，[0, 1.0]，默认值为0.0， 0.0不做开眼角
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, list[16])   /// 去黑眼圈比例，[0, 1.0]，默认值为0.0，0.0不做去黑眼圈
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, list[17])    /// 去法令纹比例，[0, 1.0]，默认值为0.0，0.0不做去法令纹
        }
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
        mImageDisplay?.run {
            this.enableBeautify(false)
            this.enableMakeUp(false)
            this.setBeautyParam(Constants.ST_BEAUTIFY_REDDEN_STRENGTH, 0.0f)// 红润强度, [0,1.0], 0.0不做红润
            this.setBeautyParam(ST_BEAUTIFY_SMOOTH_MODE, 0.0f) /// 磨皮模式, 默认值1.0, 1.0表示对全图磨皮, 0.0表示只对人脸磨皮
            this.setBeautyParam(Constants.ST_BEAUTIFY_SMOOTH_STRENGTH, 0.0f)  // 磨皮强度, [0,1.0], 0.0不做磨皮
            this.setBeautyParam(Constants.ST_BEAUTIFY_WHITEN_STRENGTH, 0.0f)  /// 美白强度, [0,1.0], 0.0不做美白
            this.setBeautyParam(Constants.ST_BEAUTIFY_ENLARGE_EYE_RATIO, 0.0f)  /// 大眼比例, [0,1.0], 0.0不做大眼效果
            this.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_FACE_RATIO, 0.0f)  /// 瘦脸比例, [0,1.0], 0.0不做瘦脸效果
            this.setBeautyParam(Constants.ST_BEAUTIFY_SHRINK_JAW_RATIO, 0.0f)  /// 小脸比例, [0,1.0], 0.0不做小脸效果
            this.setBeautyParam(Constants.ST_BEAUTIFY_CONSTRACT_STRENGTH, 0.0f)  // 对比度
            this.setBeautyParam(Constants.ST_BEAUTIFY_SATURATION_STRENGTH, 0.0f)  // 饱和度
            this.setBeautyParam(Constants.ST_BEAUTIFY_DEHIGHLIGHT_STRENGTH, 0.0f)  // 去高光强度, [0,1.0], 默认值1, 0.0不做高光
            this.setBeautyParam(Constants.ST_BEAUTIFY_NARROW_FACE_STRENGTH, 0.0f)   // 窄脸强度, [0,1.0], 默认值0, 0.0不做窄脸
            this.setBeautyParam(Constants.ST_BEAUTIFY_ROUND_EYE_RATIO, 0.0f)  /// 圆眼比例, [0,1.0], 默认值0.0, 0.0不做圆眼
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, 0.0f)  // 瘦鼻比例，[0, 1.0], 默认值为0.0，0.0不做瘦鼻
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, 0.0f)  // 鼻子长短比例，[-1, 1], 默认值为0.0, [-1, 0]为短鼻，[0, 1]为长鼻
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, 0.0f)   // 下巴长短比例，[-1, 1], 默认值为0.0，[-1, 0]为短下巴，[0, 1]为长下巴
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, 0.0f)   // 嘴型比例，[-1, 1]，默认值为0.0，[-1, 0]为放大嘴巴，[0, 1]为缩小嘴巴
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, 0.0f)   // 人中长短比例，[-1, 1], 默认值为0.0，[-1, 0]为短人中，[0, 1]为长人中
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, 0.0f)  // 发际线高低比例，[-1, 1], 默认值为0.0，[-1, 0]为高发际线，[0, 1]为低发际线
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, 0.0f)  ///  瘦脸型比例， [0,1.0], 默认值0.0, 0.0不做瘦脸型效果
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, 0.0f)   /// 眼距比例，[-1, 1]，默认值为0.0，[-1, 0]为减小眼距，[0, 1]为增加眼距
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, 0.0f)   /// 眼睛角度调整比例，[-1, 1]，默认值为0.0，[-1, 0]为左眼逆时针旋转，[0, 1]为左眼顺时针旋转，右眼与左眼相对
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, 0.0f)   /// 开眼角比例，[0, 1.0]，默认值为0.0， 0.0不做开眼角
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_PROFILE_RHINOPLASTY_RATIO, 0.0f)   /// 侧脸隆鼻比例，[0, 1.0]，默认值为0.0，0.0不做侧脸隆鼻效果
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_BRIGHT_EYE_RATIO, 0.0f)   /// 亮眼比例，[0, 1.0]，默认值为0.0，0.0不做亮眼
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, 0.0f)   /// 去黑眼圈比例，[0, 1.0]，默认值为0.0，0.0不做去黑眼圈
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, 0.0f)    /// 去法令纹比例，[0, 1.0]，默认值为0.0，0.0不做去法令纹
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_WHITE_TEETH_RATIO, 0.0f)    /// 白牙比例，[0, 1.0]，默认值为0.0，0.0不做白牙
            this.setBeautyParam(Constants.ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, 0.0f)    /// 苹果肌比例，[0, 1.0]，默认值为0.0，0.0不做苹果肌
        }
    }

    companion object {
        val MSG_SAVING_IMG = 1
        val MSG_SAVED_IMG = 2
        val MSG_NEED_REPLACE_STICKER_MAP = 106
        val MSG_NEED_SHOW_TOO_MUCH_STICKER_TIPS = 107
        //正式服appid appkey
        val APPID = "6dc0af51b69247d0af4b0a676e11b5ee"//正式服
        val APPKEY = "e4156e4d61b040d2bcbf896c798d06e3"//正式服
        val TAG = "LSY"

        private val PERMISSION_REQUEST_WRITE_PERMISSION = 101
    }
}