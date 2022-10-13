import 'package:ets/app/modules/daq_device/controllers/daq_device_controller.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<DaqDeviceController>(() => DaqDeviceController());
  }
}
