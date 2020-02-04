/*
 * @author lsy
 * @date   2019-12-20
 **/
class AIBean {
  int status;
  String msg;
  Data data;

  AIBean({this.status, this.msg, this.data});

  AIBean.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  List<EyelidRight> eyelidRight;
  List<EyelidLeft> eyelidLeft;
  List<Nose> nose;
  List<Wrink> wrink;
  List<LipThickness> lipThickness;
  List<LipPeak> lipPeak;
  List<Pouch> pouch;
  List<Cheekbone> cheekbone;
  List<BrowShape> browShape;
  List<BrowDensity> browDensity;
  List<ChinShape> chinShape;
  List<EyeDistance> eyeDistance;
  List<LipShape> lipShape;
  List<LipRadian> lipRadian;
  List<EyeShapeRight> eyeShapeRight;
  List<EyeShapeLeft> eyeShapeLeft;
  List<double> eyeAngleRight;
  List<double> eyeAngleLeft;
  List<Wocan> wocan;
  List<EyebrowStyle> eyebrowStyle;
  List<EyebrowConcentration> eyebrowConcentration;
  List<EyebrowRough> eyebrowRough;
  List<EyePrintLeft> eyePrintLeft;
  List<EyePrintRight> eyePrintRight;
  List<double> eyeEyelidLeft;
  List<double> eyeEyelidRight;
  List<SwollenBags> swollenBags;
  List<CrowsFeetLeft> crowsFeetLeft;
  List<CrowsFeetRight> crowsFeetRight;
  List<double> eyeAngle;
  List<double> bigFace;
  List<double> chinRefraction;
  List<Leigou> leigou;
  List<Heiyanquan> heiyanquan;
  List<Faceshape> faceshape;

