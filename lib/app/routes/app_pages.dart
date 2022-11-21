import 'package:get/get.dart';

import 'package:ets/app/modules/daq_device/bindings/daq_device_binding.dart';
import 'package:ets/app/modules/daq_device/views/daq_device_view.dart';
import 'package:ets/app/modules/home/bindings/home_binding.dart';
import 'package:ets/app/modules/home/views/home_view.dart';
import 'package:ets/app/modules/project/bindings/project_binding.dart';
import 'package:ets/app/modules/project/views/project_view.dart';
import 'package:ets/app/modules/setting/bindings/setting_binding.dart';
import 'package:ets/app/modules/setting/views/setting_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PROJECT,
      page: () => ProjectView(),
      binding: ProjectBinding(),
    ),
    GetPage(
      name: _Paths.SETTING,
      page: () => SettingView(),
      binding: HomeBinding(),
      transition: Transition.leftToRight,
    ),
  ];
}
