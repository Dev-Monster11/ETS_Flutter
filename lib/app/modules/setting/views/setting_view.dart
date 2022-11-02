import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/setting_controller.dart';
import '../../widgets/custom_textfield.dart';

class SettingView extends GetView<SettingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SettingView'),
          centerTitle: true,
        ),
        body: Center(child: Text("Setting")));
  }
}
