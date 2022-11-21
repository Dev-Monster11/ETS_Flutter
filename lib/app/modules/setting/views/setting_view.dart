import 'package:ets/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../controllers/setting_controller.dart';
import '../../widgets/custom_textfield.dart';

class SettingView extends GetView<SettingController> {
  @override
  Widget build(BuildContext context) {
    final HomeController c = Get.find();
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
                c.project.value.name = v;
              },
              prefixIcon: Icons.padding,
              initialValue: c.project.value.name,
              hintText: "Project",
            ),
            const SizedBox(
              height: 8,
            ),
            Obx(() => CustomTextFormField(
                  onChange: (v) {
                    c.project.value.user = v;
                  },
                  prefixIcon: Icons.person,
                  initialValue: c.project.value.user,
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
                    value: c.tempShot.value.gain,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (value) {
                      c.tempShot.update((shot) {
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
                    value: c.tempShot.value.sr,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    onChanged: (value) {
                      c.tempShot.update((shot) {
                        shot?.gain = int.parse(value.toString());
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
                            c.startScan();
                          })),
                  hint: const Text('Device'),
                  items: c.devices.map((e) {
                    return DropdownMenuItem<String>(
                      value: e.id.toString(),
                      child: Text(e.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    c.getHandle(v);
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
                c.tempShot.value.notes = v;
              },
              maxLine: 5,
              prefixIcon: Icons.notes,
              initialValue: c.tempShot.value.notes,
              hintText: "Notes",
            ),
          ],
        ),
      ),
    ));
  }
}
