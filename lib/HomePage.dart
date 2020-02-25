/*
 * @author lsy
 * @date   2019-11-05
 **/
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gengmei_app_face/commonModel/base/BaseComponent.dart';
import 'package:gengmei_flutter_plugin/gengmei_flutter_plugin.dart';

import 'HomeModel.dart';
import 'commonModel/base/AppBase.dart';
import 'commonModel/ui/ALColors.dart';

class HomePage extends StatefulWidget {
  HomeModel _model;

  HomePage() {
    _model = new HomeModel();
  }

  @override
  State<StatefulWidget> createState() => HomeState(_model);
}

class HomeState extends State<HomePage> {
  HomeModel _model;

  HomeState(this._model);

  @override
  void initState() {
    super.initState();
    GengmeiFlutterPlugin.clearCache();
    GengmeiFlutterPlugin.albumNeedCache(false);
    clearDiskCachedImages();
    _model.init(context);
  }

  @override
  Widget build(BuildContext context) {
    print("HomeState ");
    return WillPopScope(
      child: Scaffold(
//        bottomNavigationBar: StreamBuilder<int>(
//            stream: _model.indexLive.stream,
//            initialData: _model.indexLive.data,
//            builder: (con, data) {
//              int index = data.data ?? 0;
//              return BottomNavigationBar(
//                  items: _model.items,
//                  currentIndex: index,
//                  onTap: (index) {
//                    _model.onTap(index);
//                  });
//            }),
          body: StreamBuilder<int>(
              stream: _model.widgetLive.stream,
              initialData: _model.widgetLive.data,
              builder: (con, data) {
                int index = data.data ?? 0;
                List<Widget> tabList = new List();
                _model.items.forEach((value) {
                  tabList.add(baseItem(value.index, value.svgIcon, value.name));
                });
                return Column(
                  children: <Widget>[
                    Expanded(
                        child: IndexedStack(
                      index: index,
                      children: _model.pages,
                    )),
//                  Container(
//                    decoration: BoxDecoration(boxShadow: [
//                      BoxShadow(
//                          color: Colors.black12,
//                          offset: Offset(0.0, 0.0), //阴影xy轴偏移量
//                          blurRadius: 1.0, //阴影模糊程度
//                          spreadRadius: 1.0 //阴影扩散程度
//                      )
//                    ]),
//                    height: 1,
//                  ),
                    Container(
                      color: ALColors.ColorF4F3F8,
                      height: 60,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: tabList,
                      ),
                    )
                  ],
                );
              })),
      onWillPop: () {
        return backApp();
      },
    );
  }

  Widget baseItem(int index, String pic, String text) {
    return Expanded(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _model.currentIndex = index;
              _model.onTap(index);
            },
            child: Container(
                height: 60,
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),
                    _model.currentIndex == index
                        ? SvgPicture.asset(pic, color: ALColors.Color323232)
                        : SvgPicture.asset(pic, color: ALColors.Color999999),
                    Container(
                      margin: EdgeInsets.only(top: 3),
                      child: baseText(
                          text,
                          12,
                          _model.currentIndex == index
                              ? Colors.black
                              : Colors.grey),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ))));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
