import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ble_connect_page.dart';
import 'database_helper.dart';

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
  String pressureValue = "120"; // Текущее давление
  DateTime lastMeasurementTime = DateTime.now(); // Время последнего измерения
  bool isConnected = true; // Статус подключения
  double lowerPressureThreshold = 60; // Нижний порог давления
  double upperPressureThreshold = 180; // Верхний порог давления
  bool isTighteningMode = true; // Текущий режим
  double batteryLevel = 80; // Уровень заряда батареи

  double? lastPressureValue;

  final DatabaseHelper dbHelper = DatabaseHelper();


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

    flutterReactiveBle
        .subscribeToCharacteristic(pressureCharacteristic!)
        .listen(
          (data) {
        String pressureStr = String.fromCharCodes(data);
        print("Получено давление: $pressureStr");
        setState(() {
          pressureValue = _convertPressureToHumanReadable(pressureStr);
          lastMeasurementTime = DateTime.now();
        });
      },
      onError: (error) {
        print("Ошибка получения давления: $error");
      },
    );
  }

  String _convertPressureToHumanReadable(String pressure) {
    try {
      double pressureValue = double.parse(pressure);
      return pressureValue.toStringAsFixed(1);
    } catch (e) {
      return "Нет данных";
    }
  }

  String _formatDate(DateTime dateTime) {
    return "${dateTime.day.toString().padLeft(2, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.year}";
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}:"
    "${dateTime.second.toString().padLeft(2, '0')}";
  }

  Color _getPressureColor(double pressure) {
    double percentage;

    // Рассчитываем процент для нижнего диапазона
    if (pressure < lowerPressureThreshold) {
      percentage = (pressure / lowerPressureThreshold) * 100;

      if (percentage <= 90) {
        // Менее 90% от нижнего порога — красный
        return Colors.red;
      } else if (percentage > 90 && percentage <= 100) {
        // 90%-100% — переход от красного к оранжевому
        return Color.lerp(Colors.red, Colors.orange, (percentage - 90) / 10)!;
      }
    }

    // Рассчитываем процент для диапазона между нижним и верхним порогом
    if (pressure >= lowerPressureThreshold && pressure <= upperPressureThreshold) {
      percentage = ((pressure - lowerPressureThreshold) /
          (upperPressureThreshold - lowerPressureThreshold)) *
          100;

      if (percentage <= 50) {
        // Нижняя часть диапазона (переход от оранжевого к зелёному)
        return Color.lerp(Colors.orange, Colors.green, percentage / 50)!;
      } else {
        // Верхняя часть диапазона (переход от зелёного к жёлтому)
        return Color.lerp(Colors.green, Colors.yellow, (percentage - 50) / 50)!;
      }
    }

    // Рассчитываем процент для верхнего диапазона
    if (pressure > upperPressureThreshold) {
      percentage = ((pressure - upperPressureThreshold) /
          (upperPressureThreshold + 20 - upperPressureThreshold)) *
          100;

      if (percentage <= 10) {
        // 100%-110% — переход от жёлтого к оранжевому
        return Color.lerp(Colors.yellow, Colors.orange, percentage / 10)!;
      } else if (percentage > 10 && percentage <= 20) {
        // 110%-120% — переход от оранжевого к красному
        return Color.lerp(Colors.orange, Colors.red, (percentage - 10) / 10)!;
      } else {
        // Более 120% — красный
        return Colors.red;
      }
    }

    return Colors.green; // По умолчанию, если в нормальном диапазоне
  }


  double _getPressurePercentage(double pressure) {
    if (pressure <= lowerPressureThreshold) {
      return 0.0;
    } else if (pressure >= upperPressureThreshold) {
      return 1.0;
    } else {
      return (pressure - lowerPressureThreshold) /
          (upperPressureThreshold - lowerPressureThreshold);
    }
  }

  Future<void> _disconnectDevice() async {
    // Устанавливаем состояние подключения на false
    setState(() {
      isConnected = false;
    });

    // Удаляем сохраненное устройство
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedDeviceId');

    // Отключаемся от устройства
    flutterReactiveBle.deinitialize();

    // Переходим на первый экран, заменяя текущий экран
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => BleConnectPage()),
    );
  }


  void _sendModeCommand(String mode) {
    if (commandCharacteristic != null) {
      final modeData = mode.codeUnits;
      flutterReactiveBle.writeCharacteristicWithoutResponse(
        commandCharacteristic!,
        value: modeData,
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Локальные переменные для хранения значений
        double tempLowerThreshold = lowerPressureThreshold;
        double tempUpperThreshold = upperPressureThreshold;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Настройки порогов давления",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF3A7FE7),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Нижний порог
                    Text(
                      "Нижний порог давления: ${tempLowerThreshold.toStringAsFixed(0)} г",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    Slider(
                      value: tempLowerThreshold,
                      min: 1,
                      max: 1900,
                      divisions: 150,
                      activeColor: Color(0xFF3A7FE7),
                      inactiveColor: Colors.grey[300],
                      label: tempLowerThreshold.toStringAsFixed(0),
                      onChanged: (double value) {
                        setState(() {
                          tempLowerThreshold = value;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    // Верхний порог
                    Text(
                      "Верхний порог давления: ${tempUpperThreshold.toStringAsFixed(0)} г",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    Slider(
                      value: tempUpperThreshold,
                      min: 100,
                      max: 2000,
                      divisions: 150,
                      activeColor: Color(0xFF3A7FE7),
                      inactiveColor: Colors.grey[300],
                      label: tempUpperThreshold.toStringAsFixed(0),
                      onChanged: (double value) {
                        setState(() {
                          tempUpperThreshold = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Обновляем реальные значения при закрытии диалога
                    setState(() {
                      lowerPressureThreshold = tempLowerThreshold;
                      upperPressureThreshold = tempUpperThreshold;
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3A7FE7), // Цвет кнопки
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Сохранить",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double pressure = double.tryParse(pressureValue) ?? 0.0;
    Color indicatorColor = _getPressureColor(pressure);
    double percentage = _getPressurePercentage(pressure);

    return Scaffold(
      appBar: AppBar(
        title: Text("Измерение давления"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.blueAccent),
            onPressed: _showSettingsDialog,
          ),
          IconButton(
            icon: Icon(Icons.power_settings_new, color: Colors.red),
            onPressed: _disconnectDevice,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Статус подключения Bluetooth и заряд батареи
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: isConnected ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      isConnected ? "Подключено" : "Отключено",
                      style: TextStyle(
                        color: isConnected ? Colors.blueAccent : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.battery_full,
                      color: batteryLevel > 50
                          ? Colors.green
                          : batteryLevel > 20
                          ? Colors.orange
                          : Colors.red, // Цвет в зависимости от уровня заряда
                    ),
                    SizedBox(width: 8),
                    Text(
                      "$batteryLevel%",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3A7FE7), Color(0xFF34CAEB)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          spreadRadius: 6,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 15,
                      valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$pressureValue",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "грамм",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _formatDate(lastMeasurementTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _formatTime(lastMeasurementTime),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.show_chart, color: Colors.blueAccent),
                  onPressed: () {
                    // Функционал для открытия графиков
                  },
                ),
                Text("Графики", style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 40),
            // Переключатель режима
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Режим затягивания"),
                Switch(
                  value: isTighteningMode,
                  onChanged: (bool value) {
                    setState(() {
                      isTighteningMode = value;
                      _sendModeCommand(value ? "1" : "2");
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Color(0xFF3A7FE7),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
