import 'package:flutter/material.dart';
import '../configs/colors.dart';

BoxDecoration gradientBoxDecoration(
    {double radius = 10,
    Color color = Colors.transparent,
    Color gradientColor2 = ets_white,
    Color gradientColor1 = ets_white,
    var showShadow = false}) {
  return BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [gradientColor1, gradientColor2]),
    boxShadow: showShadow
        ? [BoxShadow(color: ets_ShadowColor, blurRadius: 10, spreadRadius: 2)]
        : [BoxShadow(color: Colors.transparent)],
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
