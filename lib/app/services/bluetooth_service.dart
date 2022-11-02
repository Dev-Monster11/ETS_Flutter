import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

const String SERVICE_UUID = "0000fe84-0000-1000-8000-00805f9b34fb";
const String CHARACTERISTIC_UUID = "2d30c082-f39f-4ce6-923f-3484ea480596";

typedef DeviceCallback = void Function(BluetoothDevice);

class Bluetooth_Service extends GetxService {
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> devices = [];
  final DeviceCallback deviceFound;
  Bluetooth_Service(this.deviceFound);

  void startScan() async {
    flutterBlue.startScan(timeout: const Duration(seconds: 5));
    List<BluetoothDevice> ds = await flutterBlue.connectedDevices;
    for (var element in ds) {
      element.disconnect();
    }
    devices.clear();
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
//     if (discoveredScanResults
//         .map((dsr) => dsr.identifier)
//         .contains(scanResult.peripheral.identifier)) {
        // ;
        if (devices
            .map((e) => e.id.toString())
            .contains(r.device.id.toString())) continue;
        if (r.device.name.contains('DAQ') == false) continue;
        devices.add(r.device);
        deviceFound(r.device);
        print(r.device.name);
      }
    });
  }

  Future<BluetoothCharacteristic> connectDevice(id) async {
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

    return c;
  }
}

// enum BluetoothScanStatus { UNAVAILABLE, IDLE, SCANNING }
// enum BluetoothDeviceStatus {
//   UNAVAILABLE,
//   DISCONNECTED,
//   CONNECTING,
//   CONNECTED,
//   DISCONNECTING
// }
// typedef DeviceCallback = void Function(Peripheral);

// class BluetoothService extends GetxService {
//   final bluetoothState = BluetoothState.UNKNOWN.obs;
//   final scanStatus = BluetoothScanStatus.UNAVAILABLE.obs;
//   final deviceStatus = BluetoothDeviceStatus.UNAVAILABLE.obs;
//   final discoveredScanResults = <Peripheral>[].obs;
//   Timer? scanTimer;
//   Peripheral? _connectedPeripheral;
//   final DeviceCallback discovered;
//   BluetoothService(this.discovered);

//   // static final _singleton = BluetoothService._instance();
//   // BluetoothService._instance() {
//   //   _initialize();
//   // }
//   // factory BluetoothService(this.discovered) {
//   //   return _singleton;
//   // }

//   @override
//   void onInit() {
//     super.onInit();
//   }

//   @override
//   void onReady() async {
//     super.onReady();
//   }

//   void init() async {
//     // Blemulator blemulator = Blemulator();
//     // blemulator.addSimulatedPeripheral(Meter());
//     // blemulator.simulate();

//     await BleManager().createClient();
//     BleManager().observeBluetoothState().listen((btState) async {
//       _setBluetoothState(btState);
//     });
//   }
//   // void scan() async{
//   //   await BleManager().createClient();
//   //   BleManager().observeBluetoothState().listen((btState) async {
//   //     _setBluetoothState(btState);
//   //   });
//   // }

//   void _setBluetoothState(BluetoothState btState) {
//     if (bluetoothState.value != btState) {
//       bluetoothState.value = btState;
//       // if (btState == BluetoothState.POWERED_ON) {
//       //   scanStatus.value = BluetoothScanStatus.IDLE;
//       //   // Automati cally start scanning if bluetooth becomes available
//       //   // startScan();
//       // } else {
//       //   stopScan();
//       //   scanStatus.value = BluetoothScanStatus.UNAVAILABLE;
//       // }
//     }
//   }

//   stopScan() {
//     scanTimer?.cancel();
//     BleManager().stopPeripheralScan();
//     scanStatus.value = BluetoothScanStatus.IDLE;
//   }

//   void startScan() async {
//     scanTimer?.cancel();
//     try {
//       if (await _connectedPeripheral?.isConnected() ?? false) {
//         await _connectedPeripheral?.disconnectOrCancelConnection();
//       }
//     } catch (exception) {
//       print(exception.toString());
//     }
//     scanStatus.value = BluetoothScanStatus.SCANNING;
//     discoveredScanResults.clear();
//     var endTime = DateTime.now().add(const Duration(seconds: 30));
//     performScan();
//     scanTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (DateTime.now().isAfter(endTime)) {
//         // print("start scan");
//         stopScan();
//       }
//     });
//   }

//   void performScan() async {
//     BleManager().startPeripheralScan().listen((scanResult) {
//       _peripheralDiscovered(scanResult);
//     });
//   }

//   _peripheralDiscovered(ScanResult scanResult) {
//     // Check for duplicates and remove from list, replacing with more recently found result
//     if (scanResult.peripheral.name == null ||
//         scanResult.peripheral.name!.isEmpty) return;
//     if (scanResult.peripheral.name!.contains('DAQ') == false) return;

//     discoveredScanResults.removeWhere((element) {
//       if (element.name == null || element.name!.isEmpty) return false;
//       return !(element.name!.contains('DAQ'));
//       // return element.name == null || element.name?.contains('DAQ')) ?? false;
//     });

