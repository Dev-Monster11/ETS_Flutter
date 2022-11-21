import 'package:ets/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../widgets/custom_textfield.dart';

class SettingView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    final gains = [1, 2, 5, 10];
    final freqs = [900, 1800, 3600, 7200, 14400];
    return Scaffold(
        body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: Get.width,
        height: Get.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextFormField(
              onChange: (v) {
                controller.project.value.name = v;
              },
              prefixIcon: Icons.padding,
              initialValue: controller.project.value.name,
              hintText: "Project",
            ),
            const SizedBox(
              height: 8,
            ),
            Obx(() => CustomTextFormField(
                  onChange: (v) {
                    controller.project.value.user = v;
                  },
                  prefixIcon: Icons.person,
                  initialValue: controller.project.value.user,
                  hintText: "User",
                )),
            const SizedBox(
              height: 8,
            ),
            Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: DropdownButton(
                    value: controller.tempShot.value.gain,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (value) {
                      controller.tempShot.update((shot) {
                        shot?.gain = int.parse(value.toString());
                      });
                    },
                    isExpanded: true,
                    items: gains.map((item) {
                      return DropdownMenuItem(
                          child: Text('$item'), value: item);
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: DropdownButton(
                    value: controller.tempShot.value.sr,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (value) {
                      controller.tempShot.update((shot) {
                        shot?.sr = int.parse(value.toString());
                      });
                    },
                    isExpanded: true,
                    items: freqs.map((item) {
                      return DropdownMenuItem(
                          child: Text('${item}Hz'), value: item);
                    }).toList(),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Obx(() => DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      prefixIcon: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () async {
                            controller.startScan();
                          })),
                  hint: const Text('Device'),
                  items: controller.devices.map((e) {
                    return DropdownMenuItem<String>(
                      value: e.id.toString(),
                      child: Text(e.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    controller.getHandle(v);
                    // service?.service?.handle(v!).then((value) {
                    //   p.handle = value;
                    // });
                  },
                )),
            const SizedBox(
              height: 8,
            ),
            CustomTextFormField(
              onChange: (v) {
                controller.tempShot.value.notes = v;
              },
              maxLine: 5,
              prefixIcon: Icons.notes,
              initialValue: controller.tempShot.value.notes,
              hintText: "Notes",
            ),
            IconButton(
                onPressed: controller.saveDAQ, icon: const Icon(Icons.save)),
          ],
        ),
      ),
    ));
  }
}
