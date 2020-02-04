/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gengmei_app_face/HomeModel/bean/AIBean.dart';
import 'package:gengmei_app_face/commonModel/bean/LandMarkBean.dart';
import 'package:gengmei_app_face/commonModel/base/AppBase.dart';
import 'package:rxdart/rxdart.dart';

class HomeRepo {
  Dio _myDio;

  static HomeRepo _repo;

  HomeRepo._() {
    _myDio = Dio(getw());
  }

  static HomeRepo getInstance() {
    if (_repo == null) {
      _repo = HomeRepo._();
    }
    return _repo;
  }

  Observable saveToSd(String url) {
    return Observable.fromFuture(saveToSDCard(url));
  }

  Observable startFace(String imageUrl, int ceil, int i, bool male) {
    return Observable.fromFuture(startFaceAi(imageUrl, ceil, i, male));
  }

  Observable execSTAR(String filePath) {
    return Observable.fromFuture(execStar(filePath));
  }

  Observable execSTARL() {
    return Observable.fromFuture(execStarLong());
  }



  BaseOptions getw() {
    BaseOptions options = BaseOptions();
    options.connectTimeout = 50 * 1000;
    options.receiveTimeout = 50 * 1000;
//    options.contentType = ContentType.parse('application/x-www-form-urlencoded');
//    options.contentType = ContentType.json;
    options.responseType = ResponseType.plain;
    options.baseUrl = "http://62.234.196.81/";
    Map<String, dynamic> headers = Map<String, dynamic>();
    headers['Accept'] = 'application/json';
    headers['version'] = '1.0.0';
    options.headers = headers;
    return options;
  }

  Observable<AIBean> getImageAi(String url) {
    return Observable.fromFuture(_myDio.post('v2/api/infer/face', data: """
            {"url": "${url}"}
        """)).flatMap((value) {
      if (value != null &&
          (value.statusCode >= 200 && value.statusCode < 300)) {
        return Observable.fromFuture(compute(parseAiBean, value.toString()));
      } else {
        return Observable.fromFuture(null);
      }
    });
  }


}



AIBean parseAiBean(String value) {
  return AIBean.fromJson(json.decode(value));
}
