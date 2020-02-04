// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// ServiceGenerator
// **************************************************************************

import 'dart:convert';

import 'dart:io';

import 'package:rxdart/rxdart.dart';

import 'package:dio/dio.dart';

import 'package:flutter/foundation.dart';

import 'package:gengmei_app_face/UserModel/service/remote/entity/WXLoginBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXCheckBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXUserBean.dart';

const bool inProduction = const bool.fromEnvironment("dart.vm.product");

class WXApiImpl {
  static JsonEncoder encoder = JsonEncoder.withIndent('  ');

  static WXApiImpl _instance;

  WXApiImpl._() {}

  static WXApiImpl getInstance() {
    if (_instance == null) {
      _instance = WXApiImpl._();
    }
    return _instance;
  }

  Observable<WXLoginBean> loginWX(
      Dio _dio, String appid, String secret, String code, String grant_type) {
    return Observable.fromFuture(get(_dio, 'sns/oauth2/access_token', data: {
      'appid': appid,
      'secret': secret,
      'code': code,
      'grant_type': grant_type,
    })).flatMap((value) {
      if (value != null &&
          (value.statusCode >= 200 && value.statusCode < 300)) {
        return Observable.fromFuture(
            compute(paseWXLoginBean, value.toString()));
      } else {
        return Observable.fromFuture(null);
      }
    });
  }

  Observable<WXLoginBean> refreshToken(
      Dio _dio, String appid, String grant_type, String refreshToken) {
    return Observable.fromFuture(get(_dio, 'sns/oauth2/refresh_token', data: {
      'appid': appid,
      'grant_type': grant_type,
      'refresh_token': refreshToken,
    })).flatMap((value) {
      if (value != null &&
          (value.statusCode >= 200 && value.statusCode < 300)) {
        return Observable.fromFuture(
            compute(paseWXLoginBean, value.toString()));
      } else {
        return Observable.fromFuture(null);
      }
    });
  }

  Observable<WXCheckBean> checkToken(
      Dio _dio, String access_token, String openid) {
    return Observable.fromFuture(get(_dio, 'sns/auth', data: {
      'access_token': access_token,
      'openid': openid,
    })).flatMap((value) {
      if (value != null &&
          (value.statusCode >= 200 && value.statusCode < 300)) {
        return Observable.fromFuture(
            compute(paseWXCheckBean, value.toString()));
      } else {
        return Observable.fromFuture(null);
      }
    });
  }

  Observable<WXUserBean> getWxUserInfo(
      Dio _dio, String access_token, String openid) {
    return Observable.fromFuture(get(_dio, 'sns/userinfo', data: {
      'access_token': access_token,
      'openid': openid,
    })).flatMap((value) {
      if (value != null &&
          (value.statusCode >= 200 && value.statusCode < 300)) {
        return Observable.fromFuture(compute(paseWXUserBean, value.toString()));
      } else {
        return Observable.fromFuture(null);
      }
    });
  }

  ///==================base method==================

  Future<Response> get(Dio _dio, url, {data, options, cancelToken}) async {
    Response response;
    print("GET===> URL:$url   data:$data");
    try {
      response = await _dio.get(url,
          queryParameters: data, options: options, cancelToken: cancelToken);
      _printHttpLog(response);
    } on DioError catch (e) {
      print('get error---------$e  ${formatError(e)}');
    }
    return response;
  }

  Future<Response> post(Dio _dio, url, {data, options, cancelToken}) async {
    Response response;
    print("POST===> URL:$url   data:$data");
    try {
      response = await _dio.post(url,
          data: FormData.fromMap(data),
          options: options,
          cancelToken: cancelToken);
      _printHttpLog(response);
    } on DioError catch (e) {
      print('get error---------$e  ${formatError(e)}');
    }
    return response;
  }

  Future<Response> put(Dio _dio, url, {data, options, cancelToken}) async {
    Response response;
    print("PUT===> URL:$url   data:$data");
    try {
      response = await _dio.put(url,
          data: FormData.fromMap(data),
          options: options,
          cancelToken: cancelToken);
      _printHttpLog(response);
    } on DioError catch (e) {
      print('get error---------$e  ${formatError(e)}');
    }
    return response;
  }

  Future<Response> delete(Dio _dio, url, {data, options, cancelToken}) async {
    Response response;
    print("DELETE===> URL:$url   data:$data");
    try {
      response = await _dio.delete(url,
          data: FormData.fromMap(data),
          options: options,
          cancelToken: cancelToken);
      _printHttpLog(response);
    } on DioError catch (e) {
      print('get error---------$e  ${formatError(e)}');
    }
    return response;
  }

  Future<Response> upload(Dio _dio, url, String key, String path,
      {Map<String, dynamic> data, options, cancelToken}) async {
    Response response;
    print("UPLOAD===> URL:$url  {$key : $path }   data:$data");
    MultipartFile file = await MultipartFile.fromFile(path,
        filename: path.substring(path.lastIndexOf("/") + 1, path.length));
    if (data == null) {
      data = new Map<String, dynamic>();
    }
    data.putIfAbsent(key, () => file);
    try {
      response = await _dio.post(url,
          data: FormData.fromMap(data),
          options: options,
          cancelToken: cancelToken);
      _printHttpLog(response);
    } on DioError catch (e) {
      print('get error---------$e  ${formatError(e)}');
    }
    return response;
  }

  void _printHttpLog(Response response) {
    if (!inProduction) {
      try {
        printRespond(response);
      } catch (ex) {
        print("Http Log" + " error......");
      }
    }
  }

  static void printRespond(Response response) {
    Map httpLogMap = Map();
    httpLogMap.putIfAbsent("requestMethod", () => "${response.request.method}");
    httpLogMap.putIfAbsent("requestUrl", () => "${response.request.uri}");
    httpLogMap.putIfAbsent("requestHeaders", () => response.request.headers);
    httpLogMap.putIfAbsent(
        "requestQueryParameters", () => response.request.queryParameters);
    if (response.request.data is FormData) {
      httpLogMap.putIfAbsent("requestData",
          () => ((response.request.data as FormData).fields.toString()));
    }
    httpLogMap.putIfAbsent(
        "respondData", () => json.decode(response.data.toString()));
    printJson(httpLogMap);
  }

  static void printJson(Object object) {
    try {
      var encoderString = encoder.convert(object);
      debugPrint(encoderString);
    } catch (e) {
      print(e);
    }
  }

  String formatError(DioError e) {
    String reason = "";
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      reason = "连接超时 ${e.message}";
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      reason = "请求超时 ${e.message}";
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      reason = "响应超时 ${e.message}";
    } else if (e.type == DioErrorType.RESPONSE) {
      reason = "出现异常 ${e.message}";
    } else if (e.type == DioErrorType.CANCEL) {
      reason = "请求取消 ${e.message}";
    } else {
      reason = "未知错误 ${e.message}";
    }
    return reason;
  }
}

WXLoginBean paseWXLoginBean(String value) {
  return WXLoginBean.fromJson(json.decode(value));
}

WXCheckBean paseWXCheckBean(String value) {
  return WXCheckBean.fromJson(json.decode(value));
}

WXUserBean paseWXUserBean(String value) {
  return WXUserBean.fromJson(json.decode(value));
}
