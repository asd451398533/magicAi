/*
 * @author lsy
 * @date   2020-01-02
 **/
class LandMarkBean {
  int timeUsed;
  List<Faces> faces;
  String imageId;
  String requestId;
  int faceNum;

  LandMarkBean(
      {this.timeUsed, this.faces, this.imageId, this.requestId, this.faceNum});

  LandMarkBean.fromJson(Map<String, dynamic> json) {
    timeUsed = json['time_used'];
    if (json['faces'] != null) {
      faces = new List<Faces>();
      json['faces'].forEach((v) {
        faces.add(new Faces.fromJson(v));
      });
    }
    imageId = json['image_id'];
    requestId = json['request_id'];
    faceNum = json['face_num'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time_used'] = this.timeUsed;
    if (this.faces != null) {
      data['faces'] = this.faces.map((v) => v.toJson()).toList();
    }
    data['image_id'] = this.imageId;
    data['request_id'] = this.requestId;
    data['face_num'] = this.faceNum;
    return data;
  }
}

class Faces {
  Landmark landmark;
  Attributes attributes;
  FaceRectangle faceRectangle;
  String faceToken;

  Faces({this.landmark, this.attributes, this.faceRectangle, this.faceToken});

  Faces.fromJson(Map<String, dynamic> json) {
    landmark = json['landmark'] != null
        ? new Landmark.fromJson(json['landmark'])
        : null;
    attributes = json['attributes'] != null
        ? new Attributes.fromJson(json['attributes'])
        : null;
    faceRectangle = json['face_rectangle'] != null
        ? new FaceRectangle.fromJson(json['face_rectangle'])
        : null;
    faceToken = json['face_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.landmark != null) {
      data['landmark'] = this.landmark.toJson();
    }
    if (this.attributes != null) {
      data['attributes'] = this.attributes.toJson();
    }
    if (this.faceRectangle != null) {
      data['face_rectangle'] = this.faceRectangle.toJson();
    }
    data['face_token'] = this.faceToken;
    return data;
  }
}

class Landmark {
  ContourChin contourChin;
  ContourChin leftEyeUpperLeftQuarter;
  ContourChin mouthLowerLipRightContour1;
  ContourChin leftEyeBottom;
  ContourChin mouthLowerLipRightContour2;
  ContourChin contourLeft7;
  ContourChin contourLeft6;
  ContourChin contourLeft5;
  ContourChin contourLeft4;
  ContourChin contourLeft3;
  ContourChin contourLeft2;
  ContourChin contourLeft1;
  ContourChin leftEyeLowerLeftQuarter;
  ContourChin contourRight1;
  ContourChin contourRight3;
  ContourChin contourRight2;
  ContourChin contourRight5;
  ContourChin contourRight4;
  ContourChin contourRight7;
  ContourChin leftEyebrowLeftCorner;
  ContourChin rightEyeRightCorner;
  ContourChin noseBridge1;
  ContourChin noseBridge3;
  ContourChin noseBridge2;
  ContourChin rightEyebrowUpperLeftCorner;
  ContourChin mouthUpperLipRightContour4;
  ContourChin mouthUpperLipRightContour1;
  ContourChin rightEyeLeftCorner;
  ContourChin leftEyebrowUpperRightCorner;
  ContourChin leftEyebrowUpperMiddle;
  ContourChin mouthLowerLipRightContour3;
  ContourChin noseLeftContour3;
  ContourChin mouthLowerLipBottom;
  ContourChin mouthUpperLipRightContour2;
  ContourChin leftEyeTop;
  ContourChin noseLeftContour1;
  ContourChin mouthUpperLipBottom;
  ContourChin mouthUpperLipLeftContour2;
  ContourChin mouthUpperLipTop;
  ContourChin mouthUpperLipLeftContour1;
  ContourChin mouthUpperLipLeftContour4;
  ContourChin rightEyeTop;
  ContourChin mouthUpperLipRightContour3;
  ContourChin rightEyeBottom;
  ContourChin rightEyebrowLowerLeftCorner;
  ContourChin mouthLeftCorner;
  ContourChin noseMiddleContour;
  ContourChin rightEyeLowerRightQuarter;
  ContourChin rightEyebrowLowerRightQuarter;
  ContourChin contourRight9;
  ContourChin mouthRightCorner;
  ContourChin rightEyeLowerLeftQuarter;
  ContourChin rightEyeCenter;
  ContourChin leftEyeUpperRightQuarter;
  ContourChin rightEyebrowLowerLeftQuarter;
  ContourChin leftEyePupil;
  ContourChin contourRight8;
  ContourChin contourLeft13;
  ContourChin leftEyebrowLowerRightQuarter;
  ContourChin leftEyeRightCorner;
  ContourChin leftEyebrowLowerRightCorner;
  ContourChin mouthUpperLipLeftContour3;
  ContourChin leftEyebrowLowerLeftQuarter;
  ContourChin mouthLowerLipLeftContour1;
  ContourChin mouthLowerLipLeftContour3;
  ContourChin mouthLowerLipLeftContour2;
  ContourChin contourLeft9;
  ContourChin leftEyeLowerRightQuarter;
  ContourChin contourRight6;
  ContourChin noseTip;
  ContourChin rightEyebrowUpperMiddle;
  ContourChin rightEyebrowLowerMiddle;
  ContourChin leftEyeCenter;
  ContourChin rightEyebrowUpperLeftQuarter;
  ContourChin rightEyebrowRightCorner;
  ContourChin rightEyebrowUpperRightQuarter;
  ContourChin contourLeft16;
  ContourChin contourLeft15;
  ContourChin contourLeft14;
  ContourChin leftEyebrowUpperRightQuarter;
  ContourChin contourLeft12;
  ContourChin contourLeft11;
  ContourChin contourLeft10;
  ContourChin leftEyebrowLowerMiddle;
  ContourChin leftEyebrowUpperLeftQuarter;
  ContourChin rightEyeUpperRightQuarter;
  ContourChin noseRightContour4;
  ContourChin noseRightContour5;
  ContourChin noseLeftContour4;
  ContourChin noseLeftContour5;
  ContourChin noseLeftContour2;
  ContourChin noseRightContour1;
  ContourChin noseRightContour2;
  ContourChin noseRightContour3;
  ContourChin leftEyeLeftCorner;
  ContourChin contourRight15;
  ContourChin contourRight14;
  ContourChin contourRight16;
  ContourChin contourRight11;
  ContourChin contourRight10;
  ContourChin contourRight13;
  ContourChin contourRight12;
  ContourChin contourLeft8;
  ContourChin mouthLowerLipTop;
  ContourChin rightEyeUpperLeftQuarter;
  ContourChin rightEyePupil;

