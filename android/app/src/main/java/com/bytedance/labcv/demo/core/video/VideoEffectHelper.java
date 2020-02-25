// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
package com.bytedance.labcv.demo.core.video;

import android.content.Context;
import android.util.Log;

import com.bytedance.labcv.demo.core.BaseEffectHelper;
import com.bytedance.labcv.demo.core.EffectRender;
import com.bytedance.labcv.demo.model.CaptureResult;
import com.bytedance.labcv.demo.utils.AppUtils;
import com.bytedance.labcv.effectsdk.BytedEffectConstants;


public class VideoEffectHelper extends BaseEffectHelper {




    public VideoEffectHelper(Context context) {
        super(context);
        mEffectRender = new EffectRender();
    }

    /**
     * 特效处理接口
     * 步骤1：将纹理做旋转&翻转操作，将人脸转正（如果是前置摄像头，会加左右镜像），
     * 步骤2：然后执行特效处理，
     * 步骤3：步骤1的逆操作，将纹理处理成原始输出的角度、镜像状态
     * 客户可以根据自己输入的纹理状态自行选择执行上述部分步骤，比如部分推流SDK采集到的纹理已经做了人脸转正操作，只需要执行步骤2即可
     * @param srcTextureId 输入纹理
     * @param srcTetxureFormat 输入纹理的格式
     * @param srcTextureWidth 输入纹理的宽度
     * @param srcTextureHeight 输入纹理的高度
     * @param cameraRotation 相机输出的图像旋转角度
     * @param frontCamera 是否是前置摄像头
     * @param sensorRotation 重力传感器的重力方向角
     * @param timestamp 时间戳，由SurfaceTexture的接口输出
     * @return 输出后的纹理
     */
    public int processTexure(int srcTextureId, BytedEffectConstants.TextureFormat srcTetxureFormat, int srcTextureWidth, int srcTextureHeight, int cameraRotation, boolean frontCamera, BytedEffectConstants.Rotation sensorRotation, long timestamp) {
        int tempWidth = srcTextureWidth;
        int tempheight = srcTextureHeight;

        if (cameraRotation % 180 == 90) {
            tempWidth = srcTextureHeight;
            tempheight = srcTextureWidth;
        }
        long start = System.currentTimeMillis();
        // 因为Android相机预览纹理中的人脸不是正，该函数将oes转为2D纹理，并将人脸转正，如果是前置摄像头，会同时做左右镜像
        int tempTexureId = mEffectRender.drawFrameOffScreen(srcTextureId, srcTetxureFormat, tempWidth, tempheight, -cameraRotation, frontCamera, true);
        // 保存当前处理的纹理的宽高
        mImageWidth = tempWidth;
        mImageHeight = tempheight;
        // 准备帧缓冲区纹理
        int dstTextureId = mEffectRender.prepareTexture(tempWidth, tempheight);
        long detectnext = System.currentTimeMillis();

        // 执行特效处理
        if (!isEffectOn || !mRenderManager.processTexture(tempTexureId, dstTextureId, tempWidth, tempheight, sensorRotation, timestamp)) {
            dstTextureId = tempTexureId;
        }
        if (AppUtils.isProfile()) {
            Log.d(ProfileTAG, "effectprocess: " + String.valueOf(System.currentTimeMillis() - detectnext));
        }
        // 将特效处理后的纹理，转回相机原始的状态(包括旋转角度、左右镜像)，方便接入推流SDK
        int tt = mEffectRender.drawFrameOffScreen(dstTextureId, BytedEffectConstants.TextureFormat.Texure2D, srcTextureWidth, srcTextureHeight, frontCamera ? -cameraRotation : cameraRotation, frontCamera, true);

        return tt;

    }

    /**
     * 在屏幕上渲染
     * draw on screen
     * @param textureId
     * @param textureFormat
     * @param srcTextureWidth
     * @param srcTextureHeight
     * @param cameraRotation
     * @param flipHorizontal
     * @param flipVertical
     */
    public void drawFrame(int textureId, BytedEffectConstants.TextureFormat textureFormat, int srcTextureWidth, int srcTextureHeight, int cameraRotation, boolean flipHorizontal, boolean flipVertical) {
        mEffectRender.drawFrameOnScreen(textureId, textureFormat, srcTextureWidth, srcTextureHeight, cameraRotation, flipHorizontal, flipVertical);
    }



    @Override
    protected CaptureResult captureImpl() {
        if (null == mEffectRender) {
            return null;
        }
        if (0 ==   mImageWidth* mImageHeight) {
            return null;
        }
        return new CaptureResult(mEffectRender.captureRenderResult(mImageWidth, mImageHeight), mImageWidth, mImageHeight);    }



}
