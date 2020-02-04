package com.example.gengmei_app_face;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.support.v4.content.FileProvider;
import android.text.TextUtils;

import com.example.gengmei_app_face.util.FileUtil;
import com.example.gengmei_app_face.util.StatusBarUtil;
import com.gengmei.igengmeisdk.IGengmeiSdk;
import com.gengmei.igengmeisdk.bean.AiFaceBean;
import com.gengmei.igengmeisdk.ffmpeg.IFFmpegSdkListener;
import com.gengmei.igengmeisdk.ffmpeg.IGengmeiFFmpegSdk;
import com.gengmei.igengmeisdk.helper.IGengmeiFaceListener;
import com.gengmei.igengmeisdk.helper.IGengmeiSubmitFaceListener;
import com.gengmei.igengmeisdk.helper.IGengmeiUploadListener;

import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import dlib.Dlib;
import io.flutter.Log;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.CompositeDisposable;
import io.reactivex.schedulers.Schedulers;
import sensetime.senseme.com.effects.TestCameraActivity;
import zeusees.tracking.FaceTrackingManager;

import static com.example.gengmei_app_face.CameraActivity.CAMERA_RESULT;
import static com.example.gengmei_app_face.CameraActivity.CAMERA_RESULT_SCARE;
import static com.example.gengmei_app_face.constant.AppConstant.CAMERA_CODE;
import static com.example.gengmei_app_face.constant.AppConstant.CAMERA_CODE_DEMO;
import static com.example.gengmei_app_face.util.BMUtil.returnBitMap;

public class MainActivity extends FlutterActivity {

