package sensetime.senseme.com.effects.display;

import android.util.Log;

import com.sensetime.stmobile.STStickerEvent;
import com.sensetime.stmobile.model.STAnimationStateType;
import com.sensetime.stmobile.model.STPackageStateType;

public class STStickerEventCallback {
    private static String TAG = "STStickerEventCallback";

    public STStickerEventCallback(){
        Log.e(TAG, "getInstance: "+ STStickerEvent.getInstance() );
        if(STStickerEvent.getInstance() != null){
            STStickerEvent.getInstance().setStickerEventListener(mStickerEventDefaultListener);
        }
    }

    private STStickerEvent.StickerEventListener mStickerEventDefaultListener = new STStickerEvent.StickerEventListener() {
        @Override
        public void onPackageEvent(String packageName, int packageID, int event, int displayedFrame) {
            if (packageName == null)
                return;
            Log.e(TAG, "onPackageEvent " + packageName);

            if(event == STPackageStateType.ST_AS_BEGIN){
                Log.e(TAG, "onPackageEvent: " + "package begin");
            }else if(event == STPackageStateType.ST_AS_END){
                Log.e(TAG, "onPackageEvent: " + "package end");
            }else if(event == STPackageStateType.ST_AS_TERMINATED){
                Log.e(TAG, "onPackageEvent: " + "package terminated");
            }
        }

        @Override
        public void onAnimationEvent(String moduleName, int moduleId, int animationEvent, int currentFrame, int positionId, long positionType) {
            if (moduleName == null)
                return;
            Log.e(TAG, "onAnimationEvent " + moduleName);

            if(animationEvent == STAnimationStateType.ST_AS_PAUSED_FIRST_FRAME){
                Log.e(TAG, "onAnimationEvent: " + "ST_AS_PAUSED_FIRST_FRAME");
            }else if(animationEvent == STAnimationStateType.ST_AS_PAUSED){
                Log.e(TAG, "onAnimationEvent: " + "ST_AS_PAUSED");
            }if(animationEvent == STAnimationStateType.ST_AS_PLAYING){
                Log.e(TAG, "onAnimationEvent: " + "ST_AS_PLAYING");
            }else if(animationEvent == STAnimationStateType.ST_AS_PAUSED_LAST_FRAME){
                Log.e(TAG, "onAnimationEvent: " + "ST_AS_PAUSED_LAST_FRAME");
            }else if(animationEvent == STAnimationStateType.ST_AS_INVISIBLE){
                Log.e(TAG, "onAnimationEvent: " + "ST_AS_INVISIBLE");
            }
        }

        @Override
        public void onKeyFrameEvent(String materialName, int frame) {
            if (materialName == null)
                return;
            Log.e(TAG, "onKeyFrameEvent materialName:" + materialName + " frame: " + frame);
        }
    };
}
