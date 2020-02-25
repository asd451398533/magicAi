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
import com.bytedance.labcv.demo.ResourceHelper
import com.bytedance.labcv.demo.utils.FileUtils
import com.example.gengmei_app_face.util.StatusBarUtil
import com.example.gengmei_flutter_plugin.utils.MyUtil
import com.example.gengmei_flutter_plugin.utils.addTo
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import io.reactivex.Observable
import io.reactivex.ObservableOnSubscribe
import io.reactivex.android.schedulers.AndroidSchedulers
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import zeusees.tracking.FaceTrackingManager
import java.io.File
import java.io.IOException

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

    fun getVersionCode(): Int {
        val context = this
        try {
            return context.getPackageManager().getPackageInfo(context.getPackageName(), 0).versionCode
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
            return -1
        }

    }


    private fun initFace() {

        Observable.create(ObservableOnSubscribe<String> {
            if(!ResourceHelper.isResourceReady(this, getVersionCode())){
                val path = ResourceHelper.RESOURCE
                val dstFile = getExternalFilesDir("assets")
                FileUtils.clearDir(File(dstFile, path))
                try {
                    FileUtils.copyAssets(getAssets(), path, dstFile!!.getAbsolutePath())
                } catch (e: IOException) {
                    e.printStackTrace()
                }
            }
            FaceTrackingManager.getInstance().init(applicationContext)
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