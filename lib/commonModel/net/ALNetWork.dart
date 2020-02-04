import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';

class NetworkSuccess {
  NetworkSuccess({this.data});
  final Map data;
  Map get dataMap{
    if (this.data.runtimeType == Map) {
      return data;
    }else return null;
  }
}

class NetworkError {
  NetworkError({this.error});
  final Map error;
  int get errorCode{
    if (this.error.runtimeType == Map) {
      return error['errorCode'];
    }else return null;
  }
}

class ALURL {
  ALURL({this.api}) : assert(api != null);
  final String api;
  static final baseUrl = 'http://earth.igengmei.com';
  String get originUrl => (baseUrl + api);
}

class ALNetworkHeader {

  BaseOptions get options{
    BaseOptions option = BaseOptions();
    option.headers =this.header;
    return option;
  }

  Map<String, dynamic> get header{
    return {
      'Host':	'earth.igengmei.com',
      'Accept':	'*/*',
      'Cookie':	'_gm_token=fb20fe1550833249; sessionid=qntnckxv4n4nzrl49jmaesc5ylru92yt; _gtid=ae355f92310911e9905700163e0a7a995288',
      'User-Agent':	'GMAlpha/1.3.0 (iPhone; iOS 12.1.2; Scale/2.00)',
      'Accept-Language':	'en-CN;q=1, zh-Hans-CN;q=0.9',
      'Accept-Encoding':	'gzip, deflate',
      'Connection':	'keep-alive'
    };
  }

  Map<String, dynamic> get params {
    return {
      'platform': 'iPhone',
      'os_version':'12.1.2',
      'version':'1.3.0',
      'model':'iPhone%206s',
      'release':'0',
      'idfa':'119A3567-6C81-40EA-A3ED-A63F7DCAD86B',
      'idfv':'78BE2D94-7252-4C18-A816-2CEE6350B076',
      'device_id':'119A3567-6C81-40EA-A3ED-A63F7DCAD86B',
      'channel':'App%20Store',
      'app_name':'gengmeiios',
      'current_city_id':'worldwide',
      'lat':'0',
      'lng':'0',
      'is_WiFi':'(null)',
      'phone_id':'iPhone8'
    };
  }
}

// 管理任务
class ALNetworkTask {
  ALNetworkTask({this.serviceInstance,this.networkContext, this.response});
  final Dio serviceInstance;
  final ALNetwork networkContext;
  Response response;

  void cancle(String api) {
    // CancelToken
  }
}

typedef NetworkSuccessCallback = void Function(NetworkSuccess success);
typedef NetWorkErrorCallback = void Function(NetworkError error);
typedef ProgressCallback = void Function(int count, int total);

class ALNetwork {
  /** 
   * 任务映射表
   * 外部可以通过 ALNetwork.taskMap 获取
  */
  static Map<String, ALNetworkTask> taskMap = {};

  const ALNetwork(
    {this.success,
      this.error,
      this.progress,
      this.api,
      this.params,
      this.formData}) : assert(api != null);

  final NetworkSuccessCallback success;
  final NetWorkErrorCallback error;
  final ProgressCallback progress;
  final String api;
  final Map params;
  final FormData formData;
  ALURL get url => ALURL(api: this.api);

  ///post
  Future<void> post() async{
    ALNetworkTask task = _initNetworkEngin();
    task.response = await task.serviceInstance.post(this.url.originUrl, data: this.params);
    _handleNetworkService(task.response);
  }

  /**
   * FormData formData = new FormData.from({
    "name": "simon",
    "age": 25,
    });
   */
  Future<void> postFormData() async{
    ALNetworkTask task = _initNetworkEngin();
    task.response = await task.serviceInstance.post(this.url.originUrl, data: this.formData);
    _handleNetworkService(task.response);
  }
  
  ///get
  Future<void> excuteGet() async{
    ALNetworkTask task = _initNetworkEngin();
    task.response = await task.serviceInstance.get(this.url.originUrl, queryParameters: ALNetworkHeader().params);
    _handleNetworkService(task.response);
  }
  
  /**
   * FormData formData = new FormData.from({
    "name": "wendux",
    "age": 25,
    "file1": new UploadFileInfo(new File("./upload.txt"), "upload1.txt"),
    // upload with bytes (List<int>)
    "file2": new UploadFileInfo.fromBytes(
        utf8.encode("hello world"), "word.txt"),
    // Pass multiple files within an Array
    "files": [
      new UploadFileInfo(new File("./example/upload.txt"), "upload.txt"),
      new UploadFileInfo(new File("./example/upload.txt"), "upload.txt")
    ]
    });
   */
  Future<void> upload() async{
    ALNetworkTask task = _initNetworkEngin();
    task.response = await task.serviceInstance.post(this.url.originUrl, data: this.formData,onSendProgress: this.progress);
    _handleNetworkService(task.response);
  }

  ///download
  Future<void> download(String filePath) async{
    ALNetworkTask task = _initNetworkEngin();
    task.response = await task.serviceInstance.download(this.url.originUrl, filePath, onReceiveProgress: this.progress);
    _handleNetworkService(task.response);
  }

  ALNetworkTask _initNetworkEngin(){
    Response response;
    Dio dio = new Dio();
    dio.options = ALNetworkHeader().options;
    ALNetworkTask task = ALNetworkTask(
      serviceInstance:dio,
      response: response,
      networkContext: this
    );
    //handle task
    taskMap[this.api] = task;
    return task;
  }

  void _handleNetworkService(Response response) {
    var data = jsonDecode(response.toString());
    if(data.runtimeType ==Map && response.statusCode == 200){
      if (data['error'] == 0){
        this.success(NetworkSuccess(data: data));
      }else{
        this.error(NetworkError(error: data));  
      }
    }else{
      this.error(NetworkError(error: data));
    }
    //remove task
    taskMap.remove(this.api);
  }
}