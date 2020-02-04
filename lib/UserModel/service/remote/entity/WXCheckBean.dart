/*
 * @author lsy
 * @date   2020-01-17
 **/
class WXCheckBean {
  int errcode;
  String errmsg;

  WXCheckBean({this.errcode, this.errmsg});

  WXCheckBean.fromJson(Map<String, dynamic> json) {
    errcode = json['errcode'];
    errmsg = json['errmsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['errcode'] = this.errcode;
    data['errmsg'] = this.errmsg;
    return data;
  }
}

