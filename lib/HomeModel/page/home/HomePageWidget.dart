import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_album/flutter_album.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gengmei_app_face/HomeModel/page/detect/DetectFacePage.dart';
import 'package:gengmei_app_face/HomeModel/page/want/WantPage.dart';
import 'package:gengmei_app_face/commonModel/GMBase.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
import 'package:gengmei_app_face/commonModel/util/JumpUtil.dart';
import 'package:gengmei_app_face/commonModel/util/WindowUtil.dart';
import 'package:gengmei_app_face/commonModel/view/XHeadView.dart';
import 'package:gengmei_app_face/main.mark.dart';

import 'HomeModel.dart';

class HomePageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageWidgetState();
}

class HomePageWidgetState extends State<HomePageWidget> {
  double width;
  double height;
  List<String> swarpList = [
    "http://gss0.baidu.com/9fo3dSag_xI4khGko9WTAnF6hhy/lvpics/w=1000/sign=c6c92d7ad788d43ff0a995f24d2ed31b/f636afc379310a5589d354fbb64543a9832610cd.jpg",
    "http://img.mp.itc.cn/upload/20161019/6049062618f84eeab4d96c2f13ee3b5a_th.jpg",
    "http://5b0988e595225.cdn.sohucs.com/images/20180105/fad695ef23a14b778311f078434d54ed.jpeg"
  ];
  GlobalKey _key = new GlobalKey();

  HomeModel _model;

  HomePageWidgetState() {
    _model = HomeModel();
  }

  @override
  void initState() {
    _model.loadData(
        context, "http://pic46.nipic.com/20140817/7144451_144052790000_2.jpg");
    super.initState();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  void toAiDemo(String face, String eye) {
    aiDemo(face, eye).then((value) {
      if (value != null && value.isNotEmpty) {
        var list = List<String>.from(value);
        JumpUtil.jumpAlp(context, WantPage(list[0], list[1], list[2]))
            .then((value) {
          if (value != null && value == 1) {
            toAiDemo(face, eye);
          }
        });
      }
    });
  }

  head(BuildContext context, XHeadView xHeadView) {
    return Container(
      child: GestureDetector(
          onTap: () {
            print("tap !! ");
          },
          onTapDown: (detail) {
            print("down !! ");
            xHeadView.onTapDown(detail);
          },
          onTapUp: (detail) {
            int downPos = xHeadView.onTapUp(detail);

            if (downPos == -1) {
              return;
            }
            var albumPage = GMAblum()
                .getAlbumPage(true, 1, null, noVideoHint: "暂时不支持选着视频哦~");
            if (albumPage != null) {
              JumpUtil.jumpLeft(context, albumPage).then((value) {
                if (value != null) {
                  if (downPos == 3) {
                    JumpUtil.jumpLeft(context, DetectFacePage(value[0]))
                        .then((value) {
                      if (value != null && value is List) {
                        toAiDemo(value[0], value[1]);
                      }
                    });
                    return;
                  }
                  _model.gotoAct(File(value[0]), downPos, context);
                }
              });
            }
          },
          child: Container(
            width: double.maxFinite,
            height: xHeadView.allHeight,
            child: CustomPaint(
              painter: xHeadView,
            ),
          )),
    );
  }

  Swrap() {
    Widget _swiperBuilder(BuildContext context, int index) {
      return CachedNetworkImage(
        imageUrl: swarpList[index],
        fit: BoxFit.cover,
      );
    }

    return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        width: MediaQuery.of(context).size.width,
        height: 150.0,
        child: Swiper(
          key: _key,
          itemBuilder: _swiperBuilder,
          itemCount: swarpList.length,
          pagination: new SwiperPagination(
              builder: DotSwiperPaginationBuilder(
            color: Colors.black54,
            activeColor: Colors.white,
          )),
//            control: new SwiperControl(),
          scrollDirection: Axis.horizontal,
          autoplay: true,
          onTap: (index) => print('点击了第$index个'),
        ));
  }

  getRow() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: <Widget>[
          getRowItem(
              "http://pic38.nipic.com/20140217/7643674_131828170000_2.jpg", 0),
          getRowItem(
              "http://pic38.nipic.com/20140217/7643674_131828170000_2.jpg", 20)
        ],
      ),
    );
  }

  getRowItem(String picUrl, double pad) {
    return Container(
        margin: EdgeInsets.fromLTRB(pad, 0, 0, 0),
        width: (width - 60) / 2,
        height: 230,
        child: Card(
          elevation: 3.0,
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl: picUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                        border: new Border.all(
                            color: Color(0xFFFF0000), width: 0.5),
                        color: Colors.yellow),
                    child: Center(
                      child: Text(
                        "21人参与",
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  richTextWid04("形象评估报告"),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Text(
                      "个人形象评估",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      width: 100,
                      height: 25,
                      child: OutlineButton(
                        onPressed: () {},
                        child: Center(
                          child: Text("参与研究"),
                        ),
                      )),
                ],
              )
            ],
          ),
        ));
  }

  Widget richTextWid04(String data) {
    final Gradient gradient =
        LinearGradient(colors: [Colors.redAccent, Colors.green]);
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(Offset.zero & bounds.size);
      },
      child: Text(data,
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.white, fontSize: 18)),
    );
  }

  getBottomColumn() {
    return Column(
      children: <Widget>[
        getBottomColumnItem("你掉进了情人的哪个漩涡？"),
        getBottomColumnItem("打电话看出爱情敏感度"),
        getBottomColumnItem("你掉进了情人的哪个漩涡？")
      ],
    );
  }

  getBottomColumnItem(String text) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      width: width - 40,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
              "http://a.hiphotos.baidu.com/lvpics/h=800/sign=5a82402cd5ca7bcb627bca2f8e086b3f/caef76094b36acaf0651ef137ed98d1000e99caf.jpg"),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
                border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                color: Colors.yellow),
            child: Center(
              child: Text(
                "21人参与",
                style: TextStyle(fontSize: 10),
              ),
            ),
          ),
          Container(
            height: 30,
          ),
          Center(
            child: Text(
              text,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Center(
              child: Container(
                  width: 100,
                  height: 25,
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: OutlineButton(
                    onPressed: () {},
                    borderSide: new BorderSide(color: Colors.white),
                    child: Center(
                      child: Text(
                        "开始",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return new Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: StreamBuilder<UIHeadBean>(
              stream: _model.headLive.stream,
              initialData: _model.headLive.data,
              builder: (con, data) {
                if (data.data == null) {
                  return head(context,
                      XHeadView(context, width, height, null, null, null));
                }
                return head(
                    context,
                    XHeadView(context, width, height, data.data.img,
                        data.data.icon, null));
              }),
        ),
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            Swrap(),
            getRow(),
            Container(
              height: 10,
            ),
            Column(
              children: <Widget>[
                Center(
                  child: Text(
                    "为你推荐的专业模式",
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                Container(
                  height: 5,
                ),
                Center(
                  child: Text(
                    "/////////PROFESSOIONAL TEST/////////",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Container(
                  height: 5,
                ),
                getBottomColumn(),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 30),
                  child: Text(
                    "此处是我的底线",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                )
              ],
            )
          ]),
        ),
      ],
    ));
  }
}
