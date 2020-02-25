package com.bytedance.labcv.demo.ai

import android.content.Context
import android.graphics.SurfaceTexture
import android.hardware.Camera
import android.opengl.GLES20
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.view.View
import com.bytedance.labcv.demo.camera.CameraListener
import com.bytedance.labcv.demo.camera.CameraProxy
import com.bytedance.labcv.demo.core.video.VideoEffectHelper
import com.bytedance.labcv.demo.opengl.GlUtil
import com.bytedance.labcv.demo.utils.*
import com.bytedance.labcv.effectsdk.BytedEffectConstants
import com.example.gengmei_app_face.R
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

/**
 * @author lsy
 * @date   2020-02-24
 */
class MYVideoAC : BaseEffectActivity(), SurfaceTexture.OnFrameAvailableListener {

    @Volatile
    private var mCameraChanging = false
    private var mCameraID = android.hardware.Camera.CameraInfo.CAMERA_FACING_FRONT
    private val mCameraProxy: CameraProxy  by lazy { CameraProxy(this) }
    private val mFrameRator: FrameRator by lazy { FrameRator() }
    private var mDstTexture = GlUtil.NO_TEXTURE

    override fun onCreateImpl() {
        mContext = this@MYVideoAC
        mBaseEffectHelper = VideoEffectHelper(mContext)
        mBaseEffectHelper.setOnEffectListener(this)
        mHandler = InnerHandler(this)
    }

    override fun onEffectInitializedImpl() {
        val features = arrayOfNulls<String>(30)
        mBaseEffectHelper.getAvailableFeatures(features)
        for (feature in features) {
            if (feature != null && feature == "3DStickerV3") {
                break
            }
        }
    }

    override fun onDrawFrame(gl: GL10?) {
        if (mCameraChanging || mIsPaused) {
            return
        }
        //清空缓冲区颜色
        //Clear buffer color
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)
        if (!mCameraProxy.isCameraValid) return
        mCameraProxy.updateTexture()

        var rotation = OrientationSensor.getOrientation()
        // tv sensor get an 270 ……
        if (AppUtils.isTv(mContext)) {
            rotation = BytedEffectConstants.Rotation.CLOCKWISE_ROTATE_0
        }
        // 在DrawFrame中设置相机是否是前置最可靠
        mBaseEffectHelper.setCameraPosition(mCameraProxy.isFrontCamera)
        mDstTexture = (mBaseEffectHelper as VideoEffectHelper).processTexure(mCameraProxy.previewTexture, BytedEffectConstants.TextureFormat.Texture_Oes, mCameraProxy.previewWidth, mCameraProxy.previewHeight, mCameraProxy.orientation, mCameraProxy.isFrontCamera, rotation, mCameraProxy.timeStamp)
        if (mDstTexture != GlUtil.NO_TEXTURE) {
            (mBaseEffectHelper as VideoEffectHelper).drawFrame(mDstTexture, BytedEffectConstants.TextureFormat.Texure2D, mCameraProxy.previewWidth, mCameraProxy.previewHeight, 360 - mCameraProxy.orientation, mCameraProxy.isFrontCamera, false)

        }
        mFrameRator.addFrameStamp()
    }

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        LogUtils.d("onSurfaceCreated: ")
        GLES20.glEnable(GL10.GL_DITHER)
        GLES20.glClearColor(0f, 0f, 0f, 0f)
        mBaseEffectHelper.initEffectSDK()
        mBaseEffectHelper.recoverStatus()
        mFrameRator.start()
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        if (mIsPaused) {
            return
        }
        mBaseEffectHelper.onSurfaceChanged(width, height)
    }


    override fun onFrameAvailable(surfaceTexture: SurfaceTexture?) {
        if (!mCameraChanging && null != mSurfaceView) {
            mSurfaceView.requestRender()
        }
    }

    override  fun onClick(v: View) {
        if (CommonUtils.isFastClick()) {
            ToastUtils.show("too fast click")
            return
        }
        when (v.id) {
            R.id.iv_change_camera -> switchCamera()
            R.id.btn_take_pic -> takePic(false)
        }

    }

    /**
     * 切换前后置相机
     */
    fun switchCamera() {
        LogUtils.d("switchCamera")
        if (null == mSurfaceView) return
        if (Camera.getNumberOfCameras() == 1 || mCameraChanging) {
            return
        }
        mCameraID = 1 - mCameraID
        mCameraChanging = true
        mSurfaceView.queueEvent {
            mCameraProxy.changeCamera(mCameraID, object : CameraListener {
                override fun onOpenSuccess() {
                    mSurfaceView.queueEvent {
                        LogUtils.d("onOpenSuccess")
                        mCameraProxy.deleteTexture()
                        onCameraOpen()
                        mCameraChanging = false
                        mSurfaceView.requestRender()
                    }

                }

                override fun onOpenFail() {
                    LogUtils.e("camera openFail!!")
                }
            })
        }
    }

    override fun getContext(): Context {
        return mContext
    }

    override fun getFrameRateImpl(): Int {
        return if (null == mSurfaceView) 0 else mFrameRator.frameRate
    }

    /**
     * 相机打开成功时回调，初始化特效SDK
     * Initialize camera information (texture, etc.)
     */
    private fun onCameraOpen() {
        LogUtils.d("CameraSurfaceView onCameraOpen")
        mCameraProxy.startPreview(this)
    }


    override fun onPauseImpl() {
        LogUtils.d("onPause")
        mIsPaused = true
        mFrameRator.stop()
        mSurfaceView.queueEvent {
            mCameraProxy.releaseCamera()
            mCameraProxy.deleteTexture()
            mBaseEffectHelper.destroyEffectSDK()
        }
    }

    override fun onResumeImpl() {
        LogUtils.d("onResumeImpl  $localClassName")
        mIsPaused = false
        // fix:从相册选择图片返回后会回调OnResume(),然后立即跳转图片编辑页，会出现相机开启后没有成功释放的问题
        //生命周期 VideoActivity.onResume -> VideoActivity.onPause() -> onOpened ->ImageEffectActity.onCreate->ImageEffectActity.onResume
        if (!mCameraProxy.isCameraValid) {
            mSurfaceView.queueEvent {
                if (!mCameraProxy.isCameraValid) {

                    mCameraProxy.openCamera(mCameraID, object : CameraListener {
                        override fun onOpenSuccess() {
                            mSurfaceView.queueEvent {
                                LogUtils.d("onOpenSuccess")
                                onCameraOpen()
                            }
                        }

                        override fun onOpenFail() {
                            LogUtils.d("onOpenFail")
                        }
                    })
                }
            }
        }
    }

    override fun onDestroyImpl() {
        mSurfaceView = null
    }
}