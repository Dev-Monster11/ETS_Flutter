// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';

// // import 'package:blemulator/blemulator.dart';
// // import 'package:counts_pro/services/bluetooth_fake.dart';

// import 'package:get/get.dart';

// const String SERVICE_UUID = "0000fe84-0000-1000-8000-00805f9b34fb";
// const String CHARACTERISTIC_UUID = "2d30c082-f39f-4ce6-923f-3484ea480596";

// class BluetoothService extends GetxService {
//   var _bluetoothState = BluetoothState.UNKNOWN;
//   var _scanStatus = BluetoothScanStatus.UNAVAILABLE;
//   var _deviceStatus = BluetoothDeviceStatus.UNAVAILABLE;
//   var _discoveredScanResults = <DiscoveredScanResult>[];
//   Timer? _scanTimer;
//   Peripheral? _connectedPeripheral;
//   var _stayConnected = false;
//   var deviceHungUp = false;
//   var _showingHangupAlert = false;
//   var _needsScan = false;
//   StreamSubscription? monitorSubscription;
//   get bluetoothState => _bluetoothState;
//   get scanStatus => _scanStatus;
//   get deviceStatus => _deviceStatus;
//   Peripheral? get connectedPeripheral => _connectedPeripheral;
//   get hasConnectedPeripheral => _connectedPeripheral != null;
//   List<DiscoveredScanResult> get discoveredScanResults =>
//       _discoveredScanResults;
//   get mayScan =>
//       !showingHangupAlert; // We might have other criteria for this in the future

//   bool get needsScan => _needsScan;
//   set needsScan(bool _) {
//     _needsScan = _;
//     if (mayScan) {
//       startScan();
//     }
//     // notifyListeners();
//   }

//   bool get showingHangupAlert => _showingHangupAlert;
//   set showingHangupAlert(bool _) {
//     _showingHangupAlert = _;
//     if (mayScan && needsScan) {
//       startScan();
//     }
//     // notifyListeners();
//   }
//   void onInit() async {
//     // Blemulator blemulator = Blemulator();
//     // blemulator.addSimulatedPeripheral(Meter());
//     // blemulator.simulate();

//     await BleManager().createClient();
//     BleManager().observeBluetoothState().listen((btState) async {
//       _setBluetoothState(btState);
//     });
//   }


//   _peripheralDiscovered(ScanResult scanResult) {
//     // Check for duplicates and remove from list, replacing with more recently found result
//     if (_discoveredScanResults
//         .map((dsr) => dsr.scanResult.peripheral.identifier)
//         .contains(scanResult.peripheral.identifier)) {
//       _discoveredScanResults.removeWhere((dsr) =>
//           dsr.scanResult.peripheral.identifier ==
//           scanResult.peripheral.identifier);
//     }
//     _discoveredScanResults.add(DiscoveredScanResult(
//       scanResult: scanResult,
//       afterInitialized: () {
//         // notifyListeners();
//       },
//     ));

//     // notifyListeners();
//   }

//   _setBluetoothState(BluetoothState btState) {
//     if (_bluetoothState != btState) {
//       _bluetoothState = btState;
//       if (btState == BluetoothState.POWERED_ON) {
//         _scanStatus = BluetoothScanStatus.IDLE;
//         // Automatically start scanning if bluetooth becomes available
//         startScan();
//       } else {
//         stopScan();
//         _scanStatus = BluetoothScanStatus.UNAVAILABLE;
//       }
//       // notifyListeners();
//     }
//   }

//   _readStream(Stream<Uint8List> list) async {
//     try {
//       // monitorSubscription = list.map(_parsePacket).listen((event) {
//       //   // print(event);
//       //   _surveyService.logDataEntry(
//       //       countA: event['countA'],
//       //       countB: event['countB'],
//       //       deviceTime: event['microseconds']);
//       // });

//     } catch (exception, stackTrace) {
//       print(exception.toString());
//       // Sentry.Sentry.captureException(exception, stackTrace: stackTrace);
//     }
//   }

//   Map<String, dynamic> _parsePacket(Uint8List list) {
//     int microseconds = list.buffer.asUint64List(0, 1).first;

//     var list32 = list.buffer.asUint32List(12, 2);
//     int countA = list32.last;
//     int countB = list32.first;
//     return {"microseconds": microseconds, "countA": countA, "countB": countB};
//   }

//   _setConnectedPeripheral(Peripheral? peripheral) async {
//     try {
//       if (await connectedPeripheral?.isConnected() ?? false) {
//         await connectedPeripheral?.disconnectOrCancelConnection();
//       }
//     } catch (exception, stackTrace) {
//       print(exception.toString());
//     }

