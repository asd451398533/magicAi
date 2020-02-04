/*
 * @author lsy
 * @date   2020-01-17
 **/
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXCheckBean.dart';

class WXLoginBean extends WXCheckBean {
  int errcode;
  String errmsg;
  String accessToken;
  int expiresIn;
  String refreshToken;
  String openid;
  String scope;
  String unionid;

  WXLoginBean(
      {this.accessToken,
        this.expiresIn,
        this.refreshToken,
        this.openid,
        this.scope,
        this.unionid});

  WXLoginBean.fromJson(Map<String, dynamic> json) {
    errcode = json['errcode'];
    errmsg = json['errmsg'];
    accessToken = json['access_token'];
    expiresIn = json['expires_in'];
    refreshToken = json['refresh_token'];
    openid = json['openid'];
    scope = json['scope'];
    unionid = json['unionid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    data['expires_in'] = this.expiresIn;
    data['refresh_token'] = this.refreshToken;
    data['openid'] = this.openid;
    data['scope'] = this.scope;
    data['unionid'] = this.unionid;
    return data;
  }
}

