import 'package:get/get.dart';

import '../controllers/daq_device_controller.dart';

class DaqDeviceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaqDeviceController>(
      () => DaqDeviceController(),
    );
  }
}
