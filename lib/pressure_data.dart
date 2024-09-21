class PressureData {
  final int id;
  final double value;
  final DateTime timestamp;

  PressureData({required this.id, required this.value, required this.timestamp});

  // Преобразование объекта в карту для хранения в БД
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Создание объекта из данных БД
  factory PressureData.fromMap(Map<String, dynamic> map) {
    return PressureData(
      id: map['id'],
      value: map['value'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