  Landmark(
      {this.contourChin,
        this.leftEyeUpperLeftQuarter,
        this.mouthLowerLipRightContour1,
        this.leftEyeBottom,
        this.mouthLowerLipRightContour2,
        this.contourLeft7,
        this.contourLeft6,
        this.contourLeft5,
        this.contourLeft4,
        this.contourLeft3,
        this.contourLeft2,
        this.contourLeft1,
        this.leftEyeLowerLeftQuarter,
        this.contourRight1,
        this.contourRight3,
        this.contourRight2,
        this.contourRight5,
        this.contourRight4,
        this.contourRight7,
        this.leftEyebrowLeftCorner,
        this.rightEyeRightCorner,
        this.noseBridge1,
        this.noseBridge3,
        this.noseBridge2,
        this.rightEyebrowUpperLeftCorner,
        this.mouthUpperLipRightContour4,
        this.mouthUpperLipRightContour1,
        this.rightEyeLeftCorner,
        this.leftEyebrowUpperRightCorner,
        this.leftEyebrowUpperMiddle,
        this.mouthLowerLipRightContour3,
        this.noseLeftContour3,
        this.mouthLowerLipBottom,
        this.mouthUpperLipRightContour2,
        this.leftEyeTop,
        this.noseLeftContour1,
        this.mouthUpperLipBottom,
        this.mouthUpperLipLeftContour2,
        this.mouthUpperLipTop,
        this.mouthUpperLipLeftContour1,
        this.mouthUpperLipLeftContour4,
        this.rightEyeTop,
        this.mouthUpperLipRightContour3,
        this.rightEyeBottom,
        this.rightEyebrowLowerLeftCorner,
        this.mouthLeftCorner,
        this.noseMiddleContour,
        this.rightEyeLowerRightQuarter,
        this.rightEyebrowLowerRightQuarter,
        this.contourRight9,
        this.mouthRightCorner,
        this.rightEyeLowerLeftQuarter,
        this.rightEyeCenter,
        this.leftEyeUpperRightQuarter,
        this.rightEyebrowLowerLeftQuarter,
        this.leftEyePupil,
        this.contourRight8,
        this.contourLeft13,
        this.leftEyebrowLowerRightQuarter,
        this.leftEyeRightCorner,
        this.leftEyebrowLowerRightCorner,
        this.mouthUpperLipLeftContour3,
        this.leftEyebrowLowerLeftQuarter,
        this.mouthLowerLipLeftContour1,
        this.mouthLowerLipLeftContour3,
        this.mouthLowerLipLeftContour2,
        this.contourLeft9,
        this.leftEyeLowerRightQuarter,
        this.contourRight6,
        this.noseTip,
        this.rightEyebrowUpperMiddle,
        this.rightEyebrowLowerMiddle,
        this.leftEyeCenter,
        this.rightEyebrowUpperLeftQuarter,
        this.rightEyebrowRightCorner,
        this.rightEyebrowUpperRightQuarter,
        this.contourLeft16,
        this.contourLeft15,
        this.contourLeft14,
        this.leftEyebrowUpperRightQuarter,
        this.contourLeft12,
        this.contourLeft11,
        this.contourLeft10,
        this.leftEyebrowLowerMiddle,
        this.leftEyebrowUpperLeftQuarter,
        this.rightEyeUpperRightQuarter,
        this.noseRightContour4,
        this.noseRightContour5,
        this.noseLeftContour4,
        this.noseLeftContour5,
        this.noseLeftContour2,
        this.noseRightContour1,
        this.noseRightContour2,
        this.noseRightContour3,
        this.leftEyeLeftCorner,
        this.contourRight15,
        this.contourRight14,
        this.contourRight16,
        this.contourRight11,
        this.contourRight10,
        this.contourRight13,
        this.contourRight12,
        this.contourLeft8,
        this.mouthLowerLipTop,
        this.rightEyeUpperLeftQuarter,
        this.rightEyePupil});

