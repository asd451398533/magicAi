/*
 * @author lsy
 * @date   2019-10-08
 **/

import 'CacheManager.dart';

class MemoryCache implements ICache {
  Map<String, dynamic> _cacheMap = new Map();

  @override
  get(String key) {
    return _cacheMap[key];
  }

  @override
  void save(String key, value) {
    _cacheMap.putIfAbsent(key, () => value);
  }
}
