import 'package:ets/app/modules/home/project_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SettingController extends GetxController {
  //TODO: Implement SettingController

  final project = Project(name: '', sensor: '', user: '', shots: []).obs;
  final devices = [].obs;
  @override
  void onInit() {
    super.onInit();
    print("asdf");
  }

  @override
  void onReady() {
    super.onReady();
    print("------------------------------------");
  }

  @override
  void onClose() {}

  void startScan() {}

  void getHandle(v) {}
}
