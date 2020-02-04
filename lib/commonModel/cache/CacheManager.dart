/*
 * @author lsy
 * @date   2019-10-08
 **/

import 'package:gengmei_app_face/commonModel/cache/ShareCache.dart';

import 'MemoryCache.dart';

const MEMORY_CACHE = "MEMORY_CACHE";
const SHARE_CACHE = "SHARE_CACHE";

class CacheManager {
  MemoryCache _memoryCache;
  ShareCache _shareCache;

  static CacheManager _instance = CacheManager._();

  CacheManager._() {
    _memoryCache = new MemoryCache();
  }

  static CacheManager getInstance() {
    return _instance;
  }

  ICache get(String whichCache) {
    if (whichCache == MEMORY_CACHE) {
      return _memoryCache;
    }else if(whichCache==SHARE_CACHE){
      return _shareCache;
    }
  }
}

class ICache {
  dynamic get(String key) {}

  void save(String key, dynamic value) {}
}
