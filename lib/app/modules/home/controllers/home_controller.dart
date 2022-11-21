import 'dart:async';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:csv/csv.dart';
import 'package:archive/archive_io.dart';
import '../shot_model.dart';
import 'dart:io';
import 'dart:math';
import '../../widgets/custom_textfield.dart';
import '../project_model.dart';

const String SERVICE_UUID = "0000fe84-0000-1000-8000-00805f9b34fb";
const String CHARACTERISTIC_UUID = "2d30c082-f39f-4ce6-923f-3484ea480596";
const MAX_COUNT = 16384;

class HomeController extends GetxController {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final project = Project(name: '', shots: []).obs;

  final shots = <Shot>[].obs;
  final totalShots = 0.obs;
  final isBusy = false.obs;
  late LocationData basePoint;
  final location = Location();
  final tempShot = Shot(
      gain: 1,
      timestamp: DateTime.now(),
      user: "",
      sensorID: "",
      line: 1,
      shot: 1,
      sr: 900,
      lat: 0,
      lon: 0,
      gpsAcc: 10,
      notes: "",
      shotData: []).obs;
  final isStarted = false.obs;
  final count = 0.obs;
  final distMoved = 0.0.obs;

  final projectName = ''.obs;
  final fileList = [].obs;
  final distanceCalc = false.obs;
  final spotData = <FlSpot>[].obs;
  final devices = [].obs;
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  // Timer? timer;

  // StreamSubscription? monitorSubscription;
  BluetoothCharacteristic? handle;
  // Bluetooth_Service? service;

  @override
  void onInit() {
    super.onInit();
    // tempContent[0] = projectName.value;
    // tempContent[1] = userName.value;
    // tempContent[2] = sensorID.value;
  }

