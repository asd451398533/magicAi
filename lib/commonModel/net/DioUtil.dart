import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gengmei_app_face/commonModel/cache/CacheManager.dart';
import 'package:gengmei_app_face/commonModel/net/Api.dart';

const bool inProduction = const bool.fromEnvironment("dart.vm.product");

///Http配置.
class HttpConfig {
  /// constructor.
  HttpConfig({
    this.status,
    this.code,
    this.msg,
    this.data,
    this.options,
    this.pem,
    this.pKCSPath,
    this.pKCSPwd,
    this.nativeCookie,
  });

  /// BaseResp [String status]字段 key, 默认：status.
  String status;

  /// BaseResp [int code]字段 key, 默认：errorCode.
  String code;

  /// BaseResp [String msg]字段 key, 默认：errorMsg.
  String msg;

  /// BaseResp [T data]字段 key, 默认：data.
  String data;

  /// Options.
  BaseOptions options;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PEM证书内容.
  String pem;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PKCS12 证书路径.
  String pKCSPath;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PKCS12 证书密码.
  String pKCSPwd;

  //缓存
  Map nativeCookie;
}

/// 单例 DioUtil.
/// debug模式下可以打印请求日志. DioUtil.openDebug().
/// dio详细使用请查看dio官网(https://github.com/flutterchina/dio).
class DioUtil {
  static final DioUtil _instance = DioUtil._init();
  static Dio _dio;

  /// BaseResp [String status]字段 key, 默认：status.
  String _statusKey = "status";

  /// BaseResp [int code]字段 key, 默认：error = 0 代表成功.
  String _codeKey = "error";

  /// BaseResp [String msg]字段 key, 默认：errorMsg.
  String _msgKey = "message";

  /// BaseResp [T data]字段 key, 默认：data.
  String _dataKey = "data";

  /// BaseResp [T data]字段 key, 默认：extra.
  String _extraKey = 'extra';

  // BaseResp [T data]字段 key, 默认：user_type.
  String _userType = 'user_type';

  /// Options.
  static BaseOptions _options = getDefOptions();

  /// PEM证书内容.
  String _pem;

  /// PKCS12 证书路径.
  String _pKCSPath;

  /// PKCS12 证书密码.
  String _pKCSPwd;

  String _proxy = '172.30.9.117:8888';

  static Map<String, dynamic> addHeadMap;

  /// 是否是debug模式.
  static bool _isDebug = !inProduction;

  static DioUtil getInstance() {
    return _instance;
  }

  factory DioUtil() {
    return _instance;
  }

  static var interceptor = InterceptorsWrapper(onRequest: (opt) {

  }, onResponse: (response) {

  }, onError: (e) {
    print("网络错误  $e message ${e.message}");
  });

  DioUtil._init() {
    _dio = new Dio(_options);
    _dio.interceptors.add(interceptor);
  }


  /// check Options.
  Options _checkOptions(method, options) {
    if (options == null) {
      options = new Options();
    }
    options.method = method;
    return options;
  }

  /// merge Option.
  void _mergeOption(BaseOptions opt) {
    _options.method = opt.method ?? _options.method;
    _options.headers = (new Map.from(_options.headers))..addAll(opt.headers);
    _options.baseUrl = opt.baseUrl ?? _options.baseUrl;
    _options.connectTimeout = opt.connectTimeout ?? _options.connectTimeout;
    _options.receiveTimeout = opt.receiveTimeout ?? _options.receiveTimeout;
    _options.responseType = opt.responseType ?? _options.responseType;
    _options.extra = (new Map.from(_options.extra))..addAll(opt.extra);
    _options.contentType = opt.contentType ?? _options.contentType;
    _options.validateStatus = opt.validateStatus ?? _options.validateStatus;
    _options.followRedirects = opt.followRedirects ?? _options.followRedirects;
  }

  void _mergeNativeCookie(HttpConfig config) {
    //合并native cookie
    if (config.nativeCookie == null) {
      return;
    }
    if (_options.headers == null) {
      _options.headers = Map();
    }
    Map<String, dynamic> headers = _options.headers;
    headers['Cookie'] = config.nativeCookie['Cookie'];
    _options.headers = headers;

    print('cookie---------');
    print(_options.headers);
  }

  void setCookie(String cookie) {
    if (_options.headers == null) {
      _options.headers = Map();
    }
    Map<String, dynamic> headers = _options.headers;
    headers['Cookie'] = cookie;
    _options.headers = headers;

    print('cookie---------');
    print(_options.headers);
  }

  /// print Http Log.
  void _printHttpLog(Response response) {
    if (!_isDebug) {
      return;
    }
    try {
      print("----------------Http Log----------------" +
          "\n[statusCode]:   " +
          response.statusCode.toString() +
          "\n[request   ]:   " +
          _getOptionsStr(response.request));
      _printDataStr("reqdata ", response.request.data);
      _printDataStr("response", response.data);
    } catch (ex) {
      print("Http Log" + " error......");
    }
  }

  /// get Options Str.
  String _getOptionsStr(Options request) {
    return "method: " + request.method;
  }

  /// print Data Str.
  void _printDataStr(String tag, Object value) {
    String da = value.toString();
    while (da.isNotEmpty) {
      if (da.length > 512) {
        print("[$tag  ]:   " + da.substring(0, 512));
        da = da.substring(512, da.length);
      } else {
        print("[$tag  ]:   " + da);
        da = "";
      }
    }
  }

  /// get dio.
  Dio getDio() {
    return _dio;
  }

  /// create new dio.
  static Dio createNewDio([Options options]) {
    Dio dio = new Dio();
    return dio;
  }

  /// get Def Options.
  static BaseOptions getDefOptions() {
    BaseOptions options = BaseOptions();
    options.connectTimeout = 10 * 1000;
    options.receiveTimeout = 20 * 1000;
//    options.contentType = ContentType.parse('application/x-www-form-urlencoded');
//    options.contentType = ContentType.json;
//    options.responseType = ResponseType.plain;
    options.baseUrl = "https://backend.igengmei.com/";
    Map<String, dynamic> headers = Map<String, dynamic>();
    headers['Accept'] = 'application/json';
    headers['version'] = '1.0.0';
    options.headers = headers;
    return options;
  }
}
