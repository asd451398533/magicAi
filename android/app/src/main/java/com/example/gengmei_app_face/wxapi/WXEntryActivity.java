package com.example.gengmei_app_face.wxapi;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import com.example.gengmei_app_face.MainActivity;
import com.example.gengmei_app_face.bean.WXBean;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import org.greenrobot.eventbus.EventBus;

import java.util.HashMap;

import io.flutter.Log;

import static com.example.gengmei_app_face.constant.AppConstant.CAMERA_CODE;
import static com.example.gengmei_app_face.constant.AppConstant.WX_RESULT;

/**
 * @author lsy
 * @date 2020-02-21
 */
public class WXEntryActivity extends Activity implements IWXAPIEventHandler {

    private IWXAPI WXApi;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WXApi = WXAPIFactory.createWXAPI(this, "wxa51215876ed98f9e", true);
        WXApi.handleIntent(getIntent(),this);

    }

    @Override
    public void onReq(BaseReq baseReq) {

    }

    @Override
    public void onResp(BaseResp baseResp) {
        WXBean wxBean=new WXBean(baseResp.errCode,((SendAuth.Resp) baseResp).code,((SendAuth.Resp) baseResp).state);
        EventBus.getDefault().post(wxBean);
        finish();
    }
}
