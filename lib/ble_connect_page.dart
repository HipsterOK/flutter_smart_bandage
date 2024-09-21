import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ble_data_page.dart';

class BleConnectPage extends StatefulWidget {
  @override
  _BleConnectPageState createState() => _BleConnectPageState();
}

class _BleConnectPageState extends State<BleConnectPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> foundDevices = [];
  String? selectedDeviceId;
  bool isBluetoothEnabled = false;
  bool isScanning = false;
  StreamSubscription<BluetoothState>? _bluetoothStateSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) {
      _checkBluetoothStatus();
    });

    _bluetoothStateSubscription = FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      if (state == BluetoothState.STATE_OFF) {
        setState(() {
          isBluetoothEnabled = false;
        });
      } else if (state == BluetoothState.STATE_ON) {
        setState(() {
          isBluetoothEnabled = true;
          _connectToSavedDevice();
        });
      }
    });
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ].request();

      if (statuses[Permission.bluetoothScan] != PermissionStatus.granted ||
          statuses[Permission.bluetoothConnect] != PermissionStatus.granted ||
          statuses[Permission.locationWhenInUse] != PermissionStatus.granted) {
        throw Exception('Необходимы разрешения на использование Bluetooth и местоположения.');
      }
    }
  }

  @override
  void dispose() {
    _bluetoothStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkBluetoothStatus() async {
    bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    setState(() {
      isBluetoothEnabled = isEnabled!;
    });
    if (isEnabled!) {
      _connectToSavedDevice();
    }
  }

  Future<void> _enableBluetoothAndConnect() async {
    await FlutterBluetoothSerial.instance.requestEnable();
    setState(() {
      isBluetoothEnabled = true;
    });
    _connectToSavedDevice();
  }

  Future<void> _loadSelectedDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDeviceId = prefs.getString('selectedDeviceId');
    if (savedDeviceId != null) {
      setState(() {
        selectedDeviceId = savedDeviceId;
      });
    }
  }

  Future<void> _saveSelectedDevice(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDeviceId', deviceId);
    setState(() {
      selectedDeviceId = deviceId;
    });
  }

  Future<void> _connectToSavedDevice() async {
    await _loadSelectedDevice();
    if (selectedDeviceId != null) {
      flutterReactiveBle.connectToDevice(id: selectedDeviceId!).listen(
            (connectionState) {
          if (connectionState.connectionState == DeviceConnectionState.connected) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BleDataPage(deviceId: selectedDeviceId!),
              ),
            );
          } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
            setState(() {
              selectedDeviceId = null;
            });
          }
        },
        onError: (error) {
          print("Ошибка подключения: $error");
        },
      );
    }
  }

  Future<void> _scanAndSelectDevice() async {
    if (await Permission.bluetoothScan.isGranted && await Permission.bluetoothConnect.isGranted) {
      setState(() {
        foundDevices.clear();
        isScanning = true;
      });

      flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
        if (!foundDevices.any((element) => element.id == device.id)) {
          setState(() {
            foundDevices.add(device);
            isScanning = false;
          });
        }
      });
    } else {
      print("Необходимо предоставить разрешения на Bluetooth для поиска устройств.");
      await _requestPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Подключение к устройству",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.0),
        child: isBluetoothEnabled
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: foundDevices.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        foundDevices[index].name,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        foundDevices[index].id,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      trailing: selectedDeviceId == foundDevices[index].id
                          ? Icon(Icons.check_circle, color: Colors.greenAccent)
                          : null,
                      onTap: () {
                        _saveSelectedDevice(foundDevices[index].id);
                        _connectToSavedDevice();
                      },
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                onPressed: _scanAndSelectDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                ),
                child: Text(
                  isScanning ? "Обновить список" : "Сканировать устройства",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        )
            : Center(
          child: ElevatedButton(
            onPressed: _enableBluetoothAndConnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
            ),
            child: Text(
              "Включить Bluetooth",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}