package zeusees.tracking;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.os.Environment;
import android.util.Log;

import com.example.gengmei_app_face.util.BMUtil;
import com.example.gengmei_flutter_plugin.utils.FileUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

public class FaceTrackingManager {

    private static volatile zeusees.tracking.FaceTrackingManager manager;
    private static FaceTracking mMultiTrack106 = null;
    private static volatile boolean isInit = false;
    private static volatile boolean isRunIt = false;
    public static final String modelPath = "GengmeiModle";
    private boolean mTrack106 = true;
    private List<Face> nonList = new ArrayList<>(1);
    private int detectCount = 0;


    private FaceTrackingManager() {
    }


    public static zeusees.tracking.FaceTrackingManager getInstance() {
        if (manager == null) {
            synchronized (zeusees.tracking.FaceTrackingManager.class) {
                if (manager == null) {
                    manager = new zeusees.tracking.FaceTrackingManager();
                }
            }
        }
        return manager;
    }

    public void init(final Context context) {
        if (isInit || isRunIt) {
            return;
        }
        isRunIt = true;
        isInit = false;
        new Thread(new Runnable() {
            @Override
            public void run() {
                String assetPath = modelPath;
                String sdcardPath = Environment.getExternalStorageDirectory()
                        + File.separator + assetPath;
                FileUtil.copyFilesFromAssets(context, "ZeuseesFaceTracking", sdcardPath);
                mMultiTrack106 = new FaceTracking("/sdcard/" + modelPath + "/models");
                isInit = true;
            }
        }).start();
    }

    public List<Face> detect(byte[] yuv, int width, int height) {
        if (!isInit) {
            return nonList;
        }
        detectCount++;
        if (detectCount > 300) {
            mTrack106 = true;
            detectCount = 0;
        }
        Log.e("lsy", "106  " + mTrack106);
        if (mTrack106) {
            mMultiTrack106.FaceTrackingInit(yuv, height, width);
            mTrack106 = !mTrack106;
        } else {
            mMultiTrack106.Update(yuv, height, width);
        }
        return mMultiTrack106.getTrackingInfo();
    }

    public void reset() {
        mTrack106 = true;
    }

    public List<Face> detect(Bitmap bitmap) {
        if (!isInit) {
            return nonList;
        }
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        try {
//            byte[] yuvByBitmap = BMUtil.getNV21(width, height, bitmap);
            byte[] yuvByBitmap = BMUtil.bitmapToNv21(bitmap,width, height );
            mMultiTrack106.FaceTrackingInit(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
            mMultiTrack106.Update(yuvByBitmap, height, width);
        }catch (Exception e){
            e.printStackTrace();
            return nonList;
        }
        return mMultiTrack106.getTrackingInfo();
    }

    public Bitmap rotateBitmap(Bitmap origin, float alpha) {
        if (origin == null) {
            return null;
        }
        int width = origin.getWidth();
        int height = origin.getHeight();
        Matrix matrix = new Matrix();
        matrix.setRotate(alpha);
        // 围绕原地进行旋转
        Bitmap newBM = Bitmap.createBitmap(origin, 0, 0, width, height, matrix, false);
        if (newBM.equals(origin)) {
            return newBM;
        }
        origin.recycle();
        return newBM;
    }

    public boolean isIsInit() {
        return isInit;
    }

}
