import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/commonModel/util/WindowUtil.dart';
import 'package:gengmei_app_face/commonModel/view/XHeadView.dart';

import 'HelpModel.dart';

class HelpWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HelpPageWidgetState();
}

class HelpPageWidgetState extends State<HelpWidget> {
  HelpModel _model;

  @override
  void initState() {
    _model = HelpModel();
    _model.getImage(
        context, "http://pic38.nipic.com/20140228/2457331_083845176000_2.jpg");
    super.initState();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Widget head(XHeadView xHeadView) {
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
            if (downPos != 1 && downPos != 2) {
              return;
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

  getStark(String t1, String t2) {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
      width: double.maxFinite,
      height: 120,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          CachedNetworkImage(
            width: double.maxFinite,
            imageUrl:
                "http://pic36.nipic.com/20131126/8821914_071759099000_2.jpg",
            fit: BoxFit.cover,
            placeholder: (BuildContext context, String url) {
              return Image.asset("asset/images/icon_head.png");
            },
          ),
          Container(
            height: 50,
            child: Column(
              children: <Widget>[
                Text(
                  t1,
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(
                    t2,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  double width;
  double height;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    WindowUtil.setBarStatus(false);
    return Scaffold(
        body: CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: StreamBuilder(
            stream: _model.imageLive.stream,
            initialData: _model.imageLive.data,
            builder: (con, data) {
              return head(XHeadView(
                  context, width, height, data.data, null, "//  明天穿什么？  //"));
            },
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate(<Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
            width: double.maxFinite,
            height: 200,
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl:
                  "http://pic29.nipic.com/20130507/8952533_183922555000_2.jpg",
              placeholder: (BuildContext context, String url) {
                return Image.asset("asset/images/icon_head.png");
              },
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 30, 20, 10),
            child: Text(
              "定制穿搭",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w300),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text("每天为你推荐最合适的搭配"),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            width: double.maxFinite,
            height: 200,
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl:
                  "http://pic38.nipic.com/20140222/5565441_173157063000_2.jpg",
              placeholder: (BuildContext context, String url) {
                return Image.asset("asset/images/icon_head.png");
              },
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 30, 20, 10),
            child: Text(
              "场景推荐",
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w300),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text("根据场景为你推荐变美方案"),
          ),
          getStark("MATCHMAKING", "---  相亲场景  ---"),
          getStark("LOVE SCENE", "---  恋爱场景  ---"),
          getStark("DATE SCENE", "---  约会场景  ---"),
          getStark("INTERVIEW", "---   面试场景  ---"),
          Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(0, 20, 0, 30),
              child: Text(
                "此处是我的底线",
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          )
        ]))
      ],
    ));
  }
}
