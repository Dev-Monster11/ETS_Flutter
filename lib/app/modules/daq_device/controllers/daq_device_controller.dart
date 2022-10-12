import 'package:get/get.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'dart:async';
import 'dart:typed_data';

const String SERVICE_UUID = "00000001-710e-4a5b-8d75-3e5b444bc3cf";
const String CHARACTERISTIC_UUID = "00000002-710e-4a5b-8d75-3e5b444bc3cf";
enum BluetoothScanStatus { UNAVAILABLE, IDLE, SCANNING }
enum BluetoothDeviceStatus {
  UNAVAILABLE,
  DISCONNECTED,
  CONNECTING,
  CONNECTED,
  DISCONNECTING
}

class DaqDeviceController extends GetxController {
  //TODO: Implement DaqDeviceController
  final bluetoothState = BluetoothState.UNKNOWN.obs;
  final scanStatus = BluetoothScanStatus.UNAVAILABLE.obs;
  final deviceStatus = BluetoothDeviceStatus.UNAVAILABLE.obs;
  final discoveredScanResults = [].obs;
  Timer? scanTimer;
  Peripheral? _connectedPeripheral;
  StreamSubscription? monitorSubscription;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() async {
    super.onReady();

    await BleManager().createClient();
    BleManager().observeBluetoothState().listen((btState) async {
      _setBluetoothState(btState);
    });
  }

  @override
  void onClose() {}
  stopScan() {
    scanTimer?.cancel();
    BleManager().stopPeripheralScan();
    scanStatus.value = BluetoothScanStatus.IDLE;
  }

  _peripheralDiscovered(ScanResult scanResult) {
    // Check for duplicates and remove from list, replacing with more recently found result

    if (discoveredScanResults
        .map((dsr) => dsr.scanResult.peripheral.identifier)
        .contains(scanResult.peripheral.identifier)) {
      return;
      // _discoveredScanResults.removeWhere((dsr) =>
      //     dsr.scanResult.peripheral.identifier ==
      //     scanResult.peripheral.identifier);
    }
    discoveredScanResults.add(scanResult.peripheral);
    print(scanResult.peripheral.identifier);
    // notifyListeners();
  }

  _setConnectedPeripheral(Peripheral? peripheral) async {
    try {
      if (await _connectedPeripheral?.isConnected() ?? false) {
        await _connectedPeripheral?.disconnectOrCancelConnection();
      }
    } catch (exception, stackTrace) {
      print(exception.toString());
    }

    _connectedPeripheral = peripheral;
    if (peripheral != null) {
      //   // DeviceService().clearDevice();
      // } else {
      await monitorSubscription?.cancel();
      stopScan();
      try {
        // _surveyService.resetCounts();
        await peripheral.discoverAllServicesAndCharacteristics();

        _readStream(peripheral
            .monitorCharacteristic(SERVICE_UUID, CHARACTERISTIC_UUID)
            .map((event) => event.value));
      } catch (exception, stackTrace) {
        print(exception.toString());
      }
      // DeviceService().loadDeviceWithUUID(peripheral.identifier);
    }
  }

  _readStream(Stream<Uint8List> list) async {
    try {
      // await for (var characteristic in stream) {
      //   var list = characteristic.value;
      // list is 20 bytes long
      // 0-7: The counts.pro's uptime in microseconds
      // 8-11: A duplicate of the least-significant four bytes of the uptime (unused)
      // 12-15: counts from channel B
      // 16-19: counts from channel A

      // for (int a in list) {
      //   print(a.toRadixString(16));
      // }

      monitorSubscription = list.listen((event) {
        print(event);
        // print(event);
        // _surveyService.logDataEntry(
        //     countA: event['countA'],
        //     countB: event['countB'],
        //     deviceTime: event['microseconds']);
      });
      // int microseconds = list.buffer.asUint64List(0, 1).first;
      // var list32 = list.buffer.asUint32List(12, 2);
      // var countA = list32.last;
      // var countB = list32.first;
      // print('Count A is $countA');
      // print('Count B is $countB');
      // print('MicroSecons is $microseconds');
      // }
    } catch (exception, stackTrace) {
      print(exception.toString());
    }
  }

  connectToPeripheral(Peripheral peripheral) async {
    if (_connectedPeripheral != null &&
        _connectedPeripheral?.identifier != peripheral.identifier) {
      // Trying to connect to a new peripheral - disconnect from old one
      await _connectedPeripheral?.disconnectOrCancelConnection();
    }
    // Trying to connect to peripheral that's already connected causes a crash
    var connected = await peripheral.isConnected();
    if (!connected) {
      peripheral
          .observeConnectionState(completeOnDisconnect: true)
          .listen((connectionState) {
        if (connectionState == PeripheralConnectionState.connected) {
          _setConnectedPeripheral(peripheral);
          deviceStatus.value = BluetoothDeviceStatus.CONNECTED;
        } else if (connectionState == PeripheralConnectionState.connecting) {
          deviceStatus.value = BluetoothDeviceStatus.CONNECTING;
          _setConnectedPeripheral(null);
        } else if (connectionState == PeripheralConnectionState.disconnecting) {
          deviceStatus.value = BluetoothDeviceStatus.DISCONNECTING;
          _setConnectedPeripheral(null);
        } else if (connectionState == PeripheralConnectionState.disconnected) {
          // if (deviceStatus.value != BluetoothDeviceStatus.DISCONNECTED) {
          //   // Device is unexpectedly disconnecting
          //   deviceHungUp = true;
          //   _showHangupNotification();
          // }
          // // End any active survey if there is one
          // SurveyService().endSurvey();
          deviceStatus.value = BluetoothDeviceStatus.DISCONNECTED;
          _setConnectedPeripheral(null);
        }
        // notifyListeners();
      });
      peripheral.connect(timeout: const Duration(seconds: 10));
    }
  }

  void startScan() async {
    scanTimer?.cancel();
    print("Start Scan");
    try {
      if (await _connectedPeripheral?.isConnected() ?? false) {
        print("Start Scan");
        await _connectedPeripheral?.disconnectOrCancelConnection();
      }
    } catch (exception, stackTrace) {
      print(exception.toString());
    }
    scanStatus.value = BluetoothScanStatus.SCANNING;
    discoveredScanResults.clear();
    var endTime = DateTime.now().add(Duration(seconds: 30));
    performScan();
    scanTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (DateTime.now().isAfter(endTime)) {
        // print("start scan");
        stopScan();
      } else {
        performScan();
      }
    });
  }

  void performScan() async {
    print("Perform Scan");

    BleManager().startPeripheralScan(uuids: ["fe84"]).listen((scanResult) {
      print(scanResult);
      _peripheralDiscovered(scanResult);
    });
  }

  void _setBluetoothState(BluetoothState btState) {
    if (bluetoothState.value != btState) {
      bluetoothState.value = btState;
      if (btState == BluetoothState.POWERED_ON) {
        scanStatus.value = BluetoothScanStatus.IDLE;
        // Automatically start scanning if bluetooth becomes available
        startScan();
      } else {
        stopScan();
        scanStatus.value = BluetoothScanStatus.UNAVAILABLE;
      }
    }
  }
}
