/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'package:flutter/src/widgets/framework.dart';
import 'package:gengmei_app_face/HomeModel/HomeRouter.dart';
import 'package:gengmei_app_face/HomeModel/page/home/HomePageWidget.dart';

class HomeRouterImpl implements HomeRouter {
  @override
  Widget getHomeWidget() {
    return HomePageWidget();
  }
}
