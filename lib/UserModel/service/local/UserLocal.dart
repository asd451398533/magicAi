/*
 * @author lsy
 * @date   2020-01-17
 **/

import 'package:flutter_common/Annotations/anno/User.dart';
import 'package:flutter_common/Annotations/anno/UserCenter.dart';

const WX_APPID = "wxa51215876ed98f9e";
const WX_APPSECRET = "a9de6217f055d8d47edaec341d6489c9";
const WX_LINE = "https://magicai.igengmei.com/apple-app-site-association/";

const OPEN_ID = "OPEN_ID";
const NICK_NAME = "NICK_NAME";
const HEAD_URL = "HEAD_URL";
const UIION_ID = "UIION_ID";
const ASSECS_TOKEN = "ASSECS_TOKEN";
const REFRESH_TOKEN = "REFRESH_TOKEN";

@UserCenter()
class UserLocal {
  @User(OPEN_ID)
  String openid;

  @User(NICK_NAME)
  String nickname;

  @User(HEAD_URL)
  String headimgurl;

  @User(UIION_ID)
  String unionid;

  @User(ASSECS_TOKEN)
  String accessToken;

  @User(REFRESH_TOKEN)
  String refreshToken;
}
