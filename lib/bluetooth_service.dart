import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  final _devicesController = StreamController<List<DiscoveredDevice>>.broadcast();

  BluetoothService();

  Stream<List<DiscoveredDevice>> get devicesStream => _devicesController.stream;

  Future<void> startScanning() async {
    final discoveredDevices = <DiscoveredDevice>[];

    _scanSubscription = _ble.scanForDevices(withServices: []).listen(
          (device) {
        if (!discoveredDevices.any((d) => d.id == device.id)) {
          discoveredDevices.add(device);
          _devicesController.add(List.unmodifiable(discoveredDevices));
        }
      },
      onError: (error) {
        print('Scan error: $error');
      },
    );
  }

  void stopScanning() {
    _scanSubscription?.cancel();
    _devicesController.close();
  }

  Future<ConnectionStateUpdate?> connectToDevice(String deviceId) async {
    try {
      final connectionStream = _ble.connectToDevice(
        id: deviceId,
        connectionTimeout: const Duration(seconds: 10),
      );

      final connection = await connectionStream.firstWhere(
            (update) => update.connectionState == DeviceConnectionState.connected,
      );

      print('Connected to device with id $deviceId');
      return connection;
    } catch (e) {
      print('Connection error: $e');
      return null;
    }
  }
}