//     _connectedPeripheral = peripheral;
//     if (peripheral == null) {
//       // DeviceService().clearDevice();
//     } else {
//       await monitorSubscription?.cancel();
//       stopScan();
//       try {
//         await peripheral.discoverAllServicesAndCharacteristics();

//         _readStream(peripheral
//             .monitorCharacteristic(SERVICE_UUID, CHARACTERISTIC_UUID)
//             .map((event) => event.value));
//       } catch (exception, stackTrace) {
//         print(exception.toString());
//         // Sentry.Sentry.captureException(exception, stackTrace: stackTrace);
//       }
//       // DeviceService().loadDeviceWithUUID(peripheral.identifier);
//     }
//   }

//   startScan() async {
//     _scanTimer?.cancel();
//     _stayConnected = false;
//     deviceHungUp = false;
//     try {
//       if (await connectedPeripheral?.isConnected() ?? false) {
//         await connectedPeripheral?.disconnectOrCancelConnection();
//       }
//     } catch (exception, stackTrace) {
//       print(exception.toString());
//       // Sentry.Sentry.captureException(exception, stackTrace: stackTrace);
//     }
//     _scanStatus = BluetoothScanStatus.SCANNING;
//     _discoveredScanResults = [];

//     // Only scan for 30 seconds
//     var endTime = DateTime.now().add(Duration(seconds: 30));
//     performScan();
//     _scanTimer = Timer.periodic(Duration(seconds: 5), (timer) {
//       if (DateTime.now().isAfter(endTime)) {
//         stopScan();
//       } else {
//         performScan();
//       }
//     });

//     // notifyListeners();
//   }

//   performScan() async {
//     await BleManager().stopPeripheralScan();
//     BleManager().startPeripheralScan(uuids: ["FE84"]).listen((scanResult) {
//       _peripheralDiscovered(scanResult);
//     });
//   }

//   stopScan() {
//     _scanTimer?.cancel();
//     BleManager().stopPeripheralScan();
//     _scanStatus = BluetoothScanStatus.IDLE;
//     // notifyListeners();
//   }

//   connectToPeripheral(Peripheral peripheral) async {
//     _stayConnected = false;
//     if (_connectedPeripheral != null &&
//         _connectedPeripheral?.identifier != peripheral.identifier) {
//       // Trying to connect to a new peripheral - disconnect from old one
//       await _connectedPeripheral?.disconnectOrCancelConnection();
//     }
//     // Trying to connect to peripheral that's already connected causes a crash
//     var connected = await peripheral.isConnected();
//     if (!connected) {
//       peripheral
//           .observeConnectionState(completeOnDisconnect: true)
//           .listen((connectionState) {
//         if (connectionState == PeripheralConnectionState.connected) {
//           _setConnectedPeripheral(peripheral);
//           _deviceStatus = BluetoothDeviceStatus.CONNECTED;
//           _stayConnected = true;
//         } else if (connectionState == PeripheralConnectionState.connecting) {
//           _deviceStatus = BluetoothDeviceStatus.CONNECTING;
//           _setConnectedPeripheral(null);
//         } else if (connectionState == PeripheralConnectionState.disconnecting) {
//           _deviceStatus = BluetoothDeviceStatus.DISCONNECTING;
//           _setConnectedPeripheral(null);
//         } else if (connectionState == PeripheralConnectionState.disconnected) {
//           if (_stayConnected &&
//               _deviceStatus != BluetoothDeviceStatus.DISCONNECTED) {
//             // Device is unexpectedly disconnecting
//             deviceHungUp = true;
//             // _showHangupNotification();
//           }
//           // End any active survey if there is one
//           _deviceStatus = BluetoothDeviceStatus.DISCONNECTED;
//           _setConnectedPeripheral(null);
//         }
//         // notifyListeners();
//       });
//       peripheral.connect(timeout: Duration(seconds: 10));
//     }
//   }
// }

// class DiscoveredScanResult {
//   final ScanResult scanResult;
//   final Function afterInitialized;
//   Device? device;

//   get title => device?.name ?? scanResult.peripheral.identifier;
//   get subtitle => device?.serial ?? '';

//   DiscoveredScanResult(
//       {required this.scanResult, required this.afterInitialized}) {
//     _initialize();
//   }

//   _initialize() async {
//     // Look for a saved device with scanResult's UUID
//     device = await Device().withUUID(scanResult.peripheral.identifier);
//     afterInitialized();
//   }
// }

// enum BluetoothScanStatus { UNAVAILABLE, IDLE, SCANNING }

// enum BluetoothDeviceStatus {
//   UNAVAILABLE,
//   DISCONNECTED,
//   CONNECTING,
//   CONNECTED,
//   DISCONNECTING
// }
