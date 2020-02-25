/*
 * @author lsy
 * @date   2020-02-11
 **/
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gengmei_app_face/commonModel/base/BaseComponent.dart';
import 'package:gengmei_app_face/commonModel/ui/ALColors.dart';

class AnswerItem {
  String name;
  String head;
  String content;
  bool like;
  int likeCount;
  String time;
  String filterName;

  AnswerItem(this.name, this.head, this.content, this.like, this.likeCount,
      this.time, this.filterName);
}

class AnswerItemPage extends StatelessWidget {
  AnswerItem item;
  VoidCallback likeClick;

  AnswerItemPage(this.item, this.likeClick);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 50),
      margin: EdgeInsets.only(left: 15, right: 15, top: 10),
      width: double.maxFinite,
//      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 5, right: 10),
            width: 30,
            height: 30,
            child: ClipOval(
              child:
                  CachedNetworkImage(
                    imageUrl: item.head,
                    fit: BoxFit.cover,
                    errorWidget:(c,a,b){
                      return SvgPicture.asset("images/replace_head.svg");
                    },
                    placeholder: (b,url){
                      return SvgPicture.asset("images/replace_head.svg");
                    },
                  )
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 5,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    baseText(item.name, 12, ALColors.ColorF4F3F8),
                    Container(
                      padding: EdgeInsets.only(left: 5,right: 5,top: 2,bottom: 2),
                      margin: EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.orange),
                      child:
                          baseText(item.filterName, 12, ALColors.ColorF4F3F8),
                    ),
                  ],
                ),
                Container(
                  height: 3,
                ),
                baseText(item.content, 15, ALColors.ColorFFFFFF),
              ],
            ),
          ),
          Container(
            width: 30,
            margin: EdgeInsets.only(left: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 10,
                ),
                GestureDetector(
                  onTap: likeClick,
                  child: Container(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      "images/icon_like.svg",
                      color: !item.like ? Colors.grey : Colors.red,
                    ),
                  ),
                ),
                baseText("${item.likeCount}", 13, ALColors.ColorFFFFFF)
              ],
            ),
          )
        ],
      ),
    );
  }
}
