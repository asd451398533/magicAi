/*
 * @author lsy
 * @date   2020-01-02
 **/
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:gengmei_app_face/HomeModel/page/want/WantCache.dart';
import 'package:gengmei_app_face/HomeModel/repo/HomeRepo.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/bean/LandMarkBean.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
import 'package:gengmei_app_face/commonModel/util/IUImageUtil.dart';
import 'dart:ui' as ui;

import 'package:gengmei_app_face/main.mark.dart';

class WantModel extends BaseModel {
  LiveData<String> resultLive = LiveData();
  LiveData<WantBean> wantLive = LiveData();
  LiveData<String> faceResultLive = LiveData();
  WantBean wantBean = new WantBean();
  WantCache wantCache;
  Map<String, String> cacheShow;
  ui.Image oriImg;
  ui.Image newImg;

  WantModel() {
    wantCache = new WantCache();
  }

  void init(BuildContext context, String filePath, int index) {
    RouterCenterImpl().findAiRouter().uploadImg(filePath).listen((value) {
      if (value.fileUrl != null) {
        if (value.fileUrl.contains("half")) {
          value.fileUrl = value.fileUrl.replaceAll("half", "w");
        }
        print(":  LAND  ${value.fileUrl}");
        landMark(value.fileUrl, (va) {
          if (va.faceNum == 1) {
            wantBean.landMarkBean = va;
            loadImg(value.fileUrl, (im) {
              newImg = im;
              wantBean.image = im;
              var cacheMap = wantCache.getCacheMap()[index];
              if (cacheMap == null) {
                Toast.show(context, "原图没有诉求哦");
              } else {
                print("FIND ");
                //TODO
                findWhatFace(value.fileUrl, (i, str) {
                  cacheShow = cacheMap[i][0];
                  wantBean.wantMap = cacheMap[i][0];
                  faceResultLive.notifyView(str);
                  wantLive.notifyView(wantBean);
                  resultLive.notifyView("success");
                });
              }
//              Map<String, String> map = new Map();
//              map.putIfAbsent("eye_big", () => "眼睛变大");
//              map.putIfAbsent("eye_open", () => "开眼角");
//              map.putIfAbsent("chin", () => "丰下巴");
//              map.putIfAbsent("nose", () => "鼻翼缩小");
//              map.putIfAbsent("face", () => "瘦脸");
//              map.putIfAbsent("lip", () => "眼睛变大");
//              map.putIfAbsent("tooth", () => "牙齿正畸");
//              map.putIfAbsent("wrinkles", () => "淡化法令纹");
//              map.putIfAbsent("bound", () => "颧骨降低");
//              map.putIfAbsent("temples", () => "丰太阳穴");
//              map.putIfAbsent("black", () => "祛黑眼圈");
//              map.putIfAbsent("eye_bag", () => "祛眼袋");
//              map.putIfAbsent("brow", () => "植眉");
//              map.putIfAbsent("head", () => "丰额头");
//               = map;
            });
          } else {
            wantBean.errorMessage = va.faceNum == 0 ? "没有识别到人脸" : "识别到多张人脸";
            wantLive.notifyView(wantBean);
          }
        });
      } else {
        wantBean.errorMessage = "上传图片失败!";
        wantLive.notifyView(wantBean);
      }
    }).onError((error) {
      Toast.show(context, error.toString());
      print(error);
    });
  }

  void findWhatFace(String url, Function(int index, String value) indexCall) {
    HomeRepo.getInstance().getImageAi(url).listen((value) {
      if (value != null &&
          value.data != null &&
          value.data.faceshape != null &&
          value.data.faceshape.length > 0) {
        print("AI RESULT  ${value.data.faceshape[0].type}");
        if (value.data.faceshape[0].type.contains("椭圆")) {
          indexCall(0, value.data.faceshape[0].type);
        } else if (value.data.faceshape[0].type.contains("瓜子")) {
          indexCall(1, value.data.faceshape[0].type);
        } else if (value.data.faceshape[0].type.contains("方")) {
          indexCall(2, value.data.faceshape[0].type);
        } else if (value.data.faceshape[0].type.contains("长")) {
          indexCall(3, value.data.faceshape[0].type);
        } else {
          indexCall(4, value.data.faceshape[0].type);
        }
      } else {
        wantBean.errorMessage = "没有识别出这个照片的脸型";
        wantLive.notifyView(wantBean);
      }
    }).onError((err) {
      print(err.toString());
      wantBean.errorMessage = err.toString();
      wantLive.notifyView(wantBean);
    });
  }

  void landMark(String url, Function(LandMarkBean landMarkBean) success) {
    RouterCenterImpl().findAiRouter().getLandMark(url).listen((value) {
      success(value);
    }).onError((error) {
      wantBean.errorMessage = error.toString();
      wantLive.notifyView(wantBean);
      print(error.toString());
    });
  }

  void loadImg(String url, Function(ui.Image) success) {
    IUImageUtil.getIUImage(url, true).listen((value) {
      success(value);
    }).onError((error) {
      wantBean.errorMessage = error.toString();
      wantLive.notifyView(wantBean);
      print(error.toString());
    });
  }

  @override
  void dispose() {
    wantLive.dispost();
    resultLive.dispost();
    faceResultLive.dispost();
  }
}

class WantBean {
  ui.Image image;
  String errorMessage;
  LandMarkBean landMarkBean;
  Map<String, String> wantMap;
  bool showOri = false;
}
