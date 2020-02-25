package com.bytedance.labcv.demo.core;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.widget.Toast;

import com.bytedance.labcv.demo.ResourceHelper;
import com.bytedance.labcv.demo.core.video.VideoEffectHelper;
import com.bytedance.labcv.demo.model.CaptureResult;
import com.bytedance.labcv.demo.model.ComposerNode;
import com.bytedance.labcv.demo.utils.LogUtils;
import com.bytedance.labcv.effectsdk.BytedEffectConstants;
import com.bytedance.labcv.effectsdk.RenderManager;

import java.util.HashSet;
import java.util.Set;

import static com.bytedance.labcv.effectsdk.BytedEffectConstants.BytedResultCode.BEF_RESULT_SUC;

public abstract class BaseEffectHelper {

    public static final String ProfileTAG = "Profile ";
    private volatile boolean initedEffectSDK = false;
    protected RenderManager mRenderManager;
    protected int mImageWidth;
    protected int mImageHeight;
    private int mSurfaceWidth;
    private int mSurfaceHeight;
    protected EffectRender mEffectRender;


    private VideoEffectHelper.OnEffectListener mOnEffectListener;


    private String mFilterResource;
    private String[] mComposeNodes = new String[0];
    private String mStickerResource;
    private Set<ComposerNode> mSavedComposerNodes = new HashSet<>();
    private float mFilterIntensity = 0f;
    protected volatile boolean isEffectOn = true;
    protected Context mContext;
    protected abstract CaptureResult captureImpl();

    public BaseEffectHelper(Context context) {
        mContext = context;
        mRenderManager = new RenderManager();
    }

    public void setOnEffectListener(VideoEffectHelper.OnEffectListener listener) {
        mOnEffectListener = listener;
    }

    /**
     * 特效初始化入口
     *
     * @param context     应用上下文
     * @return 如果成功返回BEF_RESULT_SUC， 否则返回对应的错误码
     */
    private int initEffect(Context context) {
        LogUtils.d("Effect SDK version =" + mRenderManager.getSDKVersion());
        int ret = mRenderManager.init(context, ResourceHelper.getModelDir(context), ResourceHelper.getLicensePath(context));
        if (ret != BEF_RESULT_SUC) {
            LogUtils.e("mRenderManager.init failed!! ret =" + ret);
            return ret;
        }
        if (mOnEffectListener != null) {
            mOnEffectListener.onEffectInitialized();
        }
        return ret;
    }

    /**
     * 根据suafceView的尺寸设置Render的参数
     * @param width
     * @param height
     */
    public void onSurfaceChanged(int width, int height) {
        if (width != 0 && height != 0) {
            this.mSurfaceWidth = width;
            this.mSurfaceHeight = height;
            mEffectRender.setViewSize(mSurfaceWidth, mSurfaceHeight);
        }
    }



    /**
     * 工作在渲染线程
     * Work on the render thread
     */
    public void destroyEffectSDK() {
        LogUtils.d("destroyEffectSDK");
        mRenderManager.release();
        mEffectRender.release();
        initedEffectSDK = false;
        LogUtils.d("destroyEffectSDK finish");
    }

