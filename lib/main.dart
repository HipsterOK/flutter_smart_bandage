import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_smart_bandage/ble_connect_page.dart';
import 'package:workmanager/workmanager.dart';

// Инициализация WorkManager для фоновых задач
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeWorkManager();
  runApp(MyApp());
}

Future<void> _initializeWorkManager() async {
  await Workmanager().initialize(
    _callbackDispatcher,
    isInDebugMode: true,
  );
}

void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // Запуск фоновой задачи
    return _backgroundTask();
  });
}

Future<bool> _backgroundTask() async {
  final flutterReactiveBle = FlutterReactiveBle();

  try {
    // Выполняем сканирование устройств
    await flutterReactiveBle
        .scanForDevices(withServices: [Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b")])
        .first;

    // Возвращаем true, если задача успешно выполнена
    return Future.value(true);
  } catch (e) {
    // Возвращаем false, если произошла ошибка
    print("Ошибка фоновой задачи: $e");
    return Future.value(false);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Bandage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BleConnectPage(),
    );
  }
}