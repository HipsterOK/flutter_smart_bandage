import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDataPage extends StatefulWidget {
  final String deviceId;
  BleDataPage({required this.deviceId});

  @override
  _BleDataPageState createState() => _BleDataPageState();
}

class _BleDataPageState extends State<BleDataPage> {
  final flutterReactiveBle = FlutterReactiveBle();
  QualifiedCharacteristic? pressureCharacteristic;
  QualifiedCharacteristic? commandCharacteristic;
  String pressureValue = "Нет данных";
  String currentMode = "Неизвестно";

  @override
  void initState() {
    super.initState();
    _setupCharacteristics(widget.deviceId);
  }

  void _setupCharacteristics(String deviceId) {
    final serviceUuid = Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
    final pressureCharUuid = Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");
    final commandCharUuid = Uuid.parse("cba1d466-344c-4be3-ab3f-189f80dd7518");

    pressureCharacteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: pressureCharUuid,
      deviceId: deviceId,
    );

    commandCharacteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: commandCharUuid,
      deviceId: deviceId,
    );

    flutterReactiveBle.subscribeToCharacteristic(pressureCharacteristic!).listen(
          (data) {
        String pressure = String.fromCharCodes(data);
        setState(() {
          pressureValue = _convertPressureToHumanReadable(pressure) + " мм рт. ст.";
        });
      },
      onError: (error) {
        print("Ошибка получения давления: $error");
      },
    );

    flutterReactiveBle.subscribeToCharacteristic(commandCharacteristic!).listen(
          (data) {
        String receivedMessage = String.fromCharCodes(data);
        setState(() {
          if (receivedMessage == "1") {
            currentMode = "Режим затягивания";
          } else if (receivedMessage == "2") {
            currentMode = "Режим ношения";
          } else {
            currentMode = "Неизвестно";
          }
        });
      },
      onError: (error) {
        print("Ошибка получения режима: $error");
      },
    );
  }

  String _convertPressureToHumanReadable(String pressure) {
    try {
      double pressureValue = double.parse(pressure);
      return pressureValue.toStringAsFixed(2);
    } catch (e) {
      return "Некорректные данные";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Данные устройства")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Давление: $pressureValue", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text("Текущий режим: $currentMode", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Вернуться"),
            ),
          ],
        ),
      ),
    );
  }
}