    private void sendUIToastMsg(final String msg) {
        ((Activity) mContext).runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(mContext, msg, Toast.LENGTH_SHORT).show();
            }
        });
    }

    /**
     * 初始化特效SDK，确保在gl线程中执行
     */
    public void initEffectSDK() {
        if (initedEffectSDK)
            return;
        int ret = initEffect(mContext);
        if (ret != BEF_RESULT_SUC) {
            LogUtils.e("initEffect ret =" + ret);
            sendUIToastMsg("Effect Initialization failed");
        }
        initedEffectSDK = true;
    }


    public void setCameraPosition(boolean isFront){
        if (null == mRenderManager)return;
        mRenderManager.setCameraPostion(isFront);
    }



    public void setEffectOn(boolean isOn) {
        isEffectOn = isOn;
    }

    /**
     * 开启或者关闭滤镜 如果path为空 关闭滤镜
     * Turn filters on or off
     * turn off filter if path is empty
     *
     * @param path path of filter file 滤镜资源文件路径
     */
    public boolean setFilter(String path) {
        mFilterResource = path;
        return mRenderManager.setFilter(path);
    }


    /**
     * 截取当前帧
     * @return CaptureResult对象
     *
     */
    public CaptureResult capture() {
        return captureImpl();
    }


    /**
     * 设置特效组合，目前支持美颜、美形、美体、 美妆特效的任意叠加
     * Set special effects combination
     * Currently only support the arbitrary superposition of two special effects, beauty and beauty makeup
     *
     * @param nodes
     * @return
     */
    public boolean setComposeNodes(String[] nodes) {
        // clear mSavedComposerNodes cache when nodes length is 0
        if (nodes.length == 0) {
            mSavedComposerNodes.clear();
        }

        mComposeNodes = nodes;
        String prefix = ResourceHelper.getComposePath(mContext);
        String[] path = new String[nodes.length];
        for (int i = 0; i < nodes.length; i++) {
            path[i] = prefix + nodes[i];
        }
        return mRenderManager.setComposerNodes(path) == BEF_RESULT_SUC;
    }

    /**
     * 更新组合特效(美颜、美形、美体、 美妆)中某个节点的强度
     * Updates the strength of a node in a composite effect
     *
     * @param node The ComposerNode corresponding to the special effects material
     *             特效素材对应的 ComposerNode
     * @return
     */
    public boolean updateComposeNode(ComposerNode node, boolean update) {
        if (update) {
            mSavedComposerNodes.remove(node);
            mSavedComposerNodes.add(node);
        }
        String path = ResourceHelper.getComposePath(mContext) + node.getNode();
        return mRenderManager.updateComposerNodes(path, node.getKey(), node.getValue()) == BEF_RESULT_SUC;
    }

    /**
     * 开启或者关闭贴纸 如果path为空 关闭贴纸
     * 注意 贴纸和Composer类型的特效（美颜、美妆）是互斥的，如果同时设置设置，后者会取消前者的效果
     * Turn on or off the sticker. If path is empty, turn off
     * Note that the stickers and Composer types of special effects (beauty, makeup) are mutually exclusive
     * If you set at the same the, the latter will cancel the effect of the former
     *
     * @param path 贴纸素材的文件路径
     */
    public boolean setSticker(String path) {
        mStickerResource = path;
        return mRenderManager.setSticker(path);
    }


    public boolean getAvailableFeatures(String[] features) {
        return mRenderManager.getAvailableFeatures(features);
    }

    /**
     * 设置滤镜强度
     * Set the intensity of the filter
     *
     * @param intensity intensity 参数值
     * @return 是否成功  if it is successful
     */
    public boolean updateFilterIntensity(float intensity) {
        boolean result = mRenderManager.updateIntensity(BytedEffectConstants.IntensityType.Filter.getId(), intensity);
        if (result) {
            mFilterIntensity = intensity;
        }
        return result;

    }

    /**
     * 切换摄像头后恢复特效设置
     * Restore beauty, filter and other Settings
     */
    public void recoverStatus() {
        LogUtils.e("recover status");
        if (!TextUtils.isEmpty(mFilterResource)) {
            setFilter(mFilterResource);

        }
        if (!TextUtils.isEmpty(mStickerResource)) {
            setSticker(mStickerResource);
        }

        if (mComposeNodes.length > 0) {
            boolean flag = setComposeNodes(mComposeNodes);
            LogUtils.d("setComposeNodes return "+flag);

            for (ComposerNode node : mSavedComposerNodes) {
                updateComposeNode(node, false);
            }
        }
        updateFilterIntensity(mFilterIntensity);
    }

    public interface OnEffectListener {
        void onEffectInitialized();
    }

}
