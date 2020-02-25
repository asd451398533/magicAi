package com.bytedance.labcv.demo.contract.presenter;

import android.content.Context;

import com.bytedance.labcv.demo.contract.ItemGetContract;
import com.bytedance.labcv.demo.model.ButtonItem;
import com.bytedance.labcv.demo.model.ComposerNode;

import java.util.ArrayList;
import java.util.List;

import static com.bytedance.labcv.demo.contract.ItemGetContract.MASK;
import static com.bytedance.labcv.demo.contract.ItemGetContract.NODE_BEAUTY;
import static com.bytedance.labcv.demo.contract.ItemGetContract.NODE_BEAUTY_4ITEMS;
import static com.bytedance.labcv.demo.contract.ItemGetContract.NODE_LONG_LEG;
import static com.bytedance.labcv.demo.contract.ItemGetContract.NODE_RESHAPE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.NODE_THIN;
import static com.bytedance.labcv.demo.contract.ItemGetContract.SUB_MASK;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_BODY;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_BODY_LONG_LEG;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_BODY_THIN;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_FACE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_FACE_BRIGHTEN_EYE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_FACE_REMOVE_POUCH;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_FACE_SHARPEN;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_FACE_SMILE_FOLDS;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_FACE_SMOOTH;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_FACE_WHITEN;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_FACE_WHITEN_TEETH;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_CHEEK;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_CHIN;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_EYE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_EYE_MOVE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_EYE_ROTATE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_EYE_SPACING;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_FACE_CUT;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_FACE_OVERALL;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_FACE_SMALL;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_FOREHEAD;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_JAW;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_MOUTH_MOVE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_MOUTH_SMILE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_MOUTH_ZOOM;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_NOSE_LEAN;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_BEAUTY_RESHAPE_NOSE_LONG;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_CLOSE;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP_BLUSHER;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP_EYEBROW;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP_EYELASH;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP_EYESHADOW;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP_FACIAL;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP_HAIR;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP_LIP;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP_OPTION;
import static com.bytedance.labcv.demo.contract.ItemGetContract.TYPE_MAKEUP_PUPIL;

/**
 * Created by QunZhang on 2019-07-21 12:27
 */
public class ItemGetPresenter extends ItemGetContract.Presenter {

    @Override
    public List<ButtonItem> getItems(int type) {
        List<ButtonItem> items = new ArrayList<>();
        switch (type & MASK) {
            case TYPE_BEAUTY_FACE:
                getBeautyFaceItems(items);
                break;
            case TYPE_BEAUTY_RESHAPE:
                getBeautyReshapeItems(items);
                break;
            case TYPE_BEAUTY_BODY:
                getBeautyBodyItems(items);
                break;
            case TYPE_MAKEUP:
                getMakeupItems(items);
                break;
            case TYPE_MAKEUP_OPTION:
                getMakeupOptionItems(items, type);
                break;
        }
        return items;
    }

    private void getBeautyFaceItems(List<ButtonItem> items) {
        Context context = getView().getContext();
            }

    private void getBeautyReshapeItems(List<ButtonItem> items) {
        Context context = getView().getContext();
    }

    private void getBeautyBodyItems(List<ButtonItem> items) {
        Context context = getView().getContext();
    }

    private void getMakeupItems(List<ButtonItem> items) {
        Context context = getView().getContext();
    }

    private void getMakeupOptionItems(List<ButtonItem> items, int type) {
        Context context = getView().getContext();
        switch (type & SUB_MASK) {
            case TYPE_MAKEUP_LIP:
                break;
            case TYPE_MAKEUP_BLUSHER:
                break;
            case TYPE_MAKEUP_EYELASH:
                break;
            case TYPE_MAKEUP_PUPIL:
                break;
            case TYPE_MAKEUP_HAIR:
                break;
            case TYPE_MAKEUP_EYESHADOW:
                break;
            case TYPE_MAKEUP_EYEBROW:
                break;
            case TYPE_MAKEUP_FACIAL:
                break;
        }
    }
}
