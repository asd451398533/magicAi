/*
 * @author lsy
 * @date   2020-01-17
 **/
class WXUserBean {
  int errcode;
  String errmsg;
  String openid;
  String nickname;
  int sex;
  String language;
  String city;
  String province;
  String country;
  String headimgurl;
  List<String> privilege;
  String unionid;

  WXUserBean(
      {this.openid,
        this.nickname,
        this.sex,
        this.language,
        this.city,
        this.province,
        this.country,
        this.headimgurl,
        this.privilege,
        this.unionid});

  WXUserBean.fromJson(Map<String, dynamic> json) {
    errcode = json['errcode'];
    errmsg = json['errmsg'];
    openid = json['openid'];
    nickname = json['nickname'];
    sex = json['sex'];
    language = json['language'];
    city = json['city'];
    province = json['province'];
    country = json['country'];
    headimgurl = json['headimgurl'];
    privilege = json['privilege'].cast<String>();
    unionid = json['unionid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['openid'] = this.openid;
    data['nickname'] = this.nickname;
    data['sex'] = this.sex;
    data['language'] = this.language;
    data['city'] = this.city;
    data['province'] = this.province;
    data['country'] = this.country;
    data['headimgurl'] = this.headimgurl;
    data['privilege'] = this.privilege;
    data['unionid'] = this.unionid;
    return data;
  }
}

