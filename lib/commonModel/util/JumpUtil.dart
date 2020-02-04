/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'package:flutter/cupertino.dart';
import 'package:gengmei_app_face/res/anim/Anim.dart';

class JumpUtil {
  static Future jumpLeft(BuildContext context, Widget widget) async {
    return await Navigator.push(context, new CustomRoute(widget));
  }

  static Future jumpAlp(BuildContext context, Widget widget) async {
    return await Navigator.push(
        context, new CustomRoute(widget, routeWay: RouteWay.ALP));
  }
}
