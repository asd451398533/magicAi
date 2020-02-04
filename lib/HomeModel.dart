/*
 * @author lsy
 * @date   2019-11-05
 **/
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
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
  LiveData<int> indexLive = new LiveData();
  LiveData<int> widgetLive = new LiveData();
  final List<HomeItem> items = [];
  final List<Widget> pages = [];
  int currentIndex = 0;

  @override
  void dispose() {
    indexLive.dispost();
    widgetLive.dispost();
  }

  void init() {
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
