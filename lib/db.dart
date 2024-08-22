import 'package:drift/backends.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/drift.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'db.g.dart';

@drift.DataClassName('PressureData')
class PressureDatas extends drift.Table {
  drift.IntColumn get id => integer().autoIncrement()();
  drift.RealColumn get pressure => real()();
  drift.DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
}

@drift.DriftDatabase(tables: [PressureDatas])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future<List<PressureData>> getAllDatas() => select(pressureDatas).get();
  Stream<List<PressureData>> watchAllDatas() => select(pressureDatas).watch();
  Future insertData(PressureData data) => into(pressureDatas).insert(data);
}