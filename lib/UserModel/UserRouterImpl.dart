/*
 * @author lsy
 * @date   2019-12-04
 **/
import 'package:flutter/src/widgets/framework.dart';
import 'package:gengmei_app_face/UserModel/page/answer/AnswerPage.dart';
import 'package:gengmei_app_face/UserModel/page/user/UserPageWidget.dart';

import 'UserRouter.dart';

class UserRouterImpl implements UserRouter{
  @override
  Widget getUserPage() {
    return UserPageWidget();
  }

  @override
  Widget getAnswerPage() {
    return AnswerPage();
  }

}