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
  StreamSubscription<BluetoothState>? _bluetoothStateSubscription;

  @override
  void initState() {
    super.initState();
    _requestPermissions().then((_) {
      _checkBluetoothStatus();
    });

    // Подписываемся на изменение состояния Bluetooth
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
      // Запрашиваем все необходимые разрешения
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
    _bluetoothStateSubscription?.cancel(); // Отписываемся при уничтожении виджета
    super.dispose();
  }

  // Проверяем статус Bluetooth при запуске
  Future<void> _checkBluetoothStatus() async {
    bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
    setState(() {
      isBluetoothEnabled = isEnabled!;
    });
    if (isEnabled!) {
      _connectToSavedDevice();
    }
  }

  // Включаем Bluetooth и подключаемся к устройству
  Future<void> _enableBluetoothAndConnect() async {
    await FlutterBluetoothSerial.instance.requestEnable();
    setState(() {
      isBluetoothEnabled = true;
    });
    _connectToSavedDevice();
  }

  // Загружаем сохранённое устройство из SharedPreferences
  Future<void> _loadSelectedDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDeviceId = prefs.getString('selectedDeviceId');
    if (savedDeviceId != null) {
      setState(() {
        selectedDeviceId = savedDeviceId;
      });
    }
  }

  // Сохраняем устройство
  Future<void> _saveSelectedDevice(String deviceId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedDeviceId', deviceId);
    setState(() {
      selectedDeviceId = deviceId;
    });
  }

  // Подключаемся к сохранённому устройству и автоматически переходим на BleDataPage
  Future<void> _connectToSavedDevice() async {
    await _loadSelectedDevice();
    if (selectedDeviceId != null) {
      flutterReactiveBle.connectToDevice(id: selectedDeviceId!).listen(
            (connectionState) {
          if (connectionState.connectionState == DeviceConnectionState.connected) {
            // Переход на BleDataPage при успешном подключении
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

  // Сканируем устройства и позволяем пользователю выбрать одно из них
  Future<void> _scanAndSelectDevice() async {
    if (await Permission.bluetoothScan.isGranted && await Permission.bluetoothConnect.isGranted) {
      setState(() {
        foundDevices.clear();
      });

      flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
        if (!foundDevices.any((element) => element.id == device.id)) {
          setState(() {
            foundDevices.add(device);
          });
        }
      });
    } else {
      print("Необходимо предоставить разрешения на Bluetooth для поиска устройств.");
      await _requestPermissions(); // Запрашиваем разрешения, если они ещё не предоставлены
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Подключение к устройству"),
      ),
      body: isBluetoothEnabled
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _scanAndSelectDevice,
            child: Text("Сканировать устройства"),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: foundDevices.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(foundDevices[index].name),
                  subtitle: Text(foundDevices[index].id),
                  trailing: selectedDeviceId == foundDevices[index].id
                      ? Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    _saveSelectedDevice(foundDevices[index].id);
                    _connectToSavedDevice();
                  },
                );
              },
            ),
          ),
        ],
      )
          : Center(
        child: ElevatedButton(
          onPressed: _enableBluetoothAndConnect,
          child: Text("Включить Bluetooth"),
        ),
      ),
    );
  }
}