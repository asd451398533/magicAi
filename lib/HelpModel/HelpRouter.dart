/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'package:flutter/material.dart';
import 'package:flutter_common/Annotations/RouterBaser.dart';
import 'package:flutter_common/Annotations/anno/Router.dart';

import 'HelpRouterImpl.dart';

@Router("HelpRouter",HelpRouterImpl,true)
abstract class HelpRouter implements RouterBaser{
  Widget getHelpPage();
}