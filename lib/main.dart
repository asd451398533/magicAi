import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_common/Annotations/anno/RouterCenter.dart';
import 'package:gengmei_app_face/UserModel/page/user/UserPageWidget.dart';
import 'package:gengmei_app_face/commonModel/cache/CacheManager.dart';
import 'package:gengmei_app_face/main.mark.dart';

import 'HomePage.dart';
import 'commonModel/toast/toast.dart';


void main() async {
  runApp(switchPage(window.defaultRouteName));
}

Widget switchPage(String pageRouter){
  print("FLutter pageRouter "+pageRouter);
  switch(pageRouter){
    case "answer":
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RouterCenterImpl().findUserRouter()?.getAnswerPage(),
      )
        ;
    default:
      return MyApp();
  }
}

@RouterCenter()
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MagicAi',
//      theme: ThemeData(primaryColor: Colors.white),
//      debugShowCheckedModeBanner: false,
//      theme: ThemeData(
//          primaryColor: YColors.themeColor[.value != null
//              ? Provider.of<ThemeProvider>(context).value
//              : themeValue]["primaryColor"],
//          primaryColorDark: YColors.themeColor[Provider.of<ThemeProvider>(context).value != null
//              ? Provider.of<ThemeProvider>(context).value
//              : themeValue]["primaryColorDark"],
//          accentColor: YColors.themeColor[Provider.of<ThemeProvider>(context).value != null
//              ? Provider.of<ThemeProvider>(context).value
//              : themeValue]["colorAccent"]),
      home: HomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  var _pageController = PageController(initialPage: 0);

  var pages = <Widget>[
    RouterCenterImpl().findHomeRouter()?.getHomeWidget(),
    RouterCenterImpl().findHelpRouter()?.getHelpPage(),
    UserPageWidget(),
  ];

  _pageChange(int page){
    setState(() {
      _selectedIndex = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            body: PageView.builder(
              onPageChanged: _pageChange,
              controller: _pageController,
              itemCount: pages.length,
              itemBuilder: (BuildContext context, int index) {
                return pages.elementAt(index);
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text("主页"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.question_answer),
                  title: Text("变美助手"),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.supervised_user_circle),
                  title: Text("我的"),
                ),
//                BottomNavigationBarItem(
//                  icon: Icon(Icons.apps),
//                  title: Text(YStrings.project),
//                ),
              ],
              //当前选中下标
              currentIndex: _selectedIndex,
              //显示模式
              type: BottomNavigationBarType.fixed,
              //选中颜色
              fixedColor: Theme.of(context).primaryColor,
              //点击事件
              onTap: _onItemTapped,
            )),
        onWillPop: () {
          _backPress(context);
        });
  }

  void _onItemTapped(int index) {
    //bottomNavigationBar 和 PageView 关联
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }
}

DateTime lastPopTime;

_backPress(BuildContext context) async {
  if (lastPopTime == null ||
      DateTime.now().difference(lastPopTime) > Duration(seconds: 1)) {
    lastPopTime = DateTime.now();
    Toast.show(context,'再按一次退出');
  } else {
    lastPopTime = DateTime.now();
    await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
}
