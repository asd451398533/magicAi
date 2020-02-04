/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'package:flutter/src/widgets/framework.dart';
import 'package:gengmei_app_face/HelpModel/page/HelpWidget.dart';

import 'HelpRouter.dart';

class HelpRouterImpl implements HelpRouter{
  @override
  Widget getHelpPage() {
    return HelpWidget();
  }

}