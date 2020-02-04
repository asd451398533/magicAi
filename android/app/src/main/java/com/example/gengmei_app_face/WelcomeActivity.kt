package com.example.gengmei_app_face

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.support.v7.app.AppCompatActivity
import android.util.Log
import android.widget.Toast
import com.example.gengmei_app_face.util.StatusBarUtil
import com.example.gengmei_flutter_plugin.utils.MyUtil
import com.example.gengmei_flutter_plugin.utils.addTo
import com.sensetime.sensearsourcemanager.SenseArMaterialService
import com.sensetime.sensearsourcemanager.SenseArServerType
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.reactivex.Observable
import io.reactivex.ObservableOnSubscribe
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import sensetime.senseme.com.effects.utils.FileUtils
import sensetime.senseme.com.effects.utils.STLicenseUtils
import zeusees.tracking.FaceTrackingManager

/**
 * @author lsy
 * @date   2019-12-13
 */
class WelcomeActivity :  AppCompatActivity() {

    val disposable = CompositeDisposable()

    override fun onCreate(savedInstanceState: Bundle?) {
        Log.e("lsy","ONCCCEEEEEe");
        StatusBarUtil.transparencyBar(this)
        super.onCreate(savedInstanceState)
        if(WelcomeInstance.instance.isInit){
            finish()
            startActivity(Intent(this@WelcomeActivity,MainActivity::class.java));
            return;
        }
        SenseArMaterialService.setServerType(SenseArServerType.DomesticServer)
        //需要初始化一次
        SenseArMaterialService.shareInstance().initialize(applicationContext)
        setContentView(R.layout.activity_welcome)
        checkPremission();
    }

    private fun checkPremission() {
        if (ContextCompat.checkSelfPermission(this@WelcomeActivity, Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                || ContextCompat.checkSelfPermission(this@WelcomeActivity, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED
                || ContextCompat.checkSelfPermission(this@WelcomeActivity, Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
                || ContextCompat.checkSelfPermission(this@WelcomeActivity, Manifest.permission.READ_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED
                || ContextCompat.checkSelfPermission(this@WelcomeActivity, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                    this,
                    arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_PHONE_STATE, Manifest.permission.RECORD_AUDIO, Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.CAMERA),
                    111
            )
        } else {
            initFace()
        }
    }

    private fun initFace() {
        val checkLicenseFromAssetFile = STLicenseUtils.checkLicenseFromAssetFile(this@WelcomeActivity, "sen.lic", false);
        if (!checkLicenseFromAssetFile) {
            Toast.makeText(applicationContext, "请检查License授权！", Toast.LENGTH_SHORT).show()
        }
        Observable.create(ObservableOnSubscribe<String> {
            FaceTrackingManager.getInstance().init(applicationContext)
            FileUtils.copyStickerFiles(this@WelcomeActivity, "newEngine")
            FileUtils.copyStickerFiles(this@WelcomeActivity, "makeup_eye")
            FileUtils.copyStickerFiles(this@WelcomeActivity, "makeup_brow")
            FileUtils.copyStickerFiles(this@WelcomeActivity, "makeup_blush")
            FileUtils.copyStickerFiles(this@WelcomeActivity, "makeup_highlight")
            FileUtils.copyStickerFiles(this@WelcomeActivity, "makeup_lip")
            FileUtils.copyStickerFiles(this@WelcomeActivity, "makeup_eyeliner")
            FileUtils.copyStickerFiles(this@WelcomeActivity, "makeup_eyelash")
            FileUtils.copyStickerFiles(this@WelcomeActivity, "makeup_eyeball")
            it.onNext("OK")
        }).subscribeOn(Schedulers.computation()).observeOn(AndroidSchedulers.mainThread())
                .subscribe({
                    finish();
                    WelcomeInstance.instance.isInit=true;
                    startActivity(Intent(this@WelcomeActivity,MainActivity::class.java))
                }, {
                    it.printStackTrace();
                }).addTo(disposable);
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        if (requestCode == 111) {
            var givePr = true
            for (i in grantResults.indices) {
                if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                    givePr = false
                }
            }
            if (!givePr) {
                Toast.makeText(this@WelcomeActivity, "请给予权限", Toast.LENGTH_SHORT).show()
                finish();
            } else {
                initFace()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        disposable.clear();
        disposable.dispose();

    }

}