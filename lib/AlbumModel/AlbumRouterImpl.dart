/*
 * @author lsy
 * @date   2019-09-09
 **/

import 'package:flutter/src/widgets/framework.dart';
import 'package:gengmei_app_face/AlbumModel/AlbumRouter.dart';
import 'package:gengmei_app_face/AlbumModel/page/album/AlbumPage.dart';

class AlbumRouterImpl implements AlbumRouter {
  @override
  Widget getAlbumPage(String provider, bool showCamera, int bigSelectSize,
      List<String> selectedImages, bool fromNative, String fromPage,
      {int maxVideoCount = 0, videoSelectPath , iosPushedPage ,noVideoHint=null,needAiCamera=false}) {
    return AlbumPage(provider, showCamera, bigSelectSize, selectedImages,
        fromNative, maxVideoCount, videoSelectPath, fromPage,iosPushedPage,noVideoHint,needAiCamera);
  }
}
