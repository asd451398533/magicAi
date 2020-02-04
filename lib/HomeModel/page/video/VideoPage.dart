import 'dart:io';

//import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:gengmei_app_face/HomeModel/page/video/VideoModel.dart';
import 'package:gengmei_app_face/commonModel/toast/toast.dart';
//import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  String url;

  VideoPage(this.url);

  @override
  State<StatefulWidget> createState() {
    return VideoAppState(url);
  }
}

class VideoAppState extends State<VideoPage> {
  bool _isPlaying = false;
  String url;
  bool isInit = true;
//  VideoPlayerController videoPlayerController;
  VideoModel _model;

  VideoAppState(this.url);

  @override
  void initState() {
    _model = new VideoModel();
    _model.init(url);
    super.initState();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
//    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.question_answer,
              color: Colors.black,
            ),
            onPressed: () {
              Toast.show(context, "这个视频位置在:${url}");
            },
          ),
        ],
        leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop()),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: _model.videoLive.stream,
        initialData: _model.videoLive.data,
        builder: (con, data) {
          if (data.data == null) {
            return CircularProgressIndicator();
          }
//          videoPlayerController = VideoPlayerController.file(File(data.data));
          return Center(
//            child:
//            new Chewie(
//              videoPlayerController,
//              autoPlay: !true,
//              aspectRatio: _model.ratio,
//              looping: true,
//              showControls: true,
//              // 占位图
//              placeholder: new Container(
//                color: Colors.grey,
//              ),
//
//              // 是否在 UI 构建的时候就加载视频
//              autoInitialize: true,
//
//              // 拖动条样式颜色
//              materialProgressColors: new ChewieProgressColors(
//                playedColor: Colors.red,
//                handleColor: Colors.blue,
//                backgroundColor: Colors.grey,
//                bufferedColor: Colors.lightGreen,
//              ),
//            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _model.execStarLong(context);
        },
        child: new Text("长视频"),
      ),
    );
  }
}
