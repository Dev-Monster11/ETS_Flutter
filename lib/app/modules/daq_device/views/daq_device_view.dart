import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/daq_device_controller.dart';

class DaqDeviceView extends GetView<DaqDeviceController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('DaqDeviceView'),
          centerTitle: true,
        ),
        body: Obx(
            () => controller.scanStatus.value == BluetoothScanStatus.UNAVAILABLE
                ? Center(
                    child: Column(
                    children: const [
                      CircularProgressIndicator(),
                      Text("Bluetooth is unavailable")
                    ],
                  ))
                : (controller.discoveredScanResults.isEmpty
                    ? Center(
                        child: Column(
                        children: const [
                          CircularProgressIndicator(),
                          Text("No available DAQ RaspberryPi nearby")
                        ],
                      ))
                    : Container(
                        color: const Color(0xFFEEF3F7),
                        height: double.infinity,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          scrollDirection: Axis.vertical,
                          itemCount: controller.discoveredScanResults.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: controller.discoveredScanResults[index]
                                  .advertisementData.localName,
                            );
                          },
                        )))));
  }
}
