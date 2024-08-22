import 'dart:async';
import 'dart:typed_data';  // Импортируйте для использования Uint8List

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BluetoothConnectionScreen(),
    );
  }
}

class BluetoothConnectionScreen extends StatefulWidget {
  @override
  _BluetoothConnectionScreenState createState() =>
      _BluetoothConnectionScreenState();
}

class _BluetoothConnectionScreenState
    extends State<BluetoothConnectionScreen> {
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanSubscription;
  late StreamSubscription<ConnectionStateUpdate> _connectionSubscription;
  late StreamSubscription<List<int>> _pressureSubscription; // Изменено на List<int>
  final _deviceName = 'Smart Bandage'; // Название устройства
  late QualifiedCharacteristic _commandCharacteristic;
  late QualifiedCharacteristic _pressureCharacteristic;
  bool _isConnected = false;
  String _pressureData = '';

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

  void _startScanning() {
    _scanSubscription = flutterReactiveBle.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      if (device.name == _deviceName) {
        _scanSubscription.cancel();
        _connectToDevice(device.id);
      }
    });
  }

  void _connectToDevice(String deviceId) async {
    final connection = flutterReactiveBle.connectToDevice(
      id: deviceId,
      servicesWithCharacteristicsToDiscover: {
        Uuid.parse('4fafc201-1fb5-459e-8fcc-c5c9c331914b'): [
          Uuid.parse('cba1d466-344c-4be3-ab3f-189f80dd7518'), // Command Char UUID
          Uuid.parse('beb5483e-36e1-4688-b7f5-ea07361b26a8')  // Pressure Char UUID
        ]
      },
      connectionTimeout: Duration(seconds: 5),
    );

    _connectionSubscription = connection.listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        setState(() {
          _isConnected = true;
        });
        _initializeCharacteristics(deviceId);
      } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        setState(() {
          _isConnected = false;
        });
        _startScanning(); // Перезапуск сканирования для переподключения
      }
    });
  }

  void _initializeCharacteristics(String deviceId) {
    _commandCharacteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse('4fafc201-1fb5-459e-8fcc-c5c9c331914b'),
      characteristicId: Uuid.parse('cba1d466-344c-4be3-ab3f-189f80dd7518'),
      deviceId: deviceId,
    );

    _pressureCharacteristic = QualifiedCharacteristic(
      serviceId: Uuid.parse('4fafc201-1fb5-459e-8fcc-c5c9c331914b'),
      characteristicId: Uuid.parse('beb5483e-36e1-4688-b7f5-ea07361b26a8'),
      deviceId: deviceId,
    );

    // Подписка на данные давления
    _pressureSubscription = flutterReactiveBle.subscribeToCharacteristic(
      _pressureCharacteristic,
    ).listen((data) {
      setState(() {
        _pressureData = String.fromCharCodes(Uint8List.fromList(data)); // Преобразуйте List<int> в Uint8List
      });
    });
  }

  void _setMode(int mode) {
    if (_isConnected) {
      final command = [mode]; // Преобразуйте режим в список байтов
      flutterReactiveBle.writeCharacteristicWithResponse(
        _commandCharacteristic,
        value: command,
      ).then((_) {
        print("Mode $mode set successfully");
      }).catchError((error) {
        print('Error setting mode: $error');
      });
    }
  }

  @override
  void dispose() {
    _scanSubscription.cancel();
    _connectionSubscription.cancel();
    _pressureSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Connection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isConnected
                ? Column(
              children: [
                Text('Pressure: $_pressureData'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _setMode(0x01),  // Hex 1
                      child: Text('Set Tightening Mode'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => _setMode(0x02),  // Hex 2
                      child: Text('Set Wearing Mode'),
                    ),
                  ],
                ),
              ],
            )
                : CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
