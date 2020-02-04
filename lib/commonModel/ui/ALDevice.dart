//
//  ALDevice
//
//  gm_alpha_flutter
//  Created by lxrent on 2019/1/30.
//  Copyright © 2019 Gengmei. All rights reserved.
//
import 'dart:ui';

class ALDevice {
  ALDevice._();
  static bool debug = !const bool.fromEnvironment("dart.vm.product");
  static double width = window.physicalSize.width;
  static double height = window.physicalSize.height;

}