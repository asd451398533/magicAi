/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'package:flutter/cupertino.dart';
import 'package:flutter_common/Annotations/RouterBaser.dart';
import 'package:flutter_common/Annotations/anno/Router.dart';

import 'UserRouterImpl.dart';

@Router("UserRouter",UserRouterImpl,true)
abstract class UserRouter implements RouterBaser{

  Widget getUserPage();

  Widget getAnswerPage();
}