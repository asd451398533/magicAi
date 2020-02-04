// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RouterCenterGenerator
// **************************************************************************

//AiImpl is resign : true
//HomeRouterImpl is resign : true
//HelpRouterImpl is resign : true
//AlbumRouterImpl is resign : true
//UserRouterImpl is resign : true

import "package:gengmei_app_face/AiModel/AiImpl.dart";
import "package:gengmei_app_face/AiModel/AiRouter.dart";
import "package:gengmei_app_face/HomeModel/HomeRouterImpl.dart";
import "package:gengmei_app_face/HomeModel/HomeRouter.dart";
import "package:gengmei_app_face/HelpModel/HelpRouterImpl.dart";
import "package:gengmei_app_face/HelpModel/HelpRouter.dart";
import "package:gengmei_app_face/AlbumModel/AlbumRouterImpl.dart";
import "package:gengmei_app_face/AlbumModel/AlbumRouter.dart";
import "package:gengmei_app_face/UserModel/UserRouterImpl.dart";
import "package:gengmei_app_face/UserModel/UserRouter.dart";

import "package:flutter_common/Annotations/RouterBaser.dart";

class RouterCenterImpl {
  Map<String, RouterBaser> map;

  factory RouterCenterImpl() => _sharedInstance();

  static RouterCenterImpl _instance;

  RouterCenterImpl._() {
    if (map == null) {
      map = new Map();
      init();
    } else {
      throw Exception("too many RouterCenter instance!!!  fix it ");
    }
  }

  static RouterCenterImpl _sharedInstance() {
    if (_instance == null) {
      _instance = RouterCenterImpl._();
    }
    return _instance;
  }

  void init() {
    map.putIfAbsent("AiRouter", () => AiImpl());
    map.putIfAbsent("HomeRouter", () => HomeRouterImpl());
    map.putIfAbsent("HelpRouter", () => HelpRouterImpl());
    map.putIfAbsent("albumModel", () => AlbumRouterImpl());
    map.putIfAbsent("UserRouter", () => UserRouterImpl());
  }

  RouterBaser getModel(String modelName) {
    return map[modelName];
  }

  AiRouter findAiRouter() {
    if (map["AiRouter"] == null) {
      return null;
    }
    return map["AiRouter"] as AiRouter;
  }

  HomeRouter findHomeRouter() {
    if (map["HomeRouter"] == null) {
      return null;
    }
    return map["HomeRouter"] as HomeRouter;
  }

  HelpRouter findHelpRouter() {
    if (map["HelpRouter"] == null) {
      return null;
    }
    return map["HelpRouter"] as HelpRouter;
  }

  AlbumRouter findAlbumRouter() {
    if (map["albumModel"] == null) {
      return null;
    }
    return map["albumModel"] as AlbumRouter;
  }

  UserRouter findUserRouter() {
    if (map["UserRouter"] == null) {
      return null;
    }
    return map["UserRouter"] as UserRouter;
  }
}
