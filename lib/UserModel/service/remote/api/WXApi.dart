/*
 * @author lsy
 * @date   2020-01-17
 **/
import 'package:flutter_common/Annotations/anno/Get.dart';
import 'package:flutter_common/Annotations/anno/Query.dart';
import 'package:flutter_common/Annotations/anno/ServiceCenter.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXCheckBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXLoginBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXUserBean.dart';

@ServiceCenter()
abstract class WXApi {
  @Get("sns/oauth2/access_token")
  WXLoginBean loginWX(
      @Query("appid") String appid,
      @Query("secret") String secret,
      @Query("code") String code,
      @Query("grant_type") String grant_type);

  @Get("sns/oauth2/refresh_token")
  WXLoginBean refreshToken(
      @Query("appid") String appid,
      @Query("grant_type") String grant_type,
      @Query("refresh_token") String refreshToken);

  @Get("sns/auth")
  WXCheckBean checkToken(@Query("access_token") String access_token,
      @Query("openid") String openid);

  @Get("sns/userinfo")
  WXUserBean getWxUserInfo(@Query("access_token") String access_token,
      @Query("openid") String openid);
}
