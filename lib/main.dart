import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_connect_page.dart';
import 'ble_data_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Bandage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartPage(), // Изменено для проверки подключения
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  String? selectedDeviceId;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedDeviceId = prefs.getString('selectedDeviceId');

    if (selectedDeviceId != null) {
      // Если есть сохраненное устройство, пробуем подключиться
      flutterReactiveBle.connectToDevice(id: selectedDeviceId!).listen(
            (connectionState) {
          if (connectionState.connectionState == DeviceConnectionState.connected) {
            // Если подключено, перейти сразу на BleDataPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BleDataPage(deviceId: selectedDeviceId!),
              ),
            );
          } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
            // Если не подключено, открыть BleConnectPage
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => BleConnectPage()),
            );
          }
        },
        onError: (error) {
          print("Ошибка подключения: $error");
          // В случае ошибки также переходить на BleConnectPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BleConnectPage()),
          );
        },
      );
    } else {
      // Если нет сохраненного устройства, открыть BleConnectPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BleConnectPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Показываем пустой экран с индикатором загрузки, пока идет проверка
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
