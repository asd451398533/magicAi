/*
 * @author lsy
 * @date   2020-01-17
 **/

import 'package:dio/dio.dart';
import 'package:gengmei_app_face/UserModel/service/local/UserLocal.dart';
import 'package:gengmei_app_face/UserModel/service/local/UserLocal.user.dart';
import 'package:gengmei_app_face/UserModel/service/remote/api/WXApi.dart';
import 'package:gengmei_app_face/UserModel/service/remote/api/WXApi.serv.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXCheckBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXLoginBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXUserBean.dart';
import 'package:rxdart/rxdart.dart';

class UserRepo {
  Dio _wxDio;
  WXApiImpl _apiImpl;
  UserLocalImpl _localImpl;

  UserRepo._Init() {
    _wxDio = Dio(BaseOptions()
      ..connectTimeout = 10 * 1000
      ..receiveTimeout = 10 * 1000
      ..baseUrl = "https://api.weixin.qq.com/");
    _apiImpl = WXApiImpl.getInstance();
    _localImpl = UserLocalImpl();
  }

  static UserRepo _userRepo;

  static UserRepo getInstance() {
    if (_userRepo == null) {
      _userRepo = UserRepo._Init();
    }
    return _userRepo;
  }

  Observable<WXLoginBean> loginWx(String code) {
    return _apiImpl
        .loginWX(_wxDio, WX_APPID, WX_APPSECRET, code, "authorization_code")
        .map((value) {
      if (value != null && (value.errcode == null || value.errcode == 0)) {
        _localImpl.saveaccessToken(value.accessToken);
        _localImpl.saverefreshToken(value.refreshToken);
        _localImpl.saveopenid(value.openid);
      }
      return value;
    });
  }

  Observable<WXCheckBean> tokenCheck(String access_token, String openid) {
    return _apiImpl.checkToken(_wxDio, access_token, openid);
  }

  Observable<WXLoginBean> refreshToken(String refreshToken) {
    return _apiImpl.refreshToken(
        _wxDio, WX_APPID, "refresh_token", refreshToken);
  }

  Observable<WXUserBean> getUserInfo(String access_token, String openid) {
    return _apiImpl.getWxUserInfo(_wxDio, access_token, openid).map((value) {
      if (value != null && (value.errcode == null || value.errcode == 0)) {
        _localImpl.savenickname(value.nickname);
        _localImpl.saveheadimgurl(value.headimgurl);
        _localImpl.saveunionid(value.unionid);
      }
      return value;
    });
  }
}
