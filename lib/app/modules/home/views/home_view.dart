// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:ets/app/configs/colors.dart';
import 'package:ets/app/modules/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:flutter_spinbox/material.dart';
import '../../../utils/utils.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const topStyle = TextStyle(color: ets_white, fontWeight: FontWeight.bold);
    const saveStyle = TextStyle(color: Color(0xFF212121));
    final gains = [1, 2, 5, 10];
    final freqs = [900, 1800, 3600, 7200, 14400];

    return SafeArea(
        child: Scaffold(
            key: controller.scaffoldKey,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  controller.openDrawer();
                },
              ),
              actions: [
                // IconButton(icon: Icon(Icons.bluetooth_disabled), onPressed: () {}),
                PopupMenuButton<int>(
                  color: Colors.grey,
                  offset: const Offset(0, 10),
                  onSelected: controller.onAction,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                        value: 1,
                        child: Row(children: const [
                          Icon(Icons.bluetooth),
                          SizedBox(width: 10),
                          Text("Bluetooth")
                        ])),
                    PopupMenuItem(
                        value: 2,
                        child: Row(children: const [
                          Icon(Icons.share),
                          SizedBox(width: 10),
                          Text("Share")
                        ]))
                  ],
                )
                // IconButton(
                //     icon: Icon(Icons.bluetooth_connected), onPressed: controller.startBluetooth),
              ],
              title: const Text('ETS'),
              centerTitle: false,
            ),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  const DrawerHeader(
                    child: Text('ETS'),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                      leading: const Icon(Icons.task),
                      title: const Text('Project'),
                      onTap: () {
                        controller.closeDrawer();
                        Get.toNamed("/project");
                      })
                ],
              ),
            ),
            body: Container(
                width: Get.width,
                height: Get.height,
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: topCards(
                              0,
                              ets_color_blue_gradient1,
                              ets_color_blue_gradient2,
                              const Icon(Icons.task,
                                  color: ets_white, size: 25),
                              Column(
                                children: [
                                  const FittedBox(
                                      child: Text("Project", style: topStyle)),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Obx(() => Text(controller.projectName.value,
                                      style: saveStyle)),
                                ],
                              ))),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Center(
                                  child: topCards(
                                      1,
                                      ets_color_blue_gradient1,
                                      ets_color_blue_gradient2,
                                      const Icon(Icons.person,
                                          color: ets_white, size: 25),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("User", style: topStyle),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Obx(() => Text(
                                              controller.tempShot.value.user ??
                                                  "",
                                              style: saveStyle)),
                                        ],
                                      ))),
                              Center(
                                  child: topCards(
                                      2,
                                      ets_color_blue_gradient1,
                                      ets_color_blue_gradient2,
                                      const Icon(Icons.task,
                                          color: ets_white, size: 25),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("SensorID",
                                              style: topStyle),
                                          const SizedBox(
                                            height: 2,
                                          ),
                                          Obx(() => Text(
                                              controller.tempShot.value
                                                      .sensorID ??
                                                  "",
                                              style: saveStyle)),
                                        ],
                                      ))),
                            ],
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Obx(() => IconButton(
                                  onPressed: controller.isStarted.value
                                      ? null
                                      : controller.start,
                                  icon: Icon(
                                    controller.isStarted.value
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                    color: controller.isStarted.value
                                        ? const Color(0xFFF44336)
                                        : const Color(0xFF2196F3),
                                    size: 50,
                                  )))),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const Text("Gain"),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Obx(() => DropdownButton(
                                          value: controller.tempShot.value.gain,
                                          icon:
                                              const Icon(Icons.arrow_downward),
                                          elevation: 16,
                                          style: const TextStyle(
                                              color: Colors.deepPurple),
                                          underline: Container(
                                            height: 2,
                                            color: Colors.deepPurpleAccent,
                                          ),
                                          onChanged: (value) {
                                            // controller.tempShot.value.gain =
                                            //     int.parse(value.toString());
                                            controller.tempShot.update((shot) {
                                              shot?.gain =
                                                  int.parse(value.toString());
                                            });
                                          },
                                          isExpanded: true,
                                          items: gains.map((item) {
                                            return DropdownMenuItem(
                                                child: Text('$item'),
                                                value: item);
                                          }).toList(),
                                        )))
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                const Text("SR"),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Obx(() => DropdownButton(
                                        value: controller.tempShot.value.sr,
                                        icon: const Icon(Icons.arrow_downward),
                                        elevation: 16,
                                        style: const TextStyle(
                                            color: Colors.deepPurple),
                                        underline: Container(
                                          height: 2,
                                          color: Colors.deepPurpleAccent,
                                        ),
                                        onChanged: (value) {
                                          controller.tempShot.update((shot) {
                                            shot?.sr =
                                                int.parse(value.toString());
                                          });
                                        },
                                        isExpanded: true,
                                        items: freqs.map((item) {
                                          return DropdownMenuItem(
                                              child: Text('${item}Hz'),
                                              value: item);
                                        }).toList()
                                        // items: [

                                        //   DropdownMenuItem(
                                        //       child: Text("1, 2, 5"), value: 1),
                                        //   DropdownMenuItem(
                                        //       child: Text("10"), value: 10)
                                        // ],
                                        )))
                              ],
                            ),
                            // width: 100,
                            // height: 50,
                            // child: DropdownButtonFormField(
                            //     value: 900,
                            //     isExpanded: true,
                            //     items: freqs.map((element) {
                            //       return DropdownMenuItem(
                            //           child: Text('${element}Hz'),
                            //           value: element);
                            //     }).toList(),
                            //     onChanged: controller.changeFreq)
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Obx(() => controller.isStarted.value
                          ? const Center(child: CircularProgressIndicator())
                          : (controller.tempShot.value.shotData!.isNotEmpty
                              ? _buildChart()
                              : const Center(child: Text("No Data")))),
                      // controller.tempShot.value.shotData!.isNotEmpty
                      //     ? _buildChart()
                      //     : Center(
                      //         child: controller.isStarted.value
                      //             ? const CircularProgressIndicator()
                      //             : const Text("No Data")))
                      // controller.isStarted.value
                      //     ? (controller.tempShot.value.shotData!.isNotEmpty
                      //         ? _buildChart()
                      //         : const Center(
                      //             child: CircularProgressIndicator()))
                      //     : const Center(
                      //         child: Text("No Data"),
                      //       ))
                      // controller.tempShot.value.shotData!.isEmpty
                      //     ? const Center(child: Text("No Data"))
                      //     : (controller.isStarted.value == true
                      //         ? const Center(
                      //             child: CircularProgressIndicator())
                      //         : _buildChart()))
                    ),
                    Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: ElevatedButton(
                              onPressed: controller.isBusy.value
                                  ? null
                                  : controller.saveShot,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  controller.isBusy.value
                                      ? const CircularProgressIndicator()
                                      : const Icon(Icons.save,
                                          size: 20, color: ets_white),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Save Shot",
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: ets_white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              )),
                        )),
                    Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Obx(() => infoWidget(
                                //     key: "Line#",
                                //     value: controller.line.value.toString(),
                                //     index: 3)),
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Obx(() => infoWidget(
                                            key: "Line#",
                                            value: controller
                                                .tempShot.value.line
                                                .toString(),
                                            index: 1)))),
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Obx(
                                          () => infoWidget(
                                            key: "Total shots",
                                            value: controller.totalShots.value
                                                .toString(),
                                          ),
                                        ))),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Obx(() => infoWidget(
                                            key: "Shot#",
                                            value: controller
                                                .tempShot.value.shot
                                                .toString(),
                                            index: 2)))),
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: Obx(() => infoWidget(
                                              key: "Dist Moved",
                                              value:
                                                  "${controller.distMoved.value}m",
                                            )))),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: Obx(() => infoWidget(
                                            key: "Notes",
                                            value:
                                                controller.tempShot.value.notes,
                                            index: 3)))),
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: infoWidget(
                                            key: "GPS", value: "+/-"))),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        )),
                  ],
                ))));
  }

  Widget topCards(var index, var gradientColor1, var gradientColor2,
      Widget icon, Widget child) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            isScrollControlled: true,
            context: Get.context!,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)),
            ),
            builder: (BuildContext ctx) {
              return Padding(
                  padding: MediaQuery.of(Get.context!).viewInsets,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: CustomTextFormField(
                              // label: ,
                              initialValue: controller.initialValue(index),
                              onChange: (value) {
                                // controller.tempContent[index] = value;
                                controller.changeTopCards(index, value);
                              },
                            )),
                        // IconButton(
                        //     icon: const Icon(Icons.save),
                        //     onPressed: () {
                        //       Navigator.pop(ctx);
                        //       // controller.saveContent(index);
                        //     })
                      ]));
            });
      },
      child: Container(
        decoration: gradientBoxDecoration(
            showShadow: true,
            gradientColor1: gradientColor1,
            gradientColor2: gradientColor2),
        padding: const EdgeInsets.all(5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            icon,
            const SizedBox(
              width: 8,
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(LineChartData(
      minY: 0.0,
      minX: 0.0,
      maxX: 16384,
      titlesData: FlTitlesData(show: false),
      lineTouchData: LineTouchData(enabled: false),
      lineBarsData: [
        LineChartBarData(
          color: const Color(0x5F578DB1),
          spots: controller.spotData,
          dotData: FlDotData(show: false),
        )
      ],
    ));
  }

  Widget infoWidget({var index = 0, var key, var value}) {
    return GestureDetector(
        onTap: index != 0
            ? () {
                showModalBottomSheet(
                    isScrollControlled: true,
                    context: Get.context!,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0)),
                    ),
                    builder: (BuildContext ctx) {
                      return Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(8),
                                    child: index < 3
                                        ? Obx(() => SpinBox(
                                            min: 0,
                                            max: 9999,
                                            value: index == 1
                                                ? controller.tempShot.value.line
                                                        ?.toDouble() ??
                                                    0
                                                : controller.tempShot.value.shot
                                                        ?.toDouble() ??
                                                    0,
                                            onChanged: (value) {
                                              controller.changeBottomCards(
                                                  index, value);
                                            }))
                                        : Obx(() => CustomTextFormField(
                                              label: key,
                                              initialValue: controller
                                                  .tempShot.value.notes,
                                              onChange: (value) {
                                                controller.tempShot.value
                                                    .notes = value;
                                              },
                                            ))),
                                IconButton(
                                    icon: const Icon(
                                      Icons.save,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      // controller.saveContent(index);
                                    })
                              ]));
                    });
              }
            : null,
        child: Container(
            // width: Get.width / 2 - 30,
            decoration: index != 0
                ? gradientBoxDecoration(
                    showShadow: true,
                    gradientColor1: ets_white,
                    gradientColor2: ets_white)
                : gradientBoxDecoration(
                    showShadow: false,
                    gradientColor1: const Color(0xFF263238),
                    gradientColor2: const Color(0xFF263238),
                  ),
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(key + ": ",
                    style: const TextStyle(
                        color: ets_color_orange_gradient1,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                Text(value,
                    style: const TextStyle(
                        color: ets_color_orange_gradient2,
                        fontSize: 13,
                        fontWeight: FontWeight.bold))
              ],
            )));
  }

  // @override
  // Widget build(BuildContext context) {
  //   final topStyle =
  //       const TextStyle(color: ets_white, fontWeight: FontWeight.bold);
  //   final saveStyle = const TextStyle(color: Color(0xFF212121));
  //   final gains = [1, 2, 5, 10];
  //   final freqs = [900, 1800, 3600, 7200, 14400];
  //   return SafeArea(
  //       child: Scaffold(
  //           key: controller.scaffoldKey,
  //           extendBodyBehindAppBar: true,
  //           appBar: AppBar(
  //             leading: IconButton(
  //               icon: const Icon(Icons.menu),
  //               onPressed: () {
  //                 controller.openDrawer();
  //               },
  //             ),
  //             actions: [
  //               // IconButton(icon: Icon(Icons.bluetooth_disabled), onPressed: () {}),
  //               PopupMenuButton<int>(
  //                 color: Colors.grey,
  //                 offset: const Offset(0, 10),
  //                 onSelected: controller.onAction,
  //                 itemBuilder: (context) => [
  //                   PopupMenuItem(
  //                       value: 1,
  //                       child: Row(children: [
  //                         const Icon(Icons.bluetooth),
  //                         const SizedBox(width: 10),
  //                         const Text("Bluetooth")
  //                       ])),
  //                   PopupMenuItem(
  //                       value: 2,
  //                       child: Row(children: [
  //                         const Icon(Icons.share),
  //                         const SizedBox(width: 10),
  //                         const Text("Share")
  //                       ]))
  //                 ],
  //               )
  //               // IconButton(
  //               //     icon: Icon(Icons.bluetooth_connected), onPressed: controller.startBluetooth),
  //             ],
  //             title: Text('ETS'),
  //             centerTitle: false,
  //           ),
  //           drawer: Drawer(
  //             child: ListView(
  //               padding: EdgeInsets.zero,
  //               children: <Widget>[
  //                 DrawerHeader(
  //                   child: Text('ETS'),
  //                   decoration: BoxDecoration(
  //                     color: Colors.blue,
  //                   ),
  //                 ),
  //                 ListTile(
  //                     leading: Icon(Icons.task),
  //                     title: Text('Project'),
  //                     onTap: () {
  //                       controller.closeDrawer();
  //                       Get.toNamed("/project");
  //                     })
  //               ],
  //             ),
  //           ),
  //           body: Container(
  //               width: Get.width,
  //               height: Get.height,
  //               margin: EdgeInsets.all(10),
  //               padding: EdgeInsets.only(top: 50),
  //               child: Column(
  //                 // padding: EdgeInsets.only(top: 50),
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Expanded(
  //                       flex: 1,
  //                       child: Padding(
  //                           padding: EdgeInsets.only(bottom: 5),
  //                           child: topCards(
  //                               0,
  //                               ets_color_blue_gradient1,
  //                               ets_color_blue_gradient2,
  //                               Icon(Icons.task, color: ets_white, size: 25),
  //                               Column(
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   FittedBox(
  //                                       child:
  //                                           Text("Project", style: topStyle)),
  //                                   SizedBox(
  //                                     height: 2,
  //                                   ),
  //                                   Obx(() => Text(controller.projectName.value,
  //                                       style: saveStyle)),
  //                                 ],
  //                               )))),
  //                   Expanded(
  //                     flex: 1,
  //                     child: Padding(
  //                         padding: EdgeInsets.only(bottom: 5),
  //                         child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                           children: [
  //                             Center(
  //                                 child: topCards(
  //                                     1,
  //                                     ets_color_blue_gradient1,
  //                                     ets_color_blue_gradient2,
  //                                     Icon(Icons.person,
  //                                         color: ets_white, size: 25),
  //                                     Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Text("User", style: topStyle),
  //                                         SizedBox(
  //                                           height: 2,
  //                                         ),
  //                                         Obx(() => Text(
  //                                             controller.userName.value,
  //                                             style: saveStyle)),
  //                                       ],
  //                                     ))),
  //                             Center(
  //                                 child: topCards(
  //                                     2,
  //                                     ets_color_blue_gradient1,
  //                                     ets_color_blue_gradient2,
  //                                     Icon(Icons.task,
  //                                         color: ets_white, size: 25),
  //                                     Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Text("SensorID", style: topStyle),
  //                                         SizedBox(
  //                                           height: 2,
  //                                         ),
  //                                         Obx(() => Text(
  //                                             controller.sensorID.value,
  //                                             style: saveStyle)),
  //                                       ],
  //                                     ))),
  //                           ],
  //                         )),
  //                   ),
  //                   Expanded(
  //                     flex: 1,
  //                     child: Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Expanded(
  //                             flex: 1,
  //                             child: Obx(() => IconButton(
  //                                 onPressed: controller.isStarted.value
  //                                     ? null
  //                                     : controller.start,
  //                                 icon: Icon(
  //                                   controller.isStarted.value
  //                                       ? Icons.stop
  //                                       : Icons.play_arrow,
  //                                   color: controller.isStarted.value
  //                                       ? Color(0xFFF44336)
  //                                       : Color(0xFF2196F3),
  //                                   size: 50,
  //                                 )))),
  //                         Expanded(
  //                           flex: 1,
  //                           child: Row(
  //                             children: [
  //                               Text("Gain"),
  //                               SizedBox(width: 10),
  //                               Expanded(
  //                                   child: Obx(() => DropdownButton(
  //                                         value: controller.gain.value,
  //                                         icon:
  //                                             const Icon(Icons.arrow_downward),
  //                                         elevation: 16,
  //                                         style: const TextStyle(
  //                                             color: Colors.deepPurple),
  //                                         underline: Container(
  //                                           height: 2,
  //                                           color: Colors.deepPurpleAccent,
  //                                         ),
  //                                         onChanged: controller.changeGain,
  //                                         isExpanded: true,
  //                                         items: gains.map((item) {
  //                                           return DropdownMenuItem(
  //                                               child: Text('$item'),
  //                                               value: item);
  //                                         }).toList(),
  //                                       )))
  //                             ],
  //                           ),
  //                         ),
  //                         Expanded(
  //                           flex: 1,
  //                           child: Row(
  //                             children: [
  //                               Text("SR"),
  //                               SizedBox(width: 10),
  //                               Expanded(
  //                                   child: Obx(() => DropdownButton(
  //                                       value: controller.freq.value,
  //                                       icon: const Icon(Icons.arrow_downward),
  //                                       elevation: 16,
  //                                       style: const TextStyle(
  //                                           color: Colors.deepPurple),
  //                                       underline: Container(
  //                                         height: 2,
  //                                         color: Colors.deepPurpleAccent,
  //                                       ),
  //                                       onChanged: controller.changeFreq,
  //                                       isExpanded: true,
  //                                       items: freqs.map((item) {
  //                                         return DropdownMenuItem(
  //                                             child: Text('${item}Hz'),
  //                                             value: item);
  //                                       }).toList()
  //                                       // items: [

  //                                       //   DropdownMenuItem(
  //                                       //       child: Text("1, 2, 5"), value: 1),
  //                                       //   DropdownMenuItem(
  //                                       //       child: Text("10"), value: 10)
  //                                       // ],
  //                                       )))
  //                             ],
  //                           ),
  //                           // width: 100,
  //                           // height: 50,
  //                           // child: DropdownButtonFormField(
  //                           //     value: 900,
  //                           //     isExpanded: true,
  //                           //     items: freqs.map((element) {
  //                           //       return DropdownMenuItem(
  //                           //           child: Text('${element}Hz'),
  //                           //           value: element);
  //                           //     }).toList(),
  //                           //     onChanged: controller.changeFreq)
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   Expanded(
  //                       flex: 5,
  //                       child: Obx(() => controller.dataSource.isEmpty
  //                           ? Center(child: Text("No Data"))
  //                           : (controller.isStarted.value
  //                               ? Center(child: CircularProgressIndicator())
  //                               : _buildChart()))),
  //                   Expanded(
  //                       flex: 1,
  //                       child: Padding(
  //                         padding: EdgeInsets.symmetric(
  //                             vertical: 10, horizontal: 20),
  //                         child: ElevatedButton(
  //                             onPressed: controller.saveShot,
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(Icons.save, size: 20, color: ets_white),
  //                                 SizedBox(
  //                                   width: 10,
  //                                 ),
  //                                 Text(
  //                                   "Save Shot",
  //                                   style: TextStyle(
  //                                       fontSize: 16,
  //                                       color: ets_white,
  //                                       fontWeight: FontWeight.bold),
  //                                 )
  //                               ],
  //                             )),
  //                       )),
  //                   Expanded(
  //                       flex: 2,
  //                       child: Column(
  //                         children: [
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               // Obx(() => infoWidget(
  //                               //     key: "Line#",
  //                               //     value: controller.line.value.toString(),
  //                               //     index: 3)),
  //                               Expanded(
  //                                   flex: 3,
  //                                   child: Padding(
  //                                       padding: EdgeInsets.only(right: 10),
  //                                       child: Obx(() => infoWidget(
  //                                           key: "Line#",
  //                                           value: controller.line.value
  //                                               .toString(),
  //                                           index: 3)))),
  //                               Expanded(
  //                                   flex: 3,
  //                                   child: Padding(
  //                                       padding: EdgeInsets.only(left: 10),
  //                                       child: Obx(
  //                                         () => infoWidget(
  //                                           key: "Total shots",
  //                                           value: controller.totalShots.value
  //                                               .toString(),
  //                                         ),
  //                                       ))),
  //                             ],
  //                           ),
  //                           SizedBox(
  //                             height: 5,
  //                           ),
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Expanded(
  //                                   flex: 3,
  //                                   child: Padding(
  //                                       padding: EdgeInsets.only(right: 10),
  //                                       child: Obx(() => infoWidget(
  //                                           key: "Shot#",
  //                                           value: controller.shots.value
  //                                               .toString(),
  //                                           index: 4)))),
  //                               Expanded(
  //                                   flex: 3,
  //                                   child: Padding(
  //                                       padding: EdgeInsets.only(left: 10),
  //                                       child: Obx(() => infoWidget(
  //                                             key: "Dist Moved",
  //                                             value:
  //                                                 "${controller.distMoved.value}m",
  //                                           )))),
  //                             ],
  //                           ),
  //                           SizedBox(
  //                             height: 5,
  //                           ),
  //                           Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               Expanded(
  //                                   flex: 3,
  //                                   child: Padding(
  //                                       padding: EdgeInsets.only(right: 10),
  //                                       child: Obx(() => infoWidget(
  //                                           key: "Notes",
  //                                           value: controller.notes.value,
  //                                           index: 4)))),
  //                               Expanded(
  //                                   flex: 3,
  //                                   child: Padding(
  //                                       padding: EdgeInsets.only(left: 10),
  //                                       child: infoWidget(
  //                                           key: "GPS", value: "+/-"))),
  //                             ],
  //                           ),
  //                           SizedBox(
  //                             height: 5,
  //                           ),
  //                         ],
  //                       )),
  //                 ],
  //               ))));
  // }

}