    private CompositeDisposable disposable = new CompositeDisposable();
    private final String CHANNEL = "samples.flutter.io/startFaceAi";
    private FlutterChannelEvent flutterChannelEvent;
    private FlutterChannelReceiveEvent flutterChannelReceiveEvent;
    private static final int SubmitCode = 10088, RESULT_STRING = 10090, RESULT_BOOLEAN = 10091, RESULT_ERROR = 10092;
    private Handler handler;
    private static final int STAR_SUCCESS = 100;
    private FaceTrackingManager faceTrackingManager;
    private MethodChannel.Result result;
    private Receiver recevier;
    private IntentFilter intentFilter;
    private Dlib dlib = new Dlib();


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        setTheme(R.style.AppTheme);
        StatusBarUtil.transparencyBar(this);
        super.onCreate(savedInstanceState);
        ref = new WeakReference<>(this);
        GeneratedPluginRegistrant.registerWith(this);
        faceTrackingManager = FaceTrackingManager.getInstance();
        handler = new MyHandler();
        recevier = new Receiver();
        intentFilter = new IntentFilter();
        intentFilter.addAction("com.alpha.flutter.album");
        registerReceiver(recevier, intentFilter);
        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodChannel.MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                        MainActivity.this.result = result;
                        flutterChannelReceiveEvent = new FlutterChannelReceiveEvent(call, result);
                        Log.e("lsy", "  CALL!!!  " + call.method);
                        switch (call.method) {
                            case "startFaceAi":
                                int age = call.argument("AGE");
                                int wantAge = call.argument("WANT_AGE");
                                boolean male = call.argument("IS_MALE");
                                String url = call.argument("URL");
                                Log.e("lsy", "   " + age + "   " + wantAge + "   " + male + "   " + url);
                                IGengmeiSdk.getInstance().submitFaceSdk(getApplication(),
                                        url, male, age, wantAge, 0, url, new IGengmeiSubmitFaceListener() {
                                            @Override
                                            public void onSuccess(String s) {
                                                Log.e("lsy", "   " + s);
                                                Message message = handler.obtainMessage(SubmitCode, s);
                                                handler.sendMessageDelayed(message, 500);
                                            }

                                            @Override
                                            public void onLoading(String s) {
                                            }

                                            @Override
                                            public void onFail(String s, int i) {
                                                runOnUiThread(new Runnable() {
                                                    @Override
                                                    public void run() {
                                                        result.error(s, "11error code " + i, i);
                                                    }
                                                });
                                            }
                                        }
                                );
                                break;
                            case "quit":
                                IGengmeiSdk.getInstance().quit();
                                Log.e("lsy", "APP QUIT !!!!  ");
                                break;
                            case "takePic":
                                break;
                            case "aiCamera":
                                Intent intent = new Intent(MainActivity.this, CameraActivity.class);
                                startActivityForResult(intent, CAMERA_CODE);
                                break;
                            case "cancleTask":
                                IGengmeiSdk.getInstance().cancelTask();
                                break;
                            case "detectPic":
                                String imagepath = call.argument("imagepath");
                                Log.e("lsy", "  dectet img inggggg " + imagepath);
                                redetectInt = 0;
                                File file = new File(imagepath);
                                if (!file.exists()) {
                                    result.success("这个照片已经被删除了");
                                } else {
                                    detectImg(file.getAbsolutePath());
//                                    IGengmeiSdk.getInstance().luban(App.getInstance(), imagepath, new ILubanListener() {
//                                        @Override
//                                        public void onSuccess(String s) {
//                                            Log.e("lsy", "  new PATH!  " + s);
//                                            detectImg(BitmapFactory.decodeFile(s));
//                                        }
//
//                                        @Override
//                                        public void onFail(String s, int i) {
//                                            result.success("压缩出错"+s);
////                                            detectImg(BitmapFactory.decodeFile(file.getAbsolutePath()));
//                                        }
//
//                                        @Override
//                                        public void onLoading(String s) {
//
//                                        }
//                                    });
                                }
                                break;
                            case "uploadImg":
                                String imagepath1 = call.argument("imagepath");
                                IGengmeiSdk.getInstance().uploadImg(App.getInstance(), imagepath1, new IGengmeiUploadListener() {
                                    @Override
                                    public void onSuccess(String s) {
                                        Log.e("lsy", "  upload img success ");
                                        handler.obtainMessage(RESULT_STRING, s).sendToTarget();
                                    }

                                    @Override
                                    public void onFail(String s, int i) {
                                        handler.obtainMessage(RESULT_ERROR, s).sendToTarget();
                                        Log.e("lsy", "  upload img fail " + s);
                                    }

                                    @Override
                                    public void onLoading(String s) {
                                    }
                                });
                                break;
                            case "saveImg":
                                String url1 = call.argument("url");
                                if (!TextUtils.isEmpty(url1)) {
                                    new Thread(new Runnable() {
                                        @Override
                                        public void run() {
                                            boolean b = FileUtil.saveImageToPhotos(App.getInstance(), returnBitMap(url1));
                                            handler.obtainMessage(RESULT_BOOLEAN, b).sendToTarget();
                                        }
                                    }).start();
                                }
                                break;
                            case "execStar":
                                String imgPath = call.argument("filePath");
                                IGengmeiFFmpegSdk.getInstance().exec(App.getInstance(), BitmapFactory.decodeResource(getResources(), R.mipmap.videoback), imgPath,
                                        Environment.getExternalStorageDirectory().getAbsolutePath() + "/GengmeiAiRectVideo.mp4"
                                        , new IFFmpegSdkListener() {
                                            @Override
                                            public void onError(String s) {
                                                Log.e("lsy", " STAR ERROR   " + s);
                                                handler.obtainMessage(RESULT_ERROR, s).sendToTarget();
                                            }

                                            @Override
                                            public void onSuccess(String s) {
                                                handler.obtainMessage(RESULT_STRING, s).sendToTarget();
                                            }
                                        });

                                break;
                            case "execStarLong":
                                IGengmeiFFmpegSdk.getInstance().execStarLong(
                                        Environment.getExternalStorageDirectory().getPath() + "/GengmeiAiLongVideo.mp4"
                                        , new IFFmpegSdkListener() {
                                            @Override
                                            public void onError(String s) {
                                                runOnUiThread(new Runnable() {
                                                    @Override
                                                    public void run() {
                                                        result.error(s, s, s);
                                                    }
                                                });
                                            }

                                            @Override
                                            public void onSuccess(String s) {
                                                handler.obtainMessage(RESULT_STRING, s).sendToTarget();
                                            }
                                        });
                                break;
                            case "quitStarTask":
                                IGengmeiFFmpegSdk.getInstance().cancelTask();
                                result.success(true);
                                break;
                            case "senSDK":
                                String path = (String) call.arguments;
                                Intent intent1 = new Intent(getApplicationContext(), sensetime.senseme.com.effects.TestImageActivity.class);
                                intent1.putExtra("PATH", path);
                                startActivity(intent1);
                                break;
                            case "backApp":
//                                moveTaskToBack(false);
                                Intent setIntent = new Intent(Intent.ACTION_MAIN);
                                setIntent.addCategory(Intent.CATEGORY_HOME);
                                setIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                                startActivity(setIntent);
                                break;
                            case "demo":
                                Intent intent2 = new Intent(MainActivity.this, TestCameraActivity.class);
                                startActivityForResult(intent2, CAMERA_CODE_DEMO);
                                break;
//                            default:
//                                result.notImplemented();
//                                break;
                        }
                    }
                });


    }

    public class Receiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent result) {
            String path = result.getStringExtra("PATH");
            String providerString = result.getStringExtra("providerString");
            int CAMERA_REQUEST_CODE = result.getIntExtra("CAMERA_REQUEST_CODE", 11223);
            Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {   //如果在Android7.0以上,使用FileProvider获取Uri
                intent.setFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                Uri contentUri = FileProvider.getUriForFile(MainActivity.this, providerString, new File(path));
                intent.putExtra(MediaStore.EXTRA_OUTPUT, contentUri);
            } else {
                intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(path)));
            }
            MainActivity.this.startActivityForResult(intent, CAMERA_REQUEST_CODE);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == CAMERA_CODE) {
            if (data == null) {
                this.result.success("");
            } else {
                String path = data.getStringExtra(CAMERA_RESULT);
                String path_scare = data.getStringExtra(CAMERA_RESULT_SCARE);
                Log.e("lsy", "  PATH" + path + "   SCARE  " + path_scare);
                Map<String, String> map = new HashMap<>();
                map.put("path", path);
                map.put("scare_path", path_scare);
                this.result.success(map);
            }
        } else if (requestCode == CAMERA_CODE_DEMO) {
            if (data == null) {
                this.result.success("");
            } else {
                String path = data.getStringExtra(CAMERA_RESULT);
                String oripath = data.getStringExtra(CameraActivity.CAMERA_ORIAL);
                String text = data.getStringExtra(CameraActivity.CAMERA_INDEX);
                Log.e("lsy", "  TEXT  " + text);
                if (path != null && text != null && oripath != null) {
                    List<String> list = new ArrayList<>();
                    list.add(path);
                    list.add(text);
                    list.add(oripath);
                    this.result.success(list);
                }
            }
        }
    }


    private int redetectInt = 0;

    private void detectImg(final String path) {
        if (!faceTrackingManager.isIsInit()) {
            handler.obtainMessage(RESULT_STRING, "模型未加载完成").sendToTarget();
            return;
        }
        if (redetectInt >= 3) {
            handler.obtainMessage(RESULT_STRING, "没有检测到人脸").sendToTarget();
            return;
        }
        redetectInt++;
        disposable.add(
                Observable.create(new ObservableOnSubscribe<String>() {
                    @Override
                    public void subscribe(ObservableEmitter<String> emitter) throws Exception {
                        //MyUtil.Companion.scareImg(path, 720f)
//                        BitmapFactory.Options newOpts = new BitmapFactory.Options();
//                        newOpts.inPreferredConfig = Bitmap.Config.ARGB_8888;
//                        Bitmap temp = faceTrackingManager.rotateBitmap(BitmapFactory.decodeFile(path, newOpts), 90);
//                        Bitmap bitmap = BitmapFactory.decodeResource(getResources(), R.drawable.filter_food_nature);
//                        List<zeusees.tracking.Face> cleanItem = faceTrackingManager.detect(bitmap);
//                        List<zeusees.tracking.Face> detect = faceTrackingManager.detect(temp);
                        List<Rect> detect = dlib.face_detection(BitmapFactory.decodeFile(path), 560f);
                        Log.e("lsy", "  RESUKT   " + detect);
                        if (detect.size() == 0) {
                            emitter.onNext("retry");
                        } else if (detect.size() == 1) {
                            emitter.onNext("success");
                        } else {
                            emitter.onNext("检测到有多张人脸");
                        }
                    }
                }).observeOn(AndroidSchedulers.mainThread())
                        .subscribeOn(Schedulers.computation())
                        .subscribe((a) -> {
                            if (a.equals("retry")) {
                                detectImg(path);
                            } else {
                                result.success(a);
                            }
                        }, (throwable) -> {
                            throwable.printStackTrace();
                        }));
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (ref != null) {
            ref.clear();
            ref = null;
        }
        if (recevier != null) {
            unregisterReceiver(recevier);
        }
        if (disposable != null) {
            disposable.clear();
            disposable.dispose();
        }
        handler.removeCallbacksAndMessages(null);
        handler = null;
        IGengmeiSdk.getInstance().quit();
    }

    private WeakReference<Activity> ref;

    private void searchSubmitState(final String taskID) {
        Log.e("lsy", " submit   ");
        IGengmeiSdk.getInstance().searchFaceTaskState(taskID, new IGengmeiFaceListener() {
            @Override
            public void onSuccess(AiFaceBean aiFaceBean) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Log.e("lsy", " SUCCESS ");
                        flutterChannelReceiveEvent.faceAiSuccess(aiFaceBean.getGenerateUrl());
                    }
                });
            }

            @Override
            public void onFail(String s, int i) {
                Log.e("lsy", "faaaaaa iii  ll  " + s);
                handler.obtainMessage(RESULT_ERROR, s).sendToTarget();
            }

            @Override
            public void onLoading(String s) {
                Log.e("lsy", "  " + s);
                handler.removeMessages(SubmitCode);
                Message message = handler.obtainMessage(SubmitCode, taskID);
                handler.sendMessageDelayed(message, 500);
            }
        });
    }


    class MyHandler extends Handler {
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
//            if (ref.get() == null) {
//                return;
//            }
            switch (msg.what) {
                case SubmitCode:
                    searchSubmitState(String.valueOf(msg.obj));
                    break;
                case STAR_SUCCESS:

                    break;
                case RESULT_STRING:
                    MainActivity.this.result.success((String) msg.obj);
                    break;
                case RESULT_BOOLEAN:
                    MainActivity.this.result.success((Boolean) msg.obj);
                    break;
                case RESULT_ERROR:
                    try {
                        MainActivity.this.result.error((String) msg.obj, (String) msg.obj, (String) msg.obj);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    break;
            }
        }
    }
}
