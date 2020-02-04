/*
 * @author lsy
 * @date   2019-09-24
 **/
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gengmei_app_face/commonModel/cache/CacheManager.dart';
import 'package:gengmei_app_face/commonModel/eventbus/GlobalEventBus.dart';
import 'package:gengmei_app_face/commonModel/eventbus/event/LoginEvent.dart';
import 'package:gengmei_app_face/commonModel/eventbus/event/SyncMessageEvent.dart';
import 'package:gengmei_app_face/commonModel/net/Api.dart';
import 'package:rxdart/rxdart.dart';

const BURIED_METHOD = "FLUTTER_BURIED";
const NET_TYPE = "GET_NET_TYPE";
const INIT_PARAMS = "INIT_PARAMS";
const UPLOAD_IMG = "UPLOAD_IMG";
const USER_LOGOUT = "USER_LOGOUT";
const FINISH_CURRENT_ACTIVITY = "FINISH_CURRENT_ACTIVITY";
const ALBUM_RESULT = "ALBUM_RESULT";
const methodChannel = const MethodChannel('flutter_channel');
const eventChannel = const EventChannel('flutter_channel_event');
StreamSubscription _listen;

const faceAi = const MethodChannel('samples.flutter.io/startFaceAi');

Future quitApp() async {
  return await faceAi.invokeMethod('quit');
}

Future senSDK(String path) async {
  return await faceAi.invokeMethod("senSDK", path);
}

Future backApp() async{
  return await faceAi.invokeMethod("backApp");
}

Future aiCamera() async {
  return await faceAi.invokeMethod("aiCamera");
}

Future<String> execStar(String filePath) async {
  return await faceAi.invokeMethod("execStar", {"filePath": filePath});
}

Future<String> execStarLong() async {
  return await faceAi.invokeMethod("execStarLong", null);
}

Future<List> aiDemo() async{
  return await faceAi.invokeMethod("demo");
}

Future<Map> loginWX(String appid) async{
  return await faceAi.invokeMethod("loginWX",appid);
}

Future<String> startFaceAi(
    String url, int age, int wantAge, bool isMale) async {
  return await faceAi.invokeMethod('startFaceAi',
      {"AGE": age, "WANT_AGE": wantAge, "IS_MALE": isMale, "URL": url});
}

Future<bool> saveToSDCard(String url) async {
  return await faceAi.invokeMethod("saveImg", {"url": url});
}

void jumpToH5(String jumpToName, Map params) {
  Map map = {"page_name": jumpToName};
  if (params != null) {
    map.addAll(params);
  }
  methodChannel.invokeMethod("FLUTTER_TO_H5", map);
}

void jumpToNative(String jumpToName, Map params) {
  Map map = {"page_name": jumpToName};
  if (params != null) {
    map.addAll(params);
  }
  methodChannel.invokeMethod("FLUTTER_TO_NATIVE", map);
}

void jumpToFlutter(String jumpToName, Map params) {
  Map map = {"page_name": jumpToName};
  if (params != null) {
    map.addAll(params);
  }
  methodChannel.invokeMethod("FLUTTER_TO_FLUTTER", map);
}

Future getBuriedInfo() async {
  return await methodChannel.invokeMethod(BURIED_METHOD, null);
}

Observable messagePopPicker(Map params) {
  return Observable.fromFuture(
      methodChannel.invokeMethod("MESSAGE_POP_PICKER", params));
}

Observable getNetType() {
  return Observable.fromFuture(methodChannel.invokeMethod(NET_TYPE, null));
}

Observable<String> uploadImg(String path, String token) {
  return Observable.fromFuture(
      methodChannel.invokeMethod(UPLOAD_IMG, {"path": path, "token": token}));
}

Observable<bool> userLogout() {
  return Observable.fromFuture(methodChannel.invokeMethod(USER_LOGOUT));
}

Observable<bool> finishCurrentActivity() {
  return Observable.fromFuture(
      methodChannel.invokeMethod(FINISH_CURRENT_ACTIVITY));
}

Observable<bool> albumResult(Map selectList) {
  return Observable.fromFuture(
      methodChannel.invokeMethod(ALBUM_RESULT, selectList));
}

void initParams(VoidCallback callback) {
//  _listen =
//      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  methodChannel.invokeMethod(INIT_PARAMS, null).then((value) {
    print("lsy INITPARAMS ！！   $value");
//    Api.getInstance().initBuildConfig(value);
    initBuried(callback);
  }).catchError((error) {
    print(error);
  });
}

void _onEvent(Object event) {
//  print("ONEVENT !!!!   ${event}");
//  if (event == null) {
//    return;
//  }
//  Map map = event as Map;
//
//  if (map["syncMessage"] != null && map["syncMessage"]) {
//    GlobalEventBus().event.fire(SyncMessageEvent());
//    return;
//  }
//
//  String cookie = (event as Map)["Cookie"];
//  if (cookie != null) {
//    Api.getInstance().setDioCookie(event);
//  }
//  String userID = (event as Map)["userId"];
//  if (userID != null) {
//    RouterCenterImpl().findUserRouter().loginChangeUserID(userID);
//  }
//  GlobalEventBus().event.fire(LoginEvent(userID, cookie));
}

void _onError(Object error) {
  print("ERROR $error");
}

void initBuried(VoidCallback call) {
  getBuriedInfo().then((value) {
    Map temp = new Map<String, dynamic>.from(value);
    print("lsy INITBURIED ！！   $temp");
    temp.forEach((k, v) {
      CacheManager.getInstance().get(MEMORY_CACHE).save(k, v);
    });
    call();
//    catchAllError();
  }).catchError((error) {
    print(error);
  });
}
