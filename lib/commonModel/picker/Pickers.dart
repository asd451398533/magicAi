import 'package:flutter/material.dart';

showPicker(BuildContext context,int downPos,VoidCallback photo,VoidCallback album){
  var sheet = showModalBottomSheet(
      context: context,
      builder: (build) {
        return new Container(
            height: 150.0,
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Container(
                  height: 25,
                  width: double.infinity,
                  color: Colors.black54,
                ),
                Container(
                  height: 150,
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.fromLTRB(36, 30, 36, 0),
                        width: double.maxFinite,
                        height: 39,
                        child: Card(
                          elevation: 3,
                          child: OutlineButton(
                            borderSide:new BorderSide(color: Colors.white),
                            onPressed: photo,
                            child: Center(
                              child: Text("相机"),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(36, 20, 36, 0),
                        width: double.maxFinite,
                        height: 39,
                        child: Card(
                          elevation: 3,
                          child: OutlineButton(
                            borderSide:new BorderSide(color: Colors.white),
                            onPressed: album,
                            child: Center(
                              child: Text("相册"),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                ),
              ],
            ));
      });
  return sheet;
}