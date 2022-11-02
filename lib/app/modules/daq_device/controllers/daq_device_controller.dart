import 'package:get/get.dart';
import 'package:flutter_ble_lib_ios_15/flutter_ble_lib.dart';
import 'dart:async';
import 'dart:typed_data';

const String SERVICE_UUID = "0000fe84-0000-1000-8000-00805f9b34fb";
const String CHARACTERISTIC_UUID = "2d30c082-f39f-4ce6-923f-3484ea480596";

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
  final discoveredScanResults = <Peripheral>[].obs;
  Timer? scanTimer;
  Peripheral? _connectedPeripheral;
  Characteristic? handle;
  StreamSubscription? monitorSubscription;
  // VoidCallback? readStream;
  @override
  void onInit() {
    super.onInit();
    // readStream = Get.arguments['callback'];
  }

  @override
  void onReady() async {
    super.onReady();

    await BleManager().createClient();
    BleManager().observeBluetoothState().listen((btState) async {
      _setBluetoothState(btState);
    });
  }

  Future<Characteristic?> getCharacteristic() async {
    bool connected = await _connectedPeripheral?.isConnected() ?? false;
    if (connected == false) return null;

    await _connectedPeripheral!.discoverAllServicesAndCharacteristics();
    List<Service> ss = await _connectedPeripheral!.services();
    List<Characteristic> cs = await ss
        .firstWhere((element) => element.uuid == SERVICE_UUID)
        .characteristics();
    Characteristic c =
        cs.firstWhere((element) => element.uuid == CHARACTERISTIC_UUID);
    return c;
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
        .map((dsr) => dsr.identifier)
        .contains(scanResult.peripheral.identifier)) {
      return;
      // _discoveredScanResults.removeWhere((dsr) =>
      //     dsr.scanResult.peripheral.identifier ==
      //     scanResult.peripheral.identifier);
    }
    print(scanResult.peripheral.name);
    discoveredScanResults.add(scanResult.peripheral);
    // print(scanResult.peripheral.identifier);
    // notifyListeners();
  }

  void startComm() {
    handle!.write(Uint8List.fromList('Start'.codeUnits), false);
  }

  _setConnectedPeripheral(Peripheral? peripheral) async {
    try {
      if (await _connectedPeripheral?.isConnected() ?? false) {
        await _connectedPeripheral?.disconnectOrCancelConnection();
      }
    } catch (exception) {
      print(exception.toString());
    }
    _connectedPeripheral = peripheral;
    if (peripheral != null) {
      //   // DeviceService().clearDevice();
      // } else {
      await monitorSubscription?.cancel();
      stopScan();
      try {
        await peripheral.discoverAllServicesAndCharacteristics();
        List<Service> ss = await peripheral.services();
        List<Characteristic> cs = await ss
            .firstWhere((element) => element.uuid == SERVICE_UUID)
            .characteristics();
        handle =
            cs.firstWhere((element) => element.uuid == CHARACTERISTIC_UUID);
        print("Found UUID---${handle!.uuid}");
        // handle!.write(Uint8List.fromList('Start'.codeUnits), false);
        // _readStream(handle!.monitor());
        Get.back(result: handle);
        // Get.back();
      } catch (exception) {
        print(exception.toString());
      }
      // DeviceService().loadDeviceWithUUID(peripheral.identifier);
    }
  }

  _readStream(Stream<Uint8List> list) async {
    print("ReadStream");
    try {
      monitorSubscription = list.listen((event) {
        print(event);
      });
    } catch (exception) {
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
    try {
      if (await _connectedPeripheral?.isConnected() ?? false) {
        await _connectedPeripheral?.disconnectOrCancelConnection();
      }
    } catch (exception) {
      print(exception.toString());
    }
    scanStatus.value = BluetoothScanStatus.SCANNING;
    discoveredScanResults.clear();
    var endTime = DateTime.now().add(Duration(seconds: 50));
    performScan();
    scanTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (DateTime.now().isAfter(endTime)) {
        // print("start scan");
        stopScan();
      }
      //  else {
      //   performScan();
      // }
    });
  }

  void performScan() async {
    // print("Perform Scan");

    BleManager().startPeripheralScan().listen((scanResult) {
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
