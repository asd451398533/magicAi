/*
 * @author lsy
 * @date   2019-11-05
 **/
import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/commonModel/picker/base/BaseBottomPicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gengmei_app_face/main.mark.dart';

import 'commonModel/live/BaseModel.dart';
import 'commonModel/live/LiveData.dart';

class HomeItem {
  HomeItem(this.index, this.svgIcon,this.name);

  int index;
  String svgIcon;
  String name;
}

class HomeModel extends BaseModel {

  static const EventChannel _eventChannel =
  const EventChannel('samples.flutter.io/startFaceAi_flutter');

  LiveData<int> indexLive = new LiveData();
  LiveData<int> widgetLive = new LiveData();
  final List<HomeItem> items = [];
  final List<Widget> pages = [];
  int currentIndex = 0;
  StreamSubscription _listen;
  BuildContext context;


  @override
  void dispose() {
    _listen.cancel();
    indexLive.dispost();
    widgetLive.dispost();
  }

  void init(BuildContext context) {
    this.context=context;
    _listen = _eventChannel
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
    var mainWidget = RouterCenterImpl().findHomeRouter()?.getHomeWidget();
    var findPage = RouterCenterImpl().findHelpRouter()?.getHelpPage();
    var userPage = RouterCenterImpl().findUserRouter()?.getUserPage();
    int index = 0;
    if (mainWidget != null) {
      items.add(HomeItem(index, "images/home.svg","主页"));
      pages.add(mainWidget);
      index++;
    }
    if (findPage != null) {
      items.add(HomeItem(index, "images/find.svg","变美助手"));
      pages.add(findPage);
      index++;
    }
    if (userPage != null) {
      items.add(HomeItem(index, "images/user.svg","我的"));
      pages.add(userPage);
      index++;
    }
  }

  void _onEvent(Object event) {
    BaseBottomPicker()..setPicker(testPicker())..show(context);
  }

  void _onError(Object error) {
    print("ERROR $error");
  }


  void onTap(int index) {
    indexLive.notifyView(index);
    widgetLive.notifyView(index);
//    if (index == 2) {
//      //TODO
//    } else if (index < 2) {
//      widgetLive.notifyView(index);
//    } else {
//      widgetLive.notifyView(index - 1);
//    }
  }
}

class testPicker implements IBottomPicker{
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 200,
      color: Colors.blue,
    );
  }

  @override
  void dispose() {
  }

  @override
  void initState(dismissCall) {
  }

}
