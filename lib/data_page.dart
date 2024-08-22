import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DataPage extends StatefulWidget {
  final QualifiedCharacteristic characteristic;

  DataPage({required this.characteristic});

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<List<int>>? _characteristicSubscription;
  Timer? _timer;
  String data = 'N/A';

  @override
  void initState() {
    super.initState();
    _subscribeToCharacteristic();
    Future.delayed(Duration(seconds: 2), _startSendingCommands);  // Добавлена задержка перед отправкой команды
  }

  void _subscribeToCharacteristic() {
    _characteristicSubscription = _ble.subscribeToCharacteristic(widget.characteristic).listen(
          (data) {
        setState(() {
          this.data = String.fromCharCodes(data);
        });
      },
      onError: (error) {
        print('Error reading characteristic: $error');
      },
    );
  }

  void _startSendingCommands() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _sendCommand();
    });
  }

  void _sendCommand() async {
    try {
      final command = '2'.codeUnits; // Преобразование '2' в байтовый массив
      await _ble.writeCharacteristicWithoutResponse(widget.characteristic, value: command);
      print('Команда "2" отправлена успешно');
    } catch (error) {
      print('Ошибка отправки команды: $error');
    }
  }

  @override
  void dispose() {
    _characteristicSubscription?.cancel();
    _timer?.cancel(); // Остановка таймера при выходе из экрана
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text('Received Data: $data'),
        ),
      ),
    );
  }
}