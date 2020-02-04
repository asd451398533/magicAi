//
//  ALCommon
//
//  gmalpha_flutter
//  Created by lxrent on 2019/2/19.
//  Copyright © 2019 Gengmei. All rights reserved.
//

import 'package:flutter/material.dart';
import 'ALColors.dart';

class ALAlphaButton extends FlatButton {
//  factory ALAlphaButton
  /// Create a simple text button.
  const ALAlphaButton({
    Key key,
    @required VoidCallback onPressed,
    ValueChanged<bool> onHighlightChanged,
    ButtonTextTheme textTheme,
    Color textColor,
    Color disabledTextColor,
    Color color,
    Color disabledColor,
    Color highlightColor,
    Color splashColor,
    double minWidth,
    Brightness colorBrightness,
    EdgeInsetsGeometry padding,
    ShapeBorder shape,
    Clip clipBehavior = Clip.none,
    MaterialTapTargetSize materialTapTargetSize,
    @required Widget child,
  }) : super(
          key: key,
          onPressed: onPressed,
          onHighlightChanged: onHighlightChanged,
          textTheme: textTheme,
          textColor: textColor,
          disabledTextColor: disabledTextColor,
          color: color,
          disabledColor: disabledColor,
          highlightColor: highlightColor,
          splashColor: splashColor,
          colorBrightness: colorBrightness,
          padding: padding,
          shape: shape,
          clipBehavior: clipBehavior,
          materialTapTargetSize: materialTapTargetSize,
          child: child,
        );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FlatButton(
      textTheme:textTheme,
      padding: padding,
      child: child,
      onPressed: onPressed,
      textColor: ALColors.Color323232,
      highlightColor:ALColors.Color323232,
      color: ALColors.ColorFFFFFF,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
          borderSide: BorderSide(color: ALColors.Color323232)),
    );
  }
}