  @override
  void onReady() async {
    super.onReady();
    Future.delayed(const Duration(seconds: 3)).then((value) {
      FlutterNativeSplash.remove();
    });
    bool _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        Get.snackbar('Warning', 'Location Service must be enabled');
      }
    }

    PermissionStatus _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        Get.snackbar('Warning', 'Locatin Permission must be granted');
      }
    }
    basePoint = await location.getLocation();

    // if (defaultTargetPlatform == TargetPlatform.android) {
    //   locationSettings = AndroidSettings(
    //       accuracy: LocationAccuracy.high,
    //       distanceFilter: 100,
    //       forceLocationManager: true,
    //       intervalDuration: const Duration(seconds: 10),
    //       //(Optional) Set foreground notification config to keep the app alive
    //       //when going to the background
    //       foregroundNotificationConfig: const ForegroundNotificationConfig(
    //         notificationText:
    //             "Example app will continue to receive your location even when you aren't using it",
    //         notificationTitle: "Running in Background",
    //         enableWakeLock: true,
    //       ));
    // } else if (defaultTargetPlatform == TargetPlatform.iOS ||
    //     defaultTargetPlatform == TargetPlatform.macOS) {
    //   locationSettings = AppleSettings(
    //     accuracy: LocationAccuracy.high,
    //     activityType: ActivityType.fitness,
    //     distanceFilter: 100,
    //     pauseLocationUpdatesAutomatically: true,
    //     // Only set to true if our app will be started up in the background.
    //     showBackgroundLocationIndicator: false,
    //   );
    // } else {
    //   locationSettings = LocationSettings(
    //     accuracy: LocationAccuracy.high,
    //     distanceFilter: 100,
    //   );
    // }

    // StreamSubscription<Position> positionStream =
    //     Geolocator.getPositionStream(locationSettings: locationSettings)
    //         .listen((Position? position) {
    //   print(position == null
    //       ? 'Unknown'
    //       : '${position.latitude.toString()}, ${position.longitude.toString()}');
    // });
  }

  @override
  void onClose() {}

  List<FlSpot> chartSpot() {
    var result = <FlSpot>[];
    double index = 0;
    tempShot.value.shotData?.forEach((element) {
      result.add(FlSpot(index.toDouble(), element.toDouble()));
      index += 1;
    });
    return result;
  }

  String initialValue(int index) {
    if (index == 0) {
      return projectName.value;
    } else if (index == 1) {
      return tempShot.value.user ?? '';
    } else if (index == 2) {
      return tempShot.value.sensorID ?? '';
    }
    return '';
  }

  void changeBottomCards(int index, var value) async {
    if (index == 1) {
      tempShot.update((val) {
        val?.line = value.toInt();
      });
      // tempShot.value.line = value.toInt();
    } else {
      tempShot.update((val) {
        val?.shot = value.toInt();
      });
    }
  }

  void changeTopCards(int index, var value) {
    if (index == 0) {
      projectName.value = value;
    } else if (index == 1) {
      tempShot.update((val) {
        val?.user = value;
      });
      // tempShot.value.user = value;
    } else {
      tempShot.update((val) {
        val?.sensorID = value;
      });
    }
  }

  // _readStream(Stream<List<int>> list) async {
  //   try {
  //     print("Data Arrived");
  //     monitorSubscription = list.listen((event) {
  //       print('Event, ${event.length}');
  //       // if (event == 0) {
  //       // handle!.read().then((value) {
  //       //   print("Total Length is ${value.length}");
  //       // });
  //       // }
  //     });
  //   } catch (exception) {
  //     print('Read Stream Exception');
  //     print(exception.toString());
  //   }
  // }

  void start() {
    tempShot.update((val) {
      val?.shot = val.shot! + 1;
    });
    // tempShot.value.shot = tempShot.value.shot! + 1;
    isStarted.toggle();

    location.onLocationChanged.listen((data) {
      var lat1 = basePoint.latitude!;
      var lon1 = basePoint.longitude!;
      var lat2 = data.latitude!;
      var lon2 = data.longitude!;
      const r = 6371;
      var p = 0.017453292519943295;
      var a = 0.5 -
          cos((lat2 - lat1) * p) / 2 +
          cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
      distMoved.value = 2 * r * asin(sqrt(a));
      // distMoved.value = d;
    });
    // DaqDeviceController daq = Get.put(DaqDeviceController());
    if (isStarted.value == true) {
      // tempShot.value.shotData?.clear();
      var index = 0;
      handle?.value.listen((val) {
        for (var i = 0; i < val.length; i += 2) {
          isStarted.value = false;
          int value = val[i] * 256 + val[i + 1] - 32768;
          print("Inputed Value is ${value}");
          tempShot.value.shotData?.add(value);
          index++;
          spotData.add(FlSpot(index.toDouble(), value.toDouble()));
        }

        // print(String.fromCharCodes(val));
        // if ((tempShot.value.shotData?.length)! >= 0) {

        // }
      });
      handle?.write(Uint8List.fromList('Start'.codeUnits)).then((value) {
        // print("Write Result - --${value}");
        // _readStream(handle!.value);
        handle!.setNotifyValue(true);
      });

      // Future.delayed(const Duration(seconds: 1), () {

      // });

      // handle!.read().then((Uint8List value){
      //   print("Length is ${value.length}");
      //   print(String.fromCharCode(value));
      // })
      tempShot.update((val) {
        val?.shotData?.clear();
      });
      // dataSource.clear();
      // timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      //   count.value = count.value + 1;
      //   // dataSource.add(Point(count.value, Random().nextDouble() * 100));
      //   // if (count.value % 10 == 0) {
      //
      //   int value = Random().nextInt(32444);
      //   spotData.add(FlSpot(count.value.toDouble(), value.toDouble()));
      //   tempShot.update((shot) {
      //     shot?.shotData?.add(value);
      //   });
      //   // tempShot.value.shotData?.add(value);
      //   // dataSource.add(FlSpot(count.toDouble(), Random().nextDouble() * 100));
      //   // }
      //   if (count.value >= 16384) {
      //     print("Count is ${tempShot.value.shotData?.length}");
      //     isStarted.value = false;
      //     count.value = 0;
      //     timer.cancel();
      //   }
      // });
    } else {
      handle!.write(Uint8List.fromList('Stop'.codeUnits));
      handle!.setNotifyValue(false);
      count.value = 0;
    }
    // tempShot.value.shot = 1;
  }

  void saveShot() {
    isBusy.toggle();
    print("save shot---");
    writeETSFile().then((value) {
      fileList.add(value);
      shots.add(tempShot.value);
      tempShot.update((val) {
        val?.timestamp = DateTime.now();
        val?.user = "";
        val?.sensorID = "";
        val?.gain = 1;
        val?.sr = 900;
        val?.line = 1;
        val?.shot = 0;
        val?.lat = 0;
        val?.lon = 0;
        val?.gpsAcc = 0;
        val?.notes = "";
        val?.shotData = [];
      });
      Get.snackbar('Save', 'Successfuly saved to ${value.path}');
      isBusy.toggle();
      print("done---");
      totalShots.value = totalShots.value + 1;
    });
  }

  // void swipeChartData() {}

  // Future<String> createFolderInAppDocDir(String folderName) async {
  //   //Get this App Document Directory

  //   final Directory _appDocDir = await getApplicationDocumentsDirectory();
  //   //App Document Directory + folder name
  //   final Directory _appDocDirFolder =
  //       Directory('${_appDocDir.path}/$folderName/');

  //   if (await _appDocDirFolder.exists()) {
  //     //if folder already exists return path
  //     return _appDocDirFolder.path;
  //   } else {
  //     //if folder not exists create folder and then return its path
  //     final Directory _appDocDirNewFolder =
  //         await _appDocDirFolder.create(recursive: true);
  //     return _appDocDirNewFolder.path;
  //   }
  // }

  // void startBluetooth() async {
  //   handle = Get.toNamed('/daq-device') as Characteristic;
  // }

  List<List<dynamic>> metadata() {
    return [];
  }

  Future<File> writeETSFile() async {
    String path =
        "${(await getTemporaryDirectory()).path}/${projectName.value}";
    Directory dir = Directory(path);

    dir.createSync();

    File file = File('$path/${tempShot.value.shot}.ets');
    if (await file.exists()) await file.delete();
    var bytes = <int>[];
    int temp;
    for (int i = 0; i < tempShot.value.shotData!.length; i++) {
      temp = tempShot.value.shotData![i];
      bytes.add(temp >> 8 & 0xFF);
      bytes.add(temp & 0x00FF);
      var stringToWrite = "${tempShot.value.shotData![i]}\r\n";
      await file.writeAsString(stringToWrite, mode: FileMode.append);
    }
    file.writeAsBytesSync(bytes);

    return file;
  }

  void startScan() async {
    flutterBlue.startScan(timeout: const Duration(seconds: 5));
    List<BluetoothDevice> ds = await flutterBlue.connectedDevices;
    for (var element in ds) {
      element.disconnect();
    }
    devices.clear();
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (devices
            .map((e) => e.id.toString())
            .contains(r.device.id.toString())) continue;
        if (r.device.name.contains('DAQ') == false) continue;
        devices.add(r.device);
      }
    });
  }

  Future<File> writeCSVFile() async {
    String path =
        "${(await getTemporaryDirectory()).path}/${projectName.value}";

    Directory dir = Directory(path);
    dir.createSync();
    File file = File('$path/ets-metadata.csv');
    if (await file.exists()) await file.delete();
    List<List<String>> csvData = [
      [
        '#',
        'TimeStamp',
        'User',
        'SensorID',
        'Gain',
        'SR',
        'Line#',
        'Sta#',
        'Lat',
        'Lon',
        'GPSAcc',
        'Notes'
      ]
    ];
    for (int i = 0; i < shots.length; i++) {
      var temp = <String>[];
      temp.add("${i + 1}");
      temp.add(shots[i].timestamp.toString());
      temp.add(shots[i].user ?? "");
      temp.add(shots[i].sensorID ?? "");
      temp.add(shots[i].gain.toString());
      temp.add(shots[i].sr.toString());
      temp.add(shots[i].line.toString());
      temp.add(shots[i].shot.toString());
      temp.add(shots[i].lat.toString());
      temp.add(shots[i].lon.toString());
      temp.add(shots[i].gpsAcc.toString());
      temp.add(shots[i].notes ?? "");
      csvData.add(temp);
    }
    file.writeAsString(const ListToCsvConverter().convert(csvData));

    // file.writeAsString(
    //     const ListToCsvConverter().convert(metadata() + "\r\n\r\n"));

    // for (int i = 0; i < shots.length; i++) {
    //   var stringToWrite = const ListToCsvConverter()
    //           .convert(tableData(dataEntries: entries, header: i == 0)) +
    //       "\r\n";
    //   await file.writeAsString(stringToWrite, mode: FileMode.append);
    // }
    return file;
  }

  void getHandle(id) async {
    BluetoothDevice device =
        devices.firstWhere((element) => element.id.toString() == id);
    await device.connect(
        timeout: const Duration(seconds: 10), autoConnect: false);
    List<BluetoothService> services = await device.discoverServices();
    BluetoothService ss = services
        .firstWhere((element) => element.uuid.toString() == SERVICE_UUID);
    var characteristics = ss.characteristics;
    BluetoothCharacteristic c = characteristics.firstWhere(
        (element) => element.uuid.toString() == CHARACTERISTIC_UUID);
    handle = c;
    print("------");
    print("Get Handle----${handle?.deviceId.toString()}");

    print("------");
  }

  void onAction(value) async {
    if (value == 2) {
      print("Email");
      // Directory project = await getTemporaryDirectory();
      // tempShot.update((value) {
      //   value?.shotData?.clear();
      // });
      // return;
      writeCSVFile().then((value) async {
        Get.snackbar("Save", "Meta data saved to ${value.path}");
        var encoder = ZipFileEncoder();
        var path =
            "${(await getTemporaryDirectory()).path}/${projectName.value}.zip";
        encoder.create(path);
        for (var element in fileList) {
          encoder.addFile(element);
        }
        encoder.addFile(value);
        encoder.close();
        Share.shareFiles([path]);
      });

//       final mailer = Mailer(
//           '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');
// //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
//       final toAddress = Address('softdrink1991@gmail.com');
//       final fromAddress = Address('mljhh@proton.me');
//       final content = Content('text/plain', 'Hello World!');
//       final subject = 'Hello Subject!';
//       final personalization = Personalization([toAddress]);

//       final email =
//           Email([personalization], fromAddress, subject, content: [content]);
//       mailer.send(email).then((result) {
//         print('Result is $result');
//         print('Result is ${result.toString()}');
//         print("Email Sent");
//       });
    } else if (value == 3) {
      Get.toNamed('/setting');
      return;
      // var dlgContent = SingleChildScrollView(
      //     child: SizedBox(
      //         width: Get.width * 0.8,
      //         height: Get.height * 0.4,
      //         child: Column(
      //           children: [
      //             Expanded(
      //                 flex: 1,
      //                 child: Column(
      //                     // crossAxisAlignment: CrossAxisAlignment.start,
      //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //                     children: [
      //                       CustomTextFormField(
      //                         onChange: (v) {
      //                           project.value.name = v;
      //                         },
      //                         prefixIcon: Icons.padding,
      //                         hintText: "Project",
      //                       ),
      //                       const SizedBox(height: 5),
      //                       CustomTextFormField(
      //                         prefixIcon: Icons.person,
      //                         hintText: "User",
      //                         onChange: (v) {
      //                           project.value.user = v;
      //                         },
      //                       ),
      //                       const SizedBox(height: 5),
      //                       Obx(() => DropdownButtonFormField<String>(
      //                             decoration: InputDecoration(
      //                                 prefixIcon: IconButton(
      //                                     icon: const Icon(Icons.refresh),
      //                                     onPressed: () async {
      //                                       startScan();
      //                                     })),
      //                             hint: const Text('Device'),
      //                             items: devices.map((e) {
      //                               return DropdownMenuItem<String>(
      //                                 value: e.id.toString(),
      //                                 child: Text(e.name),
      //                               );
      //                             }).toList(),
      //                             onChanged: (v) {
      //                               getHandle(v);
      //                               // service?.service?.handle(v!).then((value) {
      //                               //   p.handle = value;
      //                               // });
      //                             },
      //                           )),
      //                     ])),
      //             IntrinsicHeight(
      //                 child:
      //                     //  Container(color: Colors.black),
      //                     CustomTextFormField(
      //               hintText: "Notes",
      //               onChange: (v) {},
      //               maxLine: 3,
      //             )),
      //           ],
      //         )));

      // Get.defaultDialog(title: "Setting", content: dlgContent);

    }
  }

  void setSettings() {}

  void deviceDiscovered(BluetoothDevice device) {
    devices.add(device);
  }

  void saveDAQ() {
    handle?.write(Uint8List.fromList('Range${tempShot.value.gain}'.codeUnits));
    handle?.write(Uint8List.fromList('Rate${tempShot.value.sr}'.codeUnits));
    handle?.write(Uint8List.fromList('Trigger12345'.codeUnits));
    Get.back();
  }
}