//     // discoveredScanResults.where((p) => p.name?.contains('DAQ'));
//     if (discoveredScanResults
//         .map((dsr) => dsr.identifier)
//         .contains(scanResult.peripheral.identifier)) {
//       return;
//     }
//     discovered(scanResult.peripheral);

//     discoveredScanResults.add(scanResult.peripheral);
//     // print(scanResult.peripheral.identifier);
//     // notifyListeners();
//   }

//   Future<Characteristic?> handle(String uuid) async {
//     Peripheral peripheral = discoveredScanResults
//         .firstWhere((element) => element.identifier == uuid);
//     if (await _connectedPeripheral?.isConnected() ?? false) {
//       await _connectedPeripheral?.disconnectOrCancelConnection();
//     }
//     _connectedPeripheral = peripheral;

//     // stopScan();
//     try {
//       print("Connecting");
//       await peripheral.connect(timeout: const Duration(seconds: 5));
//       print("Connected");
//       await peripheral.discoverAllServicesAndCharacteristics();
//       List<Service> ss = await peripheral.services();
//       List<Characteristic> cs = await ss
//           .firstWhere((element) => element.uuid == SERVICE_UUID)
//           .characteristics();
//       print("Characteristic Count: ${cs.length}");
//       Characteristic? handle =
//           cs.firstWhere((element) => element.uuid == CHARACTERISTIC_UUID);
//       print("Handle count: ${handle.uuid}");
//       // handle!.write(Uint8List.fromList('Start'.codeUnits), false);
//       // _readStream(handle!.monitor());
//       return handle;
//       // Get.back();
//     } catch (exception) {
//       print(exception.toString());
//     }

//     return null;
//     // await peripheral.discoverAllServicesAndCharacteristics();
//     // List<Service> ss = await peripheral.services();
//     // List<Characteristic> cs = await ss
//     //     .firstWhere((element) => element.uuid == SERVICE_UUID)
//     //     .characteristics();
//     // Characteristic? handle =
//     //     cs.firstWhere((element) => element.uuid == CHARACTERISTIC_UUID);

//     // return handle;
//   }
//   // connectToPeripheral(Peripheral peripheral) async {
//   //   if (_connectedPeripheral != null &&
//   //       _connectedPeripheral?.identifier != peripheral.identifier) {
//   //     // Trying to connect to a new peripheral - disconnect from old one
//   //     await _connectedPeripheral?.disconnectOrCancelConnection();
//   //   }
//   //   // Trying to connect to peripheral that's already connected causes a crash
//   //   var connected = await peripheral.isConnected();
//   //   if (!connected) {
//   //     peripheral
//   //         .observeConnectionState(completeOnDisconnect: true)
//   //         .listen((connectionState) {
//   //       if (connectionState == PeripheralConnectionState.connected) {
//   //         _setConnectedPeripheral(peripheral);
//   //         _deviceStatus = BluetoothDeviceStatus.CONNECTED;
//   //         _stayConnected = true;
//   //       } else if (connectionState == PeripheralConnectionState.connecting) {
//   //         _deviceStatus = BluetoothDeviceStatus.CONNECTING;
//   //         _setConnectedPeripheral(null);
//   //       } else if (connectionState == PeripheralConnectionState.disconnecting) {
//   //         _deviceStatus = BluetoothDeviceStatus.DISCONNECTING;
//   //         _setConnectedPeripheral(null);
//   //       } else if (connectionState == PeripheralConnectionState.disconnected) {
//   //         if (_stayConnected &&
//   //             _deviceStatus != BluetoothDeviceStatus.DISCONNECTED) {
//   //           // Device is unexpectedly disconnecting
//   //           deviceHungUp = true;
//   //           _showHangupNotification();
//   //         }
//   //         // End any active survey if there is one
//   //         SurveyService().endSurvey();
//   //         _deviceStatus = BluetoothDeviceStatus.DISCONNECTED;
//   //         _setConnectedPeripheral(null);
//   //       }
//   //       notifyListeners();
//   //     });
//   //     peripheral.connect(timeout: Duration(seconds: 10));
//   //   }
//   // }
//   // _setConnectedPeripheral(Peripheral? peripheral) async {
//   //   try {
//   //     if (await connectedPeripheral?.isConnected() ?? false) {
//   //       await connectedPeripheral?.disconnectOrCancelConnection();
//   //     }
//   //   } catch (exception, stackTrace) {
//   //     Sentry.Sentry.captureException(exception, stackTrace: stackTrace);
//   //   }
//   //
//   //   _connectedPeripheral = peripheral;
//   //   if (peripheral == null) {
//   //     return;
//   //   } else {
//   //     await monitorSubscription?.cancel();
//   //     stopScan();
//   //     try {
//   //       _surveyService.resetCounts();
//   //       await peripheral.discoverAllServicesAndCharacteristics();
//   //
//   //       _readStream(peripheral
//   //           .monitorCharacteristic(SERVICE_UUID, CHARACTERISTIC_UUID)
//   //           .map((event) => event.value));
//   //     } catch (exception, stackTrace) {
//   //       Sentry.Sentry.captureException(exception, stackTrace: stackTrace);
//   //     }
//   //     DeviceService().loadDeviceWithUUID(peripheral.identifier);
//   //   }
//   // }
// }