  Data(
      {this.eyelidRight,
        this.eyelidLeft,
        this.nose,
        this.wrink,
        this.lipThickness,
        this.lipPeak,
        this.pouch,
        this.cheekbone,
        this.browShape,
        this.browDensity,
        this.chinShape,
        this.eyeDistance,
        this.lipShape,
        this.lipRadian,
        this.eyeShapeRight,
        this.eyeShapeLeft,
        this.eyeAngleRight,
        this.eyeAngleLeft,
        this.wocan,
        this.eyebrowStyle,
        this.eyebrowConcentration,
        this.eyebrowRough,
        this.eyePrintLeft,
        this.eyePrintRight,
        this.eyeEyelidLeft,
        this.eyeEyelidRight,
        this.swollenBags,
        this.crowsFeetLeft,
        this.crowsFeetRight,
        this.eyeAngle,
        this.bigFace,
        this.chinRefraction,
        this.leigou,
        this.heiyanquan,
        this.faceshape});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['eyelid_right'] != null) {
      eyelidRight = new List<EyelidRight>();
      json['eyelid_right'].forEach((v) {
        eyelidRight.add(new EyelidRight.fromJson(v));
      });
    }
    if (json['eyelid_left'] != null) {
      eyelidLeft = new List<EyelidLeft>();
      json['eyelid_left'].forEach((v) {
        eyelidLeft.add(new EyelidLeft.fromJson(v));
      });
    }
    if (json['nose'] != null) {
      nose = new List<Nose>();
      json['nose'].forEach((v) {
        nose.add(new Nose.fromJson(v));
      });
    }
    if (json['wrink'] != null) {
      wrink = new List<Wrink>();
      json['wrink'].forEach((v) {
        wrink.add(new Wrink.fromJson(v));
      });
    }
    if (json['lip_thickness'] != null) {
      lipThickness = new List<LipThickness>();
      json['lip_thickness'].forEach((v) {
        lipThickness.add(new LipThickness.fromJson(v));
      });
    }
    if (json['lip_peak'] != null) {
      lipPeak = new List<LipPeak>();
      json['lip_peak'].forEach((v) {
        lipPeak.add(new LipPeak.fromJson(v));
      });
    }
    if (json['pouch'] != null) {
      pouch = new List<Pouch>();
      json['pouch'].forEach((v) {
        pouch.add(new Pouch.fromJson(v));
      });
    }
    if (json['cheekbone'] != null) {
      cheekbone = new List<Cheekbone>();
      json['cheekbone'].forEach((v) {
        cheekbone.add(new Cheekbone.fromJson(v));
      });
    }
    if (json['brow_shape'] != null) {
      browShape = new List<BrowShape>();
      json['brow_shape'].forEach((v) {
        browShape.add(new BrowShape.fromJson(v));
      });
    }
    if (json['brow_density'] != null) {
      browDensity = new List<BrowDensity>();
      json['brow_density'].forEach((v) {
        browDensity.add(new BrowDensity.fromJson(v));
      });
    }
    if (json['chin_shape'] != null) {
      chinShape = new List<ChinShape>();
      json['chin_shape'].forEach((v) {
        chinShape.add(new ChinShape.fromJson(v));
      });
    }
    if (json['eye_distance'] != null) {
      eyeDistance = new List<EyeDistance>();
      json['eye_distance'].forEach((v) {
        eyeDistance.add(new EyeDistance.fromJson(v));
      });
    }
    if (json['lip_shape'] != null) {
      lipShape = new List<LipShape>();
      json['lip_shape'].forEach((v) {
        lipShape.add(new LipShape.fromJson(v));
      });
    }
    if (json['lip_radian'] != null) {
      lipRadian = new List<LipRadian>();
      json['lip_radian'].forEach((v) {
        lipRadian.add(new LipRadian.fromJson(v));
      });
    }
    if (json['eye_shape_right'] != null) {
      eyeShapeRight = new List<EyeShapeRight>();
      json['eye_shape_right'].forEach((v) {
        eyeShapeRight.add(new EyeShapeRight.fromJson(v));
      });
    }
    if (json['eye_shape_left'] != null) {
      eyeShapeLeft = new List<EyeShapeLeft>();
      json['eye_shape_left'].forEach((v) {
        eyeShapeLeft.add(new EyeShapeLeft.fromJson(v));
      });
    }
    eyeAngleRight = json['eye_angle_right'].cast<double>();
    eyeAngleLeft = json['eye_angle_left'].cast<double>();
    if (json['wocan'] != null) {
      wocan = new List<Wocan>();
      json['wocan'].forEach((v) {
        wocan.add(new Wocan.fromJson(v));
      });
    }
    if (json['eyebrow_style'] != null) {
      eyebrowStyle = new List<EyebrowStyle>();
      json['eyebrow_style'].forEach((v) {
        eyebrowStyle.add(new EyebrowStyle.fromJson(v));
      });
    }
    if (json['eyebrow_concentration'] != null) {
      eyebrowConcentration = new List<EyebrowConcentration>();
      json['eyebrow_concentration'].forEach((v) {
        eyebrowConcentration.add(new EyebrowConcentration.fromJson(v));
      });
    }
    if (json['eyebrow_rough'] != null) {
      eyebrowRough = new List<EyebrowRough>();
      json['eyebrow_rough'].forEach((v) {
        eyebrowRough.add(new EyebrowRough.fromJson(v));
      });
    }
    if (json['eye_print_left'] != null) {
      eyePrintLeft = new List<EyePrintLeft>();
      json['eye_print_left'].forEach((v) {
        eyePrintLeft.add(new EyePrintLeft.fromJson(v));
      });
    }
    if (json['eye_print_right'] != null) {
      eyePrintRight = new List<EyePrintRight>();
      json['eye_print_right'].forEach((v) {
        eyePrintRight.add(new EyePrintRight.fromJson(v));
      });
    }
    eyeEyelidLeft = json['eye_eyelid_left'].cast<double>();
    eyeEyelidRight = json['eye_eyelid_right'].cast<double>();
    if (json['swollen_bags'] != null) {
      swollenBags = new List<SwollenBags>();
      json['swollen_bags'].forEach((v) {
        swollenBags.add(new SwollenBags.fromJson(v));
      });
    }
    if (json['crows_feet_left'] != null) {
      crowsFeetLeft = new List<CrowsFeetLeft>();
      json['crows_feet_left'].forEach((v) {
        crowsFeetLeft.add(new CrowsFeetLeft.fromJson(v));
      });
    }
    if (json['crows_feet_right'] != null) {
      crowsFeetRight = new List<CrowsFeetRight>();
      json['crows_feet_right'].forEach((v) {
        crowsFeetRight.add(new CrowsFeetRight.fromJson(v));
      });
    }
    eyeAngle = json['eye_angle'].cast<double>();
    bigFace = json['big_face'].cast<double>();
    chinRefraction = json['chin_refraction'].cast<double>();
    if (json['leigou'] != null) {
      leigou = new List<Leigou>();
      json['leigou'].forEach((v) {
        leigou.add(new Leigou.fromJson(v));
      });
    }
    if (json['heiyanquan'] != null) {
      heiyanquan = new List<Heiyanquan>();
      json['heiyanquan'].forEach((v) {
        heiyanquan.add(new Heiyanquan.fromJson(v));
      });
    }
    if (json['faceshape'] != null) {
      faceshape = new List<Faceshape>();
      json['faceshape'].forEach((v) {
        faceshape.add(new Faceshape.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.eyelidRight != null) {
      data['eyelid_right'] = this.eyelidRight.map((v) => v.toJson()).toList();
    }
    if (this.eyelidLeft != null) {
      data['eyelid_left'] = this.eyelidLeft.map((v) => v.toJson()).toList();
    }
    if (this.nose != null) {
      data['nose'] = this.nose.map((v) => v.toJson()).toList();
    }
    if (this.wrink != null) {
      data['wrink'] = this.wrink.map((v) => v.toJson()).toList();
    }
    if (this.lipThickness != null) {
      data['lip_thickness'] = this.lipThickness.map((v) => v.toJson()).toList();
    }
    if (this.lipPeak != null) {
      data['lip_peak'] = this.lipPeak.map((v) => v.toJson()).toList();
    }
    if (this.pouch != null) {
      data['pouch'] = this.pouch.map((v) => v.toJson()).toList();
    }
    if (this.cheekbone != null) {
      data['cheekbone'] = this.cheekbone.map((v) => v.toJson()).toList();
    }
    if (this.browShape != null) {
      data['brow_shape'] = this.browShape.map((v) => v.toJson()).toList();
    }
    if (this.browDensity != null) {
      data['brow_density'] = this.browDensity.map((v) => v.toJson()).toList();
    }
    if (this.chinShape != null) {
      data['chin_shape'] = this.chinShape.map((v) => v.toJson()).toList();
    }
    if (this.eyeDistance != null) {
      data['eye_distance'] = this.eyeDistance.map((v) => v.toJson()).toList();
    }
    if (this.lipShape != null) {
      data['lip_shape'] = this.lipShape.map((v) => v.toJson()).toList();
    }
    if (this.lipRadian != null) {
      data['lip_radian'] = this.lipRadian.map((v) => v.toJson()).toList();
    }
    if (this.eyeShapeRight != null) {
      data['eye_shape_right'] =
          this.eyeShapeRight.map((v) => v.toJson()).toList();
    }
    if (this.eyeShapeLeft != null) {
      data['eye_shape_left'] =
          this.eyeShapeLeft.map((v) => v.toJson()).toList();
    }
    data['eye_angle_right'] = this.eyeAngleRight;
    data['eye_angle_left'] = this.eyeAngleLeft;
    if (this.wocan != null) {
      data['wocan'] = this.wocan.map((v) => v.toJson()).toList();
    }
    if (this.eyebrowStyle != null) {
      data['eyebrow_style'] = this.eyebrowStyle.map((v) => v.toJson()).toList();
    }
    if (this.eyebrowConcentration != null) {
      data['eyebrow_concentration'] =
          this.eyebrowConcentration.map((v) => v.toJson()).toList();
    }
    if (this.eyebrowRough != null) {
      data['eyebrow_rough'] = this.eyebrowRough.map((v) => v.toJson()).toList();
    }
    if (this.eyePrintLeft != null) {
      data['eye_print_left'] =
          this.eyePrintLeft.map((v) => v.toJson()).toList();
    }
    if (this.eyePrintRight != null) {
      data['eye_print_right'] =
          this.eyePrintRight.map((v) => v.toJson()).toList();
    }
    data['eye_eyelid_left'] = this.eyeEyelidLeft;
    data['eye_eyelid_right'] = this.eyeEyelidRight;
    if (this.swollenBags != null) {
      data['swollen_bags'] = this.swollenBags.map((v) => v.toJson()).toList();
    }
    if (this.crowsFeetLeft != null) {
      data['crows_feet_left'] =
          this.crowsFeetLeft.map((v) => v.toJson()).toList();
    }
    if (this.crowsFeetRight != null) {
      data['crows_feet_right'] =
          this.crowsFeetRight.map((v) => v.toJson()).toList();
    }
    data['eye_angle'] = this.eyeAngle;
    data['big_face'] = this.bigFace;
    data['chin_refraction'] = this.chinRefraction;
    if (this.leigou != null) {
      data['leigou'] = this.leigou.map((v) => v.toJson()).toList();
    }
    if (this.heiyanquan != null) {
      data['heiyanquan'] = this.heiyanquan.map((v) => v.toJson()).toList();
    }
    if (this.faceshape != null) {
      data['faceshape'] = this.faceshape.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class EyelidRight {
  String type;
  double score;

  EyelidRight({this.type, this.score});

  EyelidRight.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}

class EyelidLeft {
  String type;
  double score;

  EyelidLeft({this.type, this.score});

  EyelidLeft.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}


class Nose {
  String type;
  double score;

  Nose({this.type, this.score});

  Nose.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class Wrink {
  String type;
  double score;

  Wrink({this.type, this.score});

  Wrink.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class LipThickness {
  String type;
  double score;

  LipThickness({this.type, this.score});

  LipThickness.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class Pouch {
  String type;
  double score;

  Pouch({this.type, this.score});

  Pouch.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}


class EyeShapeRight {
  String type;
  double score;

  EyeShapeRight({this.type, this.score});

  EyeShapeRight.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class EyeShapeLeft {
  String type;
  double score;

  EyeShapeLeft({this.type, this.score});

  EyeShapeLeft.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}





class Wocan {
  String type;
  double score;

  Wocan({this.type, this.score});

  Wocan.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}





class LipRadian {
  String type;
  double score;

  LipRadian({this.type, this.score});

  LipRadian.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}





class Cheekbone {
  String type;
  double score;

  Cheekbone({this.type, this.score});

  Cheekbone.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class BrowDensity {
  String type;
  double score;

  BrowDensity({this.type, this.score});

  BrowDensity.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class EyeDistance {
  String type;
  double score;

  EyeDistance({this.type, this.score});

  EyeDistance.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class Leigou {
  String type;
  double score;

  Leigou({this.type, this.score});

  Leigou.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}




class EyebrowRough {
  String type;
  double score;

  EyebrowRough({this.type, this.score});

  EyebrowRough.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class EyebrowStyle {
  String type;
  double score;

  EyebrowStyle({this.type, this.score});

  EyebrowStyle.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class EyebrowConcentration {
  String type;
  double score;

  EyebrowConcentration({this.type, this.score});

  EyebrowConcentration.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}




class Heiyanquan {
  String type;
  double score;

  Heiyanquan({this.type, this.score});

  Heiyanquan.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}




class SwollenBags {
  String type;
  double score;

  SwollenBags({this.type, this.score});

  SwollenBags.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



class ChinShape {
  String type;
  double score;

  ChinShape({this.type, this.score});

  ChinShape.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}




class EyePrintLeft {
  String type;
  double score;

  EyePrintLeft({this.type, this.score});

  EyePrintLeft.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}




class CrowsFeetRight {
  String type;
  double score;

  CrowsFeetRight({this.type, this.score});

  CrowsFeetRight.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}




class Faceshape {
  String type;
  double score;

  Faceshape({this.type, this.score});

  Faceshape.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}




class LipShape {
  String type;
  double score;

  LipShape({this.type, this.score});

  LipShape.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}




class LipPeak {
  String type;
  double score;

  LipPeak({this.type, this.score});

  LipPeak.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}





class BrowShape {
  String type;
  double score;

  BrowShape({this.type, this.score});

  BrowShape.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}




class CrowsFeetLeft {
  String type;
  double score;

  CrowsFeetLeft({this.type, this.score});

  CrowsFeetLeft.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}


class EyePrintRight {
  String type;
  double score;

  EyePrintRight({this.type, this.score});

  EyePrintRight.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['score'] = this.score;
    return data;
  }
}



















