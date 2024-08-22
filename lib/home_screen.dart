import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceScreen extends StatefulWidget {
  final DiscoveredDevice device;

  DeviceScreen({required this.device});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late StreamSubscription<ConnectionStateUpdate> _connection;
  late QualifiedCharacteristic _characteristic;
  late StreamSubscription<List<int>> _notification;
  late Stream<List<int>> _stream;
  bool _isConnected = false;
  String _response = 'No response yet';

  @override
  void initState() {
    super.initState();
    _connectToDevice();
  }

  Future<void> _connectToDevice() async {
    final connection = _ble.connectToDevice(
      id: widget.device.id,
    );

    _connection = connection.listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        setState(() {
          _isConnected = true;
        });
        _discoverServices();
      } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        setState(() {
          _isConnected = false;
        });
      }
    });
  }

  Future<void> _discoverServices() async {
    final services = await _ble.discoverServices(widget.device.id);
    for (final service in services) {
      for (final characteristic in service.characteristics) {
        if (characteristic.characteristicId.toString() == 'your-characteristic-uuid') {
          _characteristic = characteristic as QualifiedCharacteristic;
          _startNotification();
        }
      }
    }
  }

  Future<void> _startNotification() async {
    _stream = _ble.subscribeToCharacteristic(_characteristic);
    _notification = _stream.listen((data) {
      setState(() {
        _response = String.fromCharCodes(data);
      });
    });
    _sendData();
  }

  Future<void> _sendData() async {
    if (_isConnected) {
      await _ble.writeCharacteristicWithResponse(_characteristic, value: [0x32]); // "2" in hex
    }
  }

  @override
  void dispose() {
    _connection.cancel();
    _notification.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Device Communication"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Device ID: ${widget.device.id}'),
            Text('Connection Status: ${_isConnected ? 'Connected' : 'Disconnected'}'),
            SizedBox(height: 20),
            Text('Response: $_response'),
          ],
        ),
      ),
    );
  }
}