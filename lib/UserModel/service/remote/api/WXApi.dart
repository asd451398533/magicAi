/*
 * @author lsy
 * @date   2020-01-17
 **/
import 'package:flutter_common/Annotations/anno/Get.dart';
import 'package:flutter_common/Annotations/anno/Post.dart';
import 'package:flutter_common/Annotations/anno/Query.dart';
import 'package:flutter_common/Annotations/anno/ServiceCenter.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/AnswerPageBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/GMUserBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXCheckBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXLoginBean.dart';
import 'package:gengmei_app_face/UserModel/service/remote/entity/WXUserBean.dart';
import 'package:gengmei_app_face/commonModel/bean/BaseResponse.dart';

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

  @Get("-h97n8co7-1258538551.bj.apigw.tencentcs.com/release/comments/page")
  AnswerPageBean getAnswerPage(
      @Query("pageCount") int pageCount, @Query("page") int page
      ,@Query("desc")String value);

  @Post("-f56zjcz3-1258538551.bj.apigw.tencentcs.com/release/wechatinfo")
  GMUserBean getGMUserBean(@Query("phoneid") String phoneId,
      @Query("username") String userName, @Query("headimg") String headimg);

  @Post("-h97n8co7-1258538551.bj.apigw.tencentcs.com/release/comments/add")
  BaseResponse submitAnswer(
      @Query("user_id") String uid,
      @Query("content") String content,
      @Query("filter_name") String filter_name,
      @Query("question_1") String question_1,
      @Query("question_2") String question_2,
      @Query("question_3") String question_3,
      @Query("username") String username,
      @Query("image") String image);
}
