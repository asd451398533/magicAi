/*
 * @author lsy
 * @date   2019-12-04
 **/

import 'package:flutter/cupertino.dart';
import 'package:flutter_common/Annotations/RouterBaser.dart';
import 'package:flutter_common/Annotations/anno/Router.dart';
import 'package:gengmei_app_face/HomeModel/HomeRouterImpl.dart';

@Router("HomeRouter",HomeRouterImpl,true)
abstract class HomeRouter implements RouterBaser{
  Widget getHomeWidget();
}