  Landmark.fromJson(Map<String, dynamic> json) {
    contourChin = json['contour_chin'] != null
        ? new ContourChin.fromJson(json['contour_chin'])
        : null;
    leftEyeUpperLeftQuarter = json['left_eye_upper_left_quarter'] != null
        ? new ContourChin.fromJson(json['left_eye_upper_left_quarter'])
        : null;
    mouthLowerLipRightContour1 = json['mouth_lower_lip_right_contour1'] != null
        ? new ContourChin.fromJson(json['mouth_lower_lip_right_contour1'])
        : null;
    leftEyeBottom = json['left_eye_bottom'] != null
        ? new ContourChin.fromJson(json['left_eye_bottom'])
        : null;
    mouthLowerLipRightContour2 = json['mouth_lower_lip_right_contour2'] != null
        ? new ContourChin.fromJson(json['mouth_lower_lip_right_contour2'])
        : null;
    contourLeft7 = json['contour_left7'] != null
        ? new ContourChin.fromJson(json['contour_left7'])
        : null;
    contourLeft6 = json['contour_left6'] != null
        ? new ContourChin.fromJson(json['contour_left6'])
        : null;
    contourLeft5 = json['contour_left5'] != null
        ? new ContourChin.fromJson(json['contour_left5'])
        : null;
    contourLeft4 = json['contour_left4'] != null
        ? new ContourChin.fromJson(json['contour_left4'])
        : null;
    contourLeft3 = json['contour_left3'] != null
        ? new ContourChin.fromJson(json['contour_left3'])
        : null;
    contourLeft2 = json['contour_left2'] != null
        ? new ContourChin.fromJson(json['contour_left2'])
        : null;
    contourLeft1 = json['contour_left1'] != null
        ? new ContourChin.fromJson(json['contour_left1'])
        : null;
    leftEyeLowerLeftQuarter = json['left_eye_lower_left_quarter'] != null
        ? new ContourChin.fromJson(json['left_eye_lower_left_quarter'])
        : null;
    contourRight1 = json['contour_right1'] != null
        ? new ContourChin.fromJson(json['contour_right1'])
        : null;
    contourRight3 = json['contour_right3'] != null
        ? new ContourChin.fromJson(json['contour_right3'])
        : null;
    contourRight2 = json['contour_right2'] != null
        ? new ContourChin.fromJson(json['contour_right2'])
        : null;
    contourRight5 = json['contour_right5'] != null
        ? new ContourChin.fromJson(json['contour_right5'])
        : null;
    contourRight4 = json['contour_right4'] != null
        ? new ContourChin.fromJson(json['contour_right4'])
        : null;
    contourRight7 = json['contour_right7'] != null
        ? new ContourChin.fromJson(json['contour_right7'])
        : null;
    leftEyebrowLeftCorner = json['left_eyebrow_left_corner'] != null
        ? new ContourChin.fromJson(json['left_eyebrow_left_corner'])
        : null;
    rightEyeRightCorner = json['right_eye_right_corner'] != null
        ? new ContourChin.fromJson(json['right_eye_right_corner'])
        : null;
    noseBridge1 = json['nose_bridge1'] != null
        ? new ContourChin.fromJson(json['nose_bridge1'])
        : null;
    noseBridge3 = json['nose_bridge3'] != null
        ? new ContourChin.fromJson(json['nose_bridge3'])
        : null;
    noseBridge2 = json['nose_bridge2'] != null
        ? new ContourChin.fromJson(json['nose_bridge2'])
        : null;
    rightEyebrowUpperLeftCorner =
    json['right_eyebrow_upper_left_corner'] != null
        ? new ContourChin.fromJson(json['right_eyebrow_upper_left_corner'])
        : null;
    mouthUpperLipRightContour4 = json['mouth_upper_lip_right_contour4'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_right_contour4'])
        : null;
    mouthUpperLipRightContour1 = json['mouth_upper_lip_right_contour1'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_right_contour1'])
        : null;
    rightEyeLeftCorner = json['right_eye_left_corner'] != null
        ? new ContourChin.fromJson(json['right_eye_left_corner'])
        : null;
    leftEyebrowUpperRightCorner =
    json['left_eyebrow_upper_right_corner'] != null
        ? new ContourChin.fromJson(json['left_eyebrow_upper_right_corner'])
        : null;
    leftEyebrowUpperMiddle = json['left_eyebrow_upper_middle'] != null
        ? new ContourChin.fromJson(json['left_eyebrow_upper_middle'])
        : null;
    mouthLowerLipRightContour3 = json['mouth_lower_lip_right_contour3'] != null
        ? new ContourChin.fromJson(json['mouth_lower_lip_right_contour3'])
        : null;
    noseLeftContour3 = json['nose_left_contour3'] != null
        ? new ContourChin.fromJson(json['nose_left_contour3'])
        : null;
    mouthLowerLipBottom = json['mouth_lower_lip_bottom'] != null
        ? new ContourChin.fromJson(json['mouth_lower_lip_bottom'])
        : null;
    mouthUpperLipRightContour2 = json['mouth_upper_lip_right_contour2'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_right_contour2'])
        : null;
    leftEyeTop = json['left_eye_top'] != null
        ? new ContourChin.fromJson(json['left_eye_top'])
        : null;
    noseLeftContour1 = json['nose_left_contour1'] != null
        ? new ContourChin.fromJson(json['nose_left_contour1'])
        : null;
    mouthUpperLipBottom = json['mouth_upper_lip_bottom'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_bottom'])
        : null;
    mouthUpperLipLeftContour2 = json['mouth_upper_lip_left_contour2'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_left_contour2'])
        : null;
    mouthUpperLipTop = json['mouth_upper_lip_top'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_top'])
        : null;
    mouthUpperLipLeftContour1 = json['mouth_upper_lip_left_contour1'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_left_contour1'])
        : null;
    mouthUpperLipLeftContour4 = json['mouth_upper_lip_left_contour4'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_left_contour4'])
        : null;
    rightEyeTop = json['right_eye_top'] != null
        ? new ContourChin.fromJson(json['right_eye_top'])
        : null;
    mouthUpperLipRightContour3 = json['mouth_upper_lip_right_contour3'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_right_contour3'])
        : null;
    rightEyeBottom = json['right_eye_bottom'] != null
        ? new ContourChin.fromJson(json['right_eye_bottom'])
        : null;
    rightEyebrowLowerLeftCorner =
    json['right_eyebrow_lower_left_corner'] != null
        ? new ContourChin.fromJson(json['right_eyebrow_lower_left_corner'])
        : null;
    mouthLeftCorner = json['mouth_left_corner'] != null
        ? new ContourChin.fromJson(json['mouth_left_corner'])
        : null;
    noseMiddleContour = json['nose_middle_contour'] != null
        ? new ContourChin.fromJson(json['nose_middle_contour'])
        : null;
    rightEyeLowerRightQuarter = json['right_eye_lower_right_quarter'] != null
        ? new ContourChin.fromJson(json['right_eye_lower_right_quarter'])
        : null;
    rightEyebrowLowerRightQuarter = json['right_eyebrow_lower_right_quarter'] !=
        null
        ? new ContourChin.fromJson(json['right_eyebrow_lower_right_quarter'])
        : null;
    contourRight9 = json['contour_right9'] != null
        ? new ContourChin.fromJson(json['contour_right9'])
        : null;
    mouthRightCorner = json['mouth_right_corner'] != null
        ? new ContourChin.fromJson(json['mouth_right_corner'])
        : null;
    rightEyeLowerLeftQuarter = json['right_eye_lower_left_quarter'] != null
        ? new ContourChin.fromJson(json['right_eye_lower_left_quarter'])
        : null;
    rightEyeCenter = json['right_eye_center'] != null
        ? new ContourChin.fromJson(json['right_eye_center'])
        : null;
    leftEyeUpperRightQuarter = json['left_eye_upper_right_quarter'] != null
        ? new ContourChin.fromJson(json['left_eye_upper_right_quarter'])
        : null;
    rightEyebrowLowerLeftQuarter =
    json['right_eyebrow_lower_left_quarter'] != null
        ? new ContourChin.fromJson(json['right_eyebrow_lower_left_quarter'])
        : null;
    leftEyePupil = json['left_eye_pupil'] != null
        ? new ContourChin.fromJson(json['left_eye_pupil'])
        : null;
    contourRight8 = json['contour_right8'] != null
        ? new ContourChin.fromJson(json['contour_right8'])
        : null;
    contourLeft13 = json['contour_left13'] != null
        ? new ContourChin.fromJson(json['contour_left13'])
        : null;
    leftEyebrowLowerRightQuarter =
    json['left_eyebrow_lower_right_quarter'] != null
        ? new ContourChin.fromJson(json['left_eyebrow_lower_right_quarter'])
        : null;
    leftEyeRightCorner = json['left_eye_right_corner'] != null
        ? new ContourChin.fromJson(json['left_eye_right_corner'])
        : null;
    leftEyebrowLowerRightCorner =
    json['left_eyebrow_lower_right_corner'] != null
        ? new ContourChin.fromJson(json['left_eyebrow_lower_right_corner'])
        : null;
    mouthUpperLipLeftContour3 = json['mouth_upper_lip_left_contour3'] != null
        ? new ContourChin.fromJson(json['mouth_upper_lip_left_contour3'])
        : null;
    leftEyebrowLowerLeftQuarter =
    json['left_eyebrow_lower_left_quarter'] != null
        ? new ContourChin.fromJson(json['left_eyebrow_lower_left_quarter'])
        : null;
    mouthLowerLipLeftContour1 = json['mouth_lower_lip_left_contour1'] != null
        ? new ContourChin.fromJson(json['mouth_lower_lip_left_contour1'])
        : null;
    mouthLowerLipLeftContour3 = json['mouth_lower_lip_left_contour3'] != null
        ? new ContourChin.fromJson(json['mouth_lower_lip_left_contour3'])
        : null;
    mouthLowerLipLeftContour2 = json['mouth_lower_lip_left_contour2'] != null
        ? new ContourChin.fromJson(json['mouth_lower_lip_left_contour2'])
        : null;
    contourLeft9 = json['contour_left9'] != null
        ? new ContourChin.fromJson(json['contour_left9'])
        : null;
    leftEyeLowerRightQuarter = json['left_eye_lower_right_quarter'] != null
        ? new ContourChin.fromJson(json['left_eye_lower_right_quarter'])
        : null;
    contourRight6 = json['contour_right6'] != null
        ? new ContourChin.fromJson(json['contour_right6'])
        : null;
    noseTip = json['nose_tip'] != null
        ? new ContourChin.fromJson(json['nose_tip'])
        : null;
    rightEyebrowUpperMiddle = json['right_eyebrow_upper_middle'] != null
        ? new ContourChin.fromJson(json['right_eyebrow_upper_middle'])
        : null;
    rightEyebrowLowerMiddle = json['right_eyebrow_lower_middle'] != null
        ? new ContourChin.fromJson(json['right_eyebrow_lower_middle'])
        : null;
    leftEyeCenter = json['left_eye_center'] != null
        ? new ContourChin.fromJson(json['left_eye_center'])
        : null;
    rightEyebrowUpperLeftQuarter =
    json['right_eyebrow_upper_left_quarter'] != null
        ? new ContourChin.fromJson(json['right_eyebrow_upper_left_quarter'])
        : null;
    rightEyebrowRightCorner = json['right_eyebrow_right_corner'] != null
        ? new ContourChin.fromJson(json['right_eyebrow_right_corner'])
        : null;
    rightEyebrowUpperRightQuarter = json['right_eyebrow_upper_right_quarter'] !=
        null
        ? new ContourChin.fromJson(json['right_eyebrow_upper_right_quarter'])
        : null;
    contourLeft16 = json['contour_left16'] != null
        ? new ContourChin.fromJson(json['contour_left16'])
        : null;
    contourLeft15 = json['contour_left15'] != null
        ? new ContourChin.fromJson(json['contour_left15'])
        : null;
    contourLeft14 = json['contour_left14'] != null
        ? new ContourChin.fromJson(json['contour_left14'])
        : null;
    leftEyebrowUpperRightQuarter =
    json['left_eyebrow_upper_right_quarter'] != null
        ? new ContourChin.fromJson(json['left_eyebrow_upper_right_quarter'])
        : null;
    contourLeft12 = json['contour_left12'] != null
        ? new ContourChin.fromJson(json['contour_left12'])
        : null;
    contourLeft11 = json['contour_left11'] != null
        ? new ContourChin.fromJson(json['contour_left11'])
        : null;
    contourLeft10 = json['contour_left10'] != null
        ? new ContourChin.fromJson(json['contour_left10'])
        : null;
    leftEyebrowLowerMiddle = json['left_eyebrow_lower_middle'] != null
        ? new ContourChin.fromJson(json['left_eyebrow_lower_middle'])
        : null;
    leftEyebrowUpperLeftQuarter =
    json['left_eyebrow_upper_left_quarter'] != null
        ? new ContourChin.fromJson(json['left_eyebrow_upper_left_quarter'])
        : null;
    rightEyeUpperRightQuarter = json['right_eye_upper_right_quarter'] != null
        ? new ContourChin.fromJson(json['right_eye_upper_right_quarter'])
        : null;
    noseRightContour4 = json['nose_right_contour4'] != null
        ? new ContourChin.fromJson(json['nose_right_contour4'])
        : null;
    noseRightContour5 = json['nose_right_contour5'] != null
        ? new ContourChin.fromJson(json['nose_right_contour5'])
        : null;
    noseLeftContour4 = json['nose_left_contour4'] != null
        ? new ContourChin.fromJson(json['nose_left_contour4'])
        : null;
    noseLeftContour5 = json['nose_left_contour5'] != null
        ? new ContourChin.fromJson(json['nose_left_contour5'])
        : null;
    noseLeftContour2 = json['nose_left_contour2'] != null
        ? new ContourChin.fromJson(json['nose_left_contour2'])
        : null;
    noseRightContour1 = json['nose_right_contour1'] != null
        ? new ContourChin.fromJson(json['nose_right_contour1'])
        : null;
    noseRightContour2 = json['nose_right_contour2'] != null
        ? new ContourChin.fromJson(json['nose_right_contour2'])
        : null;
    noseRightContour3 = json['nose_right_contour3'] != null
        ? new ContourChin.fromJson(json['nose_right_contour3'])
        : null;
    leftEyeLeftCorner = json['left_eye_left_corner'] != null
        ? new ContourChin.fromJson(json['left_eye_left_corner'])
        : null;
    contourRight15 = json['contour_right15'] != null
        ? new ContourChin.fromJson(json['contour_right15'])
        : null;
    contourRight14 = json['contour_right14'] != null
        ? new ContourChin.fromJson(json['contour_right14'])
        : null;
    contourRight16 = json['contour_right16'] != null
        ? new ContourChin.fromJson(json['contour_right16'])
        : null;
    contourRight11 = json['contour_right11'] != null
        ? new ContourChin.fromJson(json['contour_right11'])
        : null;
    contourRight10 = json['contour_right10'] != null
        ? new ContourChin.fromJson(json['contour_right10'])
        : null;
    contourRight13 = json['contour_right13'] != null
        ? new ContourChin.fromJson(json['contour_right13'])
        : null;
    contourRight12 = json['contour_right12'] != null
        ? new ContourChin.fromJson(json['contour_right12'])
        : null;
    contourLeft8 = json['contour_left8'] != null
        ? new ContourChin.fromJson(json['contour_left8'])
        : null;
    mouthLowerLipTop = json['mouth_lower_lip_top'] != null
        ? new ContourChin.fromJson(json['mouth_lower_lip_top'])
        : null;
    rightEyeUpperLeftQuarter = json['right_eye_upper_left_quarter'] != null
        ? new ContourChin.fromJson(json['right_eye_upper_left_quarter'])
        : null;
    rightEyePupil = json['right_eye_pupil'] != null
        ? new ContourChin.fromJson(json['right_eye_pupil'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.contourChin != null) {
      data['contour_chin'] = this.contourChin.toJson();
    }
    if (this.leftEyeUpperLeftQuarter != null) {
      data['left_eye_upper_left_quarter'] =
          this.leftEyeUpperLeftQuarter.toJson();
    }
    if (this.mouthLowerLipRightContour1 != null) {
      data['mouth_lower_lip_right_contour1'] =
          this.mouthLowerLipRightContour1.toJson();
    }
    if (this.leftEyeBottom != null) {
      data['left_eye_bottom'] = this.leftEyeBottom.toJson();
    }
    if (this.mouthLowerLipRightContour2 != null) {
      data['mouth_lower_lip_right_contour2'] =
          this.mouthLowerLipRightContour2.toJson();
    }
    if (this.contourLeft7 != null) {
      data['contour_left7'] = this.contourLeft7.toJson();
    }
    if (this.contourLeft6 != null) {
      data['contour_left6'] = this.contourLeft6.toJson();
    }
    if (this.contourLeft5 != null) {
      data['contour_left5'] = this.contourLeft5.toJson();
    }
    if (this.contourLeft4 != null) {
      data['contour_left4'] = this.contourLeft4.toJson();
    }
    if (this.contourLeft3 != null) {
      data['contour_left3'] = this.contourLeft3.toJson();
    }
    if (this.contourLeft2 != null) {
      data['contour_left2'] = this.contourLeft2.toJson();
    }
    if (this.contourLeft1 != null) {
      data['contour_left1'] = this.contourLeft1.toJson();
    }
    if (this.leftEyeLowerLeftQuarter != null) {
      data['left_eye_lower_left_quarter'] =
          this.leftEyeLowerLeftQuarter.toJson();
    }
    if (this.contourRight1 != null) {
      data['contour_right1'] = this.contourRight1.toJson();
    }
    if (this.contourRight3 != null) {
      data['contour_right3'] = this.contourRight3.toJson();
    }
    if (this.contourRight2 != null) {
      data['contour_right2'] = this.contourRight2.toJson();
    }
    if (this.contourRight5 != null) {
      data['contour_right5'] = this.contourRight5.toJson();
    }
    if (this.contourRight4 != null) {
      data['contour_right4'] = this.contourRight4.toJson();
    }
    if (this.contourRight7 != null) {
      data['contour_right7'] = this.contourRight7.toJson();
    }
    if (this.leftEyebrowLeftCorner != null) {
      data['left_eyebrow_left_corner'] = this.leftEyebrowLeftCorner.toJson();
    }
    if (this.rightEyeRightCorner != null) {
      data['right_eye_right_corner'] = this.rightEyeRightCorner.toJson();
    }
    if (this.noseBridge1 != null) {
      data['nose_bridge1'] = this.noseBridge1.toJson();
    }
    if (this.noseBridge3 != null) {
      data['nose_bridge3'] = this.noseBridge3.toJson();
    }
    if (this.noseBridge2 != null) {
      data['nose_bridge2'] = this.noseBridge2.toJson();
    }
    if (this.rightEyebrowUpperLeftCorner != null) {
      data['right_eyebrow_upper_left_corner'] =
          this.rightEyebrowUpperLeftCorner.toJson();
    }
    if (this.mouthUpperLipRightContour4 != null) {
      data['mouth_upper_lip_right_contour4'] =
          this.mouthUpperLipRightContour4.toJson();
    }
    if (this.mouthUpperLipRightContour1 != null) {
      data['mouth_upper_lip_right_contour1'] =
          this.mouthUpperLipRightContour1.toJson();
    }
    if (this.rightEyeLeftCorner != null) {
      data['right_eye_left_corner'] = this.rightEyeLeftCorner.toJson();
    }
    if (this.leftEyebrowUpperRightCorner != null) {
      data['left_eyebrow_upper_right_corner'] =
          this.leftEyebrowUpperRightCorner.toJson();
    }
    if (this.leftEyebrowUpperMiddle != null) {
      data['left_eyebrow_upper_middle'] = this.leftEyebrowUpperMiddle.toJson();
    }
    if (this.mouthLowerLipRightContour3 != null) {
      data['mouth_lower_lip_right_contour3'] =
          this.mouthLowerLipRightContour3.toJson();
    }
    if (this.noseLeftContour3 != null) {
      data['nose_left_contour3'] = this.noseLeftContour3.toJson();
    }
    if (this.mouthLowerLipBottom != null) {
      data['mouth_lower_lip_bottom'] = this.mouthLowerLipBottom.toJson();
    }
    if (this.mouthUpperLipRightContour2 != null) {
      data['mouth_upper_lip_right_contour2'] =
          this.mouthUpperLipRightContour2.toJson();
    }
    if (this.leftEyeTop != null) {
      data['left_eye_top'] = this.leftEyeTop.toJson();
    }
    if (this.noseLeftContour1 != null) {
      data['nose_left_contour1'] = this.noseLeftContour1.toJson();
    }
    if (this.mouthUpperLipBottom != null) {
      data['mouth_upper_lip_bottom'] = this.mouthUpperLipBottom.toJson();
    }
    if (this.mouthUpperLipLeftContour2 != null) {
      data['mouth_upper_lip_left_contour2'] =
          this.mouthUpperLipLeftContour2.toJson();
    }
    if (this.mouthUpperLipTop != null) {
      data['mouth_upper_lip_top'] = this.mouthUpperLipTop.toJson();
    }
    if (this.mouthUpperLipLeftContour1 != null) {
      data['mouth_upper_lip_left_contour1'] =
          this.mouthUpperLipLeftContour1.toJson();
    }
    if (this.mouthUpperLipLeftContour4 != null) {
      data['mouth_upper_lip_left_contour4'] =
          this.mouthUpperLipLeftContour4.toJson();
    }
    if (this.rightEyeTop != null) {
      data['right_eye_top'] = this.rightEyeTop.toJson();
    }
    if (this.mouthUpperLipRightContour3 != null) {
      data['mouth_upper_lip_right_contour3'] =
          this.mouthUpperLipRightContour3.toJson();
    }
    if (this.rightEyeBottom != null) {
      data['right_eye_bottom'] = this.rightEyeBottom.toJson();
    }
    if (this.rightEyebrowLowerLeftCorner != null) {
      data['right_eyebrow_lower_left_corner'] =
          this.rightEyebrowLowerLeftCorner.toJson();
    }
    if (this.mouthLeftCorner != null) {
      data['mouth_left_corner'] = this.mouthLeftCorner.toJson();
    }
    if (this.noseMiddleContour != null) {
      data['nose_middle_contour'] = this.noseMiddleContour.toJson();
    }
    if (this.rightEyeLowerRightQuarter != null) {
      data['right_eye_lower_right_quarter'] =
          this.rightEyeLowerRightQuarter.toJson();
    }
    if (this.rightEyebrowLowerRightQuarter != null) {
      data['right_eyebrow_lower_right_quarter'] =
          this.rightEyebrowLowerRightQuarter.toJson();
    }
    if (this.contourRight9 != null) {
      data['contour_right9'] = this.contourRight9.toJson();
    }
    if (this.mouthRightCorner != null) {
      data['mouth_right_corner'] = this.mouthRightCorner.toJson();
    }
    if (this.rightEyeLowerLeftQuarter != null) {
      data['right_eye_lower_left_quarter'] =
          this.rightEyeLowerLeftQuarter.toJson();
    }
    if (this.rightEyeCenter != null) {
      data['right_eye_center'] = this.rightEyeCenter.toJson();
    }
    if (this.leftEyeUpperRightQuarter != null) {
      data['left_eye_upper_right_quarter'] =
          this.leftEyeUpperRightQuarter.toJson();
    }
    if (this.rightEyebrowLowerLeftQuarter != null) {
      data['right_eyebrow_lower_left_quarter'] =
          this.rightEyebrowLowerLeftQuarter.toJson();
    }
    if (this.leftEyePupil != null) {
      data['left_eye_pupil'] = this.leftEyePupil.toJson();
    }
    if (this.contourRight8 != null) {
      data['contour_right8'] = this.contourRight8.toJson();
    }
    if (this.contourLeft13 != null) {
      data['contour_left13'] = this.contourLeft13.toJson();
    }
    if (this.leftEyebrowLowerRightQuarter != null) {
      data['left_eyebrow_lower_right_quarter'] =
          this.leftEyebrowLowerRightQuarter.toJson();
    }
    if (this.leftEyeRightCorner != null) {
      data['left_eye_right_corner'] = this.leftEyeRightCorner.toJson();
    }
    if (this.leftEyebrowLowerRightCorner != null) {
      data['left_eyebrow_lower_right_corner'] =
          this.leftEyebrowLowerRightCorner.toJson();
    }
    if (this.mouthUpperLipLeftContour3 != null) {
      data['mouth_upper_lip_left_contour3'] =
          this.mouthUpperLipLeftContour3.toJson();
    }
    if (this.leftEyebrowLowerLeftQuarter != null) {
      data['left_eyebrow_lower_left_quarter'] =
          this.leftEyebrowLowerLeftQuarter.toJson();
    }
    if (this.mouthLowerLipLeftContour1 != null) {
      data['mouth_lower_lip_left_contour1'] =
          this.mouthLowerLipLeftContour1.toJson();
    }
    if (this.mouthLowerLipLeftContour3 != null) {
      data['mouth_lower_lip_left_contour3'] =
          this.mouthLowerLipLeftContour3.toJson();
    }
    if (this.mouthLowerLipLeftContour2 != null) {
      data['mouth_lower_lip_left_contour2'] =
          this.mouthLowerLipLeftContour2.toJson();
    }
    if (this.contourLeft9 != null) {
      data['contour_left9'] = this.contourLeft9.toJson();
    }
    if (this.leftEyeLowerRightQuarter != null) {
      data['left_eye_lower_right_quarter'] =
          this.leftEyeLowerRightQuarter.toJson();
    }
    if (this.contourRight6 != null) {
      data['contour_right6'] = this.contourRight6.toJson();
    }
    if (this.noseTip != null) {
      data['nose_tip'] = this.noseTip.toJson();
    }
    if (this.rightEyebrowUpperMiddle != null) {
      data['right_eyebrow_upper_middle'] =
          this.rightEyebrowUpperMiddle.toJson();
    }
    if (this.rightEyebrowLowerMiddle != null) {
      data['right_eyebrow_lower_middle'] =
          this.rightEyebrowLowerMiddle.toJson();
    }
    if (this.leftEyeCenter != null) {
      data['left_eye_center'] = this.leftEyeCenter.toJson();
    }
    if (this.rightEyebrowUpperLeftQuarter != null) {
      data['right_eyebrow_upper_left_quarter'] =
          this.rightEyebrowUpperLeftQuarter.toJson();
    }
    if (this.rightEyebrowRightCorner != null) {
      data['right_eyebrow_right_corner'] =
          this.rightEyebrowRightCorner.toJson();
    }
    if (this.rightEyebrowUpperRightQuarter != null) {
      data['right_eyebrow_upper_right_quarter'] =
          this.rightEyebrowUpperRightQuarter.toJson();
    }
    if (this.contourLeft16 != null) {
      data['contour_left16'] = this.contourLeft16.toJson();
    }
    if (this.contourLeft15 != null) {
      data['contour_left15'] = this.contourLeft15.toJson();
    }
    if (this.contourLeft14 != null) {
      data['contour_left14'] = this.contourLeft14.toJson();
    }
    if (this.leftEyebrowUpperRightQuarter != null) {
      data['left_eyebrow_upper_right_quarter'] =
          this.leftEyebrowUpperRightQuarter.toJson();
    }
    if (this.contourLeft12 != null) {
      data['contour_left12'] = this.contourLeft12.toJson();
    }
    if (this.contourLeft11 != null) {
      data['contour_left11'] = this.contourLeft11.toJson();
    }
    if (this.contourLeft10 != null) {
      data['contour_left10'] = this.contourLeft10.toJson();
    }
    if (this.leftEyebrowLowerMiddle != null) {
      data['left_eyebrow_lower_middle'] = this.leftEyebrowLowerMiddle.toJson();
    }
    if (this.leftEyebrowUpperLeftQuarter != null) {
      data['left_eyebrow_upper_left_quarter'] =
          this.leftEyebrowUpperLeftQuarter.toJson();
    }
    if (this.rightEyeUpperRightQuarter != null) {
      data['right_eye_upper_right_quarter'] =
          this.rightEyeUpperRightQuarter.toJson();
    }
    if (this.noseRightContour4 != null) {
      data['nose_right_contour4'] = this.noseRightContour4.toJson();
    }
    if (this.noseRightContour5 != null) {
      data['nose_right_contour5'] = this.noseRightContour5.toJson();
    }
    if (this.noseLeftContour4 != null) {
      data['nose_left_contour4'] = this.noseLeftContour4.toJson();
    }
    if (this.noseLeftContour5 != null) {
      data['nose_left_contour5'] = this.noseLeftContour5.toJson();
    }
    if (this.noseLeftContour2 != null) {
      data['nose_left_contour2'] = this.noseLeftContour2.toJson();
    }
    if (this.noseRightContour1 != null) {
      data['nose_right_contour1'] = this.noseRightContour1.toJson();
    }
    if (this.noseRightContour2 != null) {
      data['nose_right_contour2'] = this.noseRightContour2.toJson();
    }
    if (this.noseRightContour3 != null) {
      data['nose_right_contour3'] = this.noseRightContour3.toJson();
    }
    if (this.leftEyeLeftCorner != null) {
      data['left_eye_left_corner'] = this.leftEyeLeftCorner.toJson();
    }
    if (this.contourRight15 != null) {
      data['contour_right15'] = this.contourRight15.toJson();
    }
    if (this.contourRight14 != null) {
      data['contour_right14'] = this.contourRight14.toJson();
    }
    if (this.contourRight16 != null) {
      data['contour_right16'] = this.contourRight16.toJson();
    }
    if (this.contourRight11 != null) {
      data['contour_right11'] = this.contourRight11.toJson();
    }
    if (this.contourRight10 != null) {
      data['contour_right10'] = this.contourRight10.toJson();
    }
    if (this.contourRight13 != null) {
      data['contour_right13'] = this.contourRight13.toJson();
    }
    if (this.contourRight12 != null) {
      data['contour_right12'] = this.contourRight12.toJson();
    }
    if (this.contourLeft8 != null) {
      data['contour_left8'] = this.contourLeft8.toJson();
    }
    if (this.mouthLowerLipTop != null) {
      data['mouth_lower_lip_top'] = this.mouthLowerLipTop.toJson();
    }
    if (this.rightEyeUpperLeftQuarter != null) {
      data['right_eye_upper_left_quarter'] =
          this.rightEyeUpperLeftQuarter.toJson();
    }
    if (this.rightEyePupil != null) {
      data['right_eye_pupil'] = this.rightEyePupil.toJson();
    }
    return data;
  }
}

class ContourChin {
  int y;
  int x;

  ContourChin({this.y, this.x});

  ContourChin.fromJson(Map<String, dynamic> json) {
    y = json['y'];
    x = json['x'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['y'] = this.y;
    data['x'] = this.x;
    return data;
  }
}

class Attributes {
  Emotion emotion;
  Beauty beauty;
  Gender gender;
  Age age;
  Mouthstatus mouthstatus;
  Gender glass;
  Skinstatus skinstatus;
  Headpose headpose;
  Blur blur;
  Blurness smile;
  Eyestatus eyestatus;
  Facequality facequality;
  Gender ethnicity;

  Attributes(
      {this.emotion,
        this.beauty,
        this.gender,
        this.age,
        this.mouthstatus,
        this.glass,
        this.skinstatus,
        this.headpose,
        this.blur,
        this.smile,
        this.eyestatus,
        this.facequality,
        this.ethnicity});

  Attributes.fromJson(Map<String, dynamic> json) {
    emotion =
    json['emotion'] != null ? new Emotion.fromJson(json['emotion']) : null;
    beauty =
    json['beauty'] != null ? new Beauty.fromJson(json['beauty']) : null;
    gender =
    json['gender'] != null ? new Gender.fromJson(json['gender']) : null;
    age = json['age'] != null ? new Age.fromJson(json['age']) : null;
    mouthstatus = json['mouthstatus'] != null
        ? new Mouthstatus.fromJson(json['mouthstatus'])
        : null;
    glass = json['glass'] != null ? new Gender.fromJson(json['glass']) : null;
    skinstatus = json['skinstatus'] != null
        ? new Skinstatus.fromJson(json['skinstatus'])
        : null;
    headpose = json['headpose'] != null
        ? new Headpose.fromJson(json['headpose'])
        : null;
    blur = json['blur'] != null ? new Blur.fromJson(json['blur']) : null;
    smile = json['smile'] != null ? new Blurness.fromJson(json['smile']) : null;
    eyestatus = json['eyestatus'] != null
        ? new Eyestatus.fromJson(json['eyestatus'])
        : null;
    facequality = json['facequality'] != null
        ? new Facequality.fromJson(json['facequality'])
        : null;
    ethnicity = json['ethnicity'] != null
        ? new Gender.fromJson(json['ethnicity'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.emotion != null) {
      data['emotion'] = this.emotion.toJson();
    }
    if (this.beauty != null) {
      data['beauty'] = this.beauty.toJson();
    }
    if (this.gender != null) {
      data['gender'] = this.gender.toJson();
    }
    if (this.age != null) {
      data['age'] = this.age.toJson();
    }
    if (this.mouthstatus != null) {
      data['mouthstatus'] = this.mouthstatus.toJson();
    }
    if (this.glass != null) {
      data['glass'] = this.glass.toJson();
    }
    if (this.skinstatus != null) {
      data['skinstatus'] = this.skinstatus.toJson();
    }
    if (this.headpose != null) {
      data['headpose'] = this.headpose.toJson();
    }
    if (this.blur != null) {
      data['blur'] = this.blur.toJson();
    }
    if (this.smile != null) {
      data['smile'] = this.smile.toJson();
    }
    if (this.eyestatus != null) {
      data['eyestatus'] = this.eyestatus.toJson();
    }
    if (this.facequality != null) {
      data['facequality'] = this.facequality.toJson();
    }
    if (this.ethnicity != null) {
      data['ethnicity'] = this.ethnicity.toJson();
    }
    return data;
  }
}

class Emotion {
  double sadness;
  double neutral;
  double disgust;
  double anger;
  double surprise;
  double fear;
  double happiness;

  Emotion(
      {this.sadness,
        this.neutral,
        this.disgust,
        this.anger,
        this.surprise,
        this.fear,
        this.happiness});

  Emotion.fromJson(Map<String, dynamic> json) {
    sadness = json['sadness'];
    neutral = json['neutral'];
    disgust = json['disgust'];
    anger = json['anger'];
    surprise = json['surprise'];
    fear = json['fear'];
    happiness = json['happiness'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sadness'] = this.sadness;
    data['neutral'] = this.neutral;
    data['disgust'] = this.disgust;
    data['anger'] = this.anger;
    data['surprise'] = this.surprise;
    data['fear'] = this.fear;
    data['happiness'] = this.happiness;
    return data;
  }
}

class Beauty {
  double femaleScore;
  double maleScore;

  Beauty({this.femaleScore, this.maleScore});

  Beauty.fromJson(Map<String, dynamic> json) {
    femaleScore = json['female_score'];
    maleScore = json['male_score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['female_score'] = this.femaleScore;
    data['male_score'] = this.maleScore;
    return data;
  }
}

class Gender {
  String value;

  Gender({this.value});

  Gender.fromJson(Map<String, dynamic> json) {
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    return data;
  }
}

class Age {
  int value;

  Age({this.value});

  Age.fromJson(Map<String, dynamic> json) {
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    return data;
  }
}

class Mouthstatus {
  double close;
  double surgicalMaskOrRespirator;
  double open;
  double otherOcclusion;

  Mouthstatus(
      {this.close,
        this.surgicalMaskOrRespirator,
        this.open,
        this.otherOcclusion});

  Mouthstatus.fromJson(Map<String, dynamic> json) {
    close = json['close'];
    surgicalMaskOrRespirator = json['surgical_mask_or_respirator'];
    open = json['open'];
    otherOcclusion = json['other_occlusion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['close'] = this.close;
    data['surgical_mask_or_respirator'] = this.surgicalMaskOrRespirator;
    data['open'] = this.open;
    data['other_occlusion'] = this.otherOcclusion;
    return data;
  }
}

class Skinstatus {
  double darkCircle;
  double stain;
  double acne;
  double health;

  Skinstatus({this.darkCircle, this.stain, this.acne, this.health});

  Skinstatus.fromJson(Map<String, dynamic> json) {
    darkCircle = json['dark_circle'];
    stain = json['stain'];
    acne = json['acne'];
    health = json['health'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dark_circle'] = this.darkCircle;
    data['stain'] = this.stain;
    data['acne'] = this.acne;
    data['health'] = this.health;
    return data;
  }
}

class Headpose {
  double yawAngle;
  double pitchAngle;
  double rollAngle;

  Headpose({this.yawAngle, this.pitchAngle, this.rollAngle});

  Headpose.fromJson(Map<String, dynamic> json) {
    yawAngle = json['yaw_angle'];
    pitchAngle = json['pitch_angle'];
    rollAngle = json['roll_angle'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['yaw_angle'] = this.yawAngle;
    data['pitch_angle'] = this.pitchAngle;
    data['roll_angle'] = this.rollAngle;
    return data;
  }
}

class Blur {
  Blurness blurness;
  Blurness motionblur;
  Blurness gaussianblur;

  Blur({this.blurness, this.motionblur, this.gaussianblur});

  Blur.fromJson(Map<String, dynamic> json) {
    blurness = json['blurness'] != null
        ? new Blurness.fromJson(json['blurness'])
        : null;
    motionblur = json['motionblur'] != null
        ? new Blurness.fromJson(json['motionblur'])
        : null;
    gaussianblur = json['gaussianblur'] != null
        ? new Blurness.fromJson(json['gaussianblur'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.blurness != null) {
      data['blurness'] = this.blurness.toJson();
    }
    if (this.motionblur != null) {
      data['motionblur'] = this.motionblur.toJson();
    }
    if (this.gaussianblur != null) {
      data['gaussianblur'] = this.gaussianblur.toJson();
    }
    return data;
  }
}

class Blurness {
  double threshold;
  double value;

  Blurness({this.threshold, this.value});

  Blurness.fromJson(Map<String, dynamic> json) {
    threshold = json['threshold'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['threshold'] = this.threshold;
    data['value'] = this.value;
    return data;
  }
}

class Eyestatus {
  LeftEyeStatus leftEyeStatus;
  LeftEyeStatus rightEyeStatus;

  Eyestatus({this.leftEyeStatus, this.rightEyeStatus});

  Eyestatus.fromJson(Map<String, dynamic> json) {
    leftEyeStatus = json['left_eye_status'] != null
        ? new LeftEyeStatus.fromJson(json['left_eye_status'])
        : null;
    rightEyeStatus = json['right_eye_status'] != null
        ? new LeftEyeStatus.fromJson(json['right_eye_status'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.leftEyeStatus != null) {
      data['left_eye_status'] = this.leftEyeStatus.toJson();
    }
    if (this.rightEyeStatus != null) {
      data['right_eye_status'] = this.rightEyeStatus.toJson();
    }
    return data;
  }
}

class LeftEyeStatus {
  double normalGlassEyeOpen;
  double noGlassEyeClose;
  double occlusion;
  double noGlassEyeOpen;
  double normalGlassEyeClose;
  double darkGlasses;

  LeftEyeStatus(
      {this.normalGlassEyeOpen,
        this.noGlassEyeClose,
        this.occlusion,
        this.noGlassEyeOpen,
        this.normalGlassEyeClose,
        this.darkGlasses});

  LeftEyeStatus.fromJson(Map<String, dynamic> json) {
    normalGlassEyeOpen = json['normal_glass_eye_open'];
    noGlassEyeClose = json['no_glass_eye_close'];
    occlusion = json['occlusion'];
    noGlassEyeOpen = json['no_glass_eye_open'];
    normalGlassEyeClose = json['normal_glass_eye_close'];
    darkGlasses = json['dark_glasses'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['normal_glass_eye_open'] = this.normalGlassEyeOpen;
    data['no_glass_eye_close'] = this.noGlassEyeClose;
    data['occlusion'] = this.occlusion;
    data['no_glass_eye_open'] = this.noGlassEyeOpen;
    data['normal_glass_eye_close'] = this.normalGlassEyeClose;
    data['dark_glasses'] = this.darkGlasses;
    return data;
  }
}

class Facequality {
  double threshold;
  double value;

  Facequality({this.threshold, this.value});

  Facequality.fromJson(Map<String, dynamic> json) {
    threshold = json['threshold'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['threshold'] = this.threshold;
    data['value'] = this.value;
    return data;
  }
}

class FaceRectangle {
  int width;
  int top;
  int left;
  int height;

  FaceRectangle({this.width, this.top, this.left, this.height});

  FaceRectangle.fromJson(Map<String, dynamic> json) {
    width = json['width'];
    top = json['top'];
    left = json['left'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['width'] = this.width;
    data['top'] = this.top;
    data['left'] = this.left;
    data['height'] = this.height;
    return data;
  }
}

