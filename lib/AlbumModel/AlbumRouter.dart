/*
 * @author lsy
 * @date   2019-09-09
 **/

import 'package:flutter/material.dart';
import 'package:flutter_common/Annotations/RouterBaser.dart';
import 'package:flutter_common/Annotations/anno/Router.dart';
import 'package:gengmei_app_face/AlbumModel/AlbumRouterImpl.dart';

@Router("albumModel", AlbumRouterImpl, true)
abstract class AlbumRouter implements RouterBaser {
  Widget getAlbumPage(String provider, bool showCamera, int bigSelectImage,
      List<String> selectedImages, bool fromNative, String fromPage,
      {int maxVideoCount = 0, videoSelectPath = null, iosPushedPage = null
      ,noVideoHint=null,needAiCamera=false});
}
