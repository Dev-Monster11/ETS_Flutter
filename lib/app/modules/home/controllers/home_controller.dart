import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';

import 'package:csv/csv.dart';
import 'package:archive/archive_io.dart';
import '../shot_model.dart';
import 'dart:io';
import 'dart:math';

class HomeController extends GetxController {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  final shots = <Shot>[].obs;
  final freq = 900.obs;
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

  Timer? timer;

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

  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.openEndDrawer();
  }

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
    print('--value$value');

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
  // void calcDistMoved(){

  // }
  void start() {
    tempShot.update((val) {
      val?.shot = val.shot! + 1;
    });
    // tempShot.value.shot = tempShot.value.shot! + 1;
    isStarted.toggle();
    // print("value---${isStarted.value}");
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
    if (isStarted.value == true) {
      // tempShot.value.shotData?.clear();
      tempShot.update((val) {
        val?.shotData?.clear();
      });
      // dataSource.clear();
      timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
        count.value = count.value + 1;
        // dataSource.add(Point(count.value, Random().nextDouble() * 100));
        // if (count.value % 10 == 0) {

        int value = Random().nextInt(32444);
        spotData.add(FlSpot(count.value.toDouble(), value.toDouble()));
        tempShot.update((shot) {
          shot?.shotData?.add(value);
        });
        // tempShot.value.shotData?.add(value);
        // dataSource.add(FlSpot(count.toDouble(), Random().nextDouble() * 100));
        // }
        if (count.value >= 16384) {
          print("Count is ${tempShot.value.shotData?.length}");
          isStarted.value = false;
          count.value = 0;
          timer.cancel();
        }
      });
    } else {
      count.value = 0;
      timer?.cancel();
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

  void startBluetooth() async {
    Get.toNamed('/daq-device');
  }

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

  void onAction(value) async {
    if (value == 1) {
      print("Bluetooth");
      startBluetooth();
    } else if (value == 2) {
      print("Email");
      // Directory project = await getTemporaryDirectory();
      tempShot.update((value) {
        value?.shotData?.clear();
      });
      return;
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
    }
  }
}
