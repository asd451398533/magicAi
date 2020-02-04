/*
 * @author lsy
 * @date   2019-09-16
 **/

import 'dart:math';

import 'package:dio/dio.dart';
import 'package:gengmei_app_face/commonModel/net/DioUtil.dart';

/**
 * 生产环境
 */
const String APP_HOST_RELEASE = "https://earth.iyanzhi.com";
/**
 * 测试环境
 */
const String APP_HOST_DEBUG = "http://earth.gmapp.env";

/**
 * 开发环境
 */
const String APP_HOST_DEV = "http://earth.alpha.newdev";

class Api {
  static String BUILD_CONFIG;
  static String PROVIDER_NAME;

  static Api intance = new Api._();

  Api._();

  static Api getInstance() {
    return intance;
  }


  String getBaseUrl(String string) {
    if (string == "debug") {
      return APP_HOST_DEBUG;
    } else if (string == "dev") {
      return APP_HOST_DEV;
    } else if (string == "release") {
      return APP_HOST_RELEASE;
    } else {
      return null;
    }
  }
}
