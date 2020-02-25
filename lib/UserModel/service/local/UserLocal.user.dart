// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// UserGenerator
// **************************************************************************

import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserLocalImpl {
  factory UserLocalImpl() => _sharedInstance();

  static UserLocalImpl _instance;

  UserLocalImpl._() {}

  static UserLocalImpl _sharedInstance() {
    if (_instance == null) {
      _instance = UserLocalImpl._();
    }
    return _instance;
  }

  Future<bool> saveopenid(String openid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString("OPEN_ID", openid);
  }

  Observable<String> getopenid() {
    return Observable.fromFuture(SharedPreferences.getInstance())
        .flatMap((value) {
      return Observable.fromFuture(Future.value(value.getString("OPEN_ID")));
    });
  }

  Future<bool> savenickname(String nickname) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString("NICK_NAME", nickname);
  }

  Observable<String> getnickname() {
    return Observable.fromFuture(SharedPreferences.getInstance())
        .flatMap((value) {
      return Observable.fromFuture(Future.value(value.getString("NICK_NAME")));
    });
  }

  Future<bool> saveheadimgurl(String headimgurl) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString("HEAD_URL", headimgurl);
  }

  Observable<String> getheadimgurl() {
    return Observable.fromFuture(SharedPreferences.getInstance())
        .flatMap((value) {
      return Observable.fromFuture(Future.value(value.getString("HEAD_URL")));
    });
  }

  Future<bool> saveunionid(String unionid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString("UIION_ID", unionid);
  }

  Observable<String> getunionid() {
    return Observable.fromFuture(SharedPreferences.getInstance())
        .flatMap((value) {
      return Observable.fromFuture(Future.value(value.getString("UIION_ID")));
    });
  }

  Future<bool> saveaccessToken(String accessToken) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString("ASSECS_TOKEN", accessToken);
  }

  Observable<String> getaccessToken() {
    return Observable.fromFuture(SharedPreferences.getInstance())
        .flatMap((value) {
      return Observable.fromFuture(
          Future.value(value.getString("ASSECS_TOKEN")));
    });
  }

  Future<bool> saverefreshToken(String refreshToken) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString("REFRESH_TOKEN", refreshToken);
  }

  Observable<String> getrefreshToken() {
    return Observable.fromFuture(SharedPreferences.getInstance())
        .flatMap((value) {
      return Observable.fromFuture(
          Future.value(value.getString("REFRESH_TOKEN")));
    });
  }

  Future<bool> savephone(String phone) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setString("PHONE_NUMBER", phone);
  }

  Observable<String> getphone() {
    return Observable.fromFuture(SharedPreferences.getInstance())
        .flatMap((value) {
      return Observable.fromFuture(
          Future.value(value.getString("PHONE_NUMBER")));
    });
  }

  Future<bool> saveuid(int uid) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.setInt("USER_ID", uid);
  }

  Observable<int> getuid() {
    return Observable.fromFuture(SharedPreferences.getInstance())
        .flatMap((value) {
      return Observable.fromFuture(Future.value(value.getInt("USER_ID")));
    });
  }

  Future<bool> clearAll() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    return s.clear();
  }
}
