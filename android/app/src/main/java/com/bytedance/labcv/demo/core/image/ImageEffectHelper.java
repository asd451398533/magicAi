package com.bytedance.labcv.demo.core.image;

import android.content.Context;
import android.opengl.GLES20;

import com.bytedance.labcv.demo.core.BaseEffectHelper;
import com.bytedance.labcv.demo.core.EffectRender;
import com.bytedance.labcv.demo.model.CaptureResult;
import com.bytedance.labcv.effectsdk.BytedEffectConstants;


public class ImageEffectHelper extends BaseEffectHelper {
    private int dstTextureId;


    public ImageEffectHelper(Context context) {
        super(context);
        mEffectRender = new EffectRender();
    }


    @Override
    protected CaptureResult captureImpl() {
        if (null == mEffectRender) {
            return null;
        }
        if (0 == mImageWidth * mImageHeight) {
            return null;
        }
        return new CaptureResult(mEffectRender.captureRenderResult(dstTextureId, mImageWidth, mImageHeight), mImageWidth, mImageHeight);
    }

    public int processTexture(int srcTextureId, int width, int height) {
        dstTextureId = mEffectRender.prepareTexture(width, height);
        mImageWidth = width;
        mImageHeight = height;
        // 执行特效处理
        if (!isEffectOn || !mRenderManager.processTexture(srcTextureId, dstTextureId,width, height, BytedEffectConstants.Rotation.CLOCKWISE_ROTATE_0, System.nanoTime())) {
            dstTextureId = srcTextureId;
        }
        ;
        return dstTextureId;

    }


    public void drawFrame(int textureId, BytedEffectConstants.TextureFormat textureFormat, int width, int height) {
        if (!GLES20.glIsTexture(textureId)) return;
        mEffectRender.drawFrameCentnerInside(textureId, textureFormat, width, height);

    }

}
