/*
 * @author lsy
 * @date   2019-09-16
 **/

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gengmei_app_face/AiModel/bean/GMUploadImgBean.dart';
import 'package:gengmei_app_face/AiModel/repository/remote/api/AiApi.serv.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/base/AppBase.dart';
import 'package:gengmei_app_face/commonModel/bean/LandMarkBean.dart';
import 'package:gengmei_flutter_plugin/gengmei_flutter_plugin.dart';
import 'package:rxdart/rxdart.dart';

class DetectRepository {
  static DetectRepository _instance;
  Dio _landDio;

  DetectRepository._() {
    _landDio = Dio(BaseOptions()
      ..connectTimeout = 10 * 1000
      ..receiveTimeout = 10 * 1000
      ..baseUrl = "https://api-cn.faceplusplus.com/facepp/v3/");
  }

  static DetectRepository getInstance() {
    if (_instance == null) {
      _instance = DetectRepository._();
    }
    return _instance;
  }

  BaseOptions getwW() {}

  Observable<String> detectFace(String imgFile) {
    return Observable.fromFuture(
        faceAi.invokeMethod("detectPic", {"imagepath": imgFile}));
  }

  Observable<String> uploadImg(String path) {
    return Observable.fromFuture(_uploadImg(path));
  }

  Future<String> _uploadImg(String path) async {
    return await faceAi.invokeMethod("uploadImg", {"imagepath": path});
  }

  Observable<GMUploadImgBean> uploadImgGM(String path) {
    return AiApiImpl.getInstance().uploadImgGM(DioUtil().getDio(), path);
  }

  Observable<LandMarkBean> getLandMark(String imageUrl) {
    FormData formData = new FormData.fromMap({
      "api_secret": "MyL-97-v-I58ZuejJCY5v_J6WSPF8aNE",
      "api_key": "k0pKhsD-obflJPrjlF5POg_bvpIdz4OR",
      "return_attributes":
          "gender,age,smiling,headpose,blur,eyestatus,emotion,facequality,ethnicity,beauty,mouthstatus,skinstatus",
      "return_landmark": 2,
      "image_url": imageUrl
    });
    return Observable.fromFuture(_landDio.post('detect', data: formData))
        .flatMap((value) {
      if (value != null &&
          (value.statusCode >= 200 && value.statusCode < 300)) {
        return Observable.fromFuture(compute(parseLandmark, value.toString()));
      } else {
        return Observable.fromFuture(null);
      }
    });
  }
}

LandMarkBean parseLandmark(String value) {
  return LandMarkBean.fromJson(json.decode(value));
}

GMUploadImgBean parseMyUpload(String value) {
  return GMUploadImgBean.fromJson(json.decode(value));
}
