// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $PressureDatasTable extends PressureDatas
    with drift.TableInfo<$PressureDatasTable, PressureData> {
  @override
  final drift.GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PressureDatasTable(this.attachedDatabase, [this._alias]);
  static const drift.VerificationMeta _idMeta =
      const drift.VerificationMeta('id');
  @override
  late final drift.GeneratedColumn<int> id = drift.GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const drift.VerificationMeta _pressureMeta =
      const drift.VerificationMeta('pressure');
  @override
  late final drift.GeneratedColumn<double> pressure =
      drift.GeneratedColumn<double>('pressure', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const drift.VerificationMeta _timestampMeta =
      const drift.VerificationMeta('timestamp');
  @override
  late final drift.GeneratedColumn<DateTime> timestamp =
      drift.GeneratedColumn<DateTime>('timestamp', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: drift.currentDateAndTime);
  @override
  List<drift.GeneratedColumn> get $columns => [id, pressure, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pressure_datas';
  @override
  drift.VerificationContext validateIntegrity(
      drift.Insertable<PressureData> instance,
      {bool isInserting = false}) {
    final context = drift.VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pressure')) {
      context.handle(_pressureMeta,
          pressure.isAcceptableOrUnknown(data['pressure']!, _pressureMeta));
    } else if (isInserting) {
      context.missing(_pressureMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<drift.GeneratedColumn> get $primaryKey => {id};
  @override
  PressureData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PressureData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      pressure: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pressure'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $PressureDatasTable createAlias(String alias) {
    return $PressureDatasTable(attachedDatabase, alias);
  }
}

class PressureData extends drift.DataClass
    implements drift.Insertable<PressureData> {
  final int id;
  final double pressure;
  final DateTime timestamp;
  const PressureData(
      {required this.id, required this.pressure, required this.timestamp});
  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    map['id'] = drift.Variable<int>(id);
    map['pressure'] = drift.Variable<double>(pressure);
    map['timestamp'] = drift.Variable<DateTime>(timestamp);
    return map;
  }

  PressureDatasCompanion toCompanion(bool nullToAbsent) {
    return PressureDatasCompanion(
      id: drift.Value(id),
      pressure: drift.Value(pressure),
      timestamp: drift.Value(timestamp),
    );
  }

  factory PressureData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return PressureData(
      id: serializer.fromJson<int>(json['id']),
      pressure: serializer.fromJson<double>(json['pressure']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= drift.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pressure': serializer.toJson<double>(pressure),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  PressureData copyWith({int? id, double? pressure, DateTime? timestamp}) =>
      PressureData(
        id: id ?? this.id,
        pressure: pressure ?? this.pressure,
        timestamp: timestamp ?? this.timestamp,
      );
  PressureData copyWithCompanion(PressureDatasCompanion data) {
    return PressureData(
      id: data.id.present ? data.id.value : this.id,
      pressure: data.pressure.present ? data.pressure.value : this.pressure,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PressureData(')
          ..write('id: $id, ')
          ..write('pressure: $pressure, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pressure, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PressureData &&
          other.id == this.id &&
          other.pressure == this.pressure &&
          other.timestamp == this.timestamp);
}

class PressureDatasCompanion extends drift.UpdateCompanion<PressureData> {
  final drift.Value<int> id;
  final drift.Value<double> pressure;
  final drift.Value<DateTime> timestamp;
  const PressureDatasCompanion({
    this.id = const drift.Value.absent(),
    this.pressure = const drift.Value.absent(),
    this.timestamp = const drift.Value.absent(),
  });
  PressureDatasCompanion.insert({
    this.id = const drift.Value.absent(),
    required double pressure,
    this.timestamp = const drift.Value.absent(),
  }) : pressure = drift.Value(pressure);
  static drift.Insertable<PressureData> custom({
    drift.Expression<int>? id,
    drift.Expression<double>? pressure,
    drift.Expression<DateTime>? timestamp,
  }) {
    return drift.RawValuesInsertable({
      if (id != null) 'id': id,
      if (pressure != null) 'pressure': pressure,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  PressureDatasCompanion copyWith(
      {drift.Value<int>? id,
      drift.Value<double>? pressure,
      drift.Value<DateTime>? timestamp}) {
    return PressureDatasCompanion(
      id: id ?? this.id,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, drift.Expression> toColumns(bool nullToAbsent) {
    final map = <String, drift.Expression>{};
    if (id.present) {
      map['id'] = drift.Variable<int>(id.value);
    }
    if (pressure.present) {
      map['pressure'] = drift.Variable<double>(pressure.value);
    }
    if (timestamp.present) {
      map['timestamp'] = drift.Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PressureDatasCompanion(')
          ..write('id: $id, ')
          ..write('pressure: $pressure, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends drift.GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PressureDatasTable pressureDatas = $PressureDatasTable(this);
  @override
  Iterable<drift.TableInfo<drift.Table, Object?>> get allTables =>
      allSchemaEntities.whereType<drift.TableInfo<drift.Table, Object?>>();
  @override
  List<drift.DatabaseSchemaEntity> get allSchemaEntities => [pressureDatas];
}

typedef $$PressureDatasTableCreateCompanionBuilder = PressureDatasCompanion
    Function({
  drift.Value<int> id,
  required double pressure,
  drift.Value<DateTime> timestamp,
});
typedef $$PressureDatasTableUpdateCompanionBuilder = PressureDatasCompanion
    Function({
  drift.Value<int> id,
  drift.Value<double> pressure,
  drift.Value<DateTime> timestamp,
});

class $$PressureDatasTableFilterComposer
    extends drift.FilterComposer<_$AppDatabase, $PressureDatasTable> {
  $$PressureDatasTableFilterComposer(super.$state);
  drift.ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnFilters<double> get pressure => $state.composableBuilder(
      column: $state.table.pressure,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));

  drift.ColumnFilters<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          drift.ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PressureDatasTableOrderingComposer
    extends drift.OrderingComposer<_$AppDatabase, $PressureDatasTable> {
  $$PressureDatasTableOrderingComposer(super.$state);
  drift.ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<double> get pressure => $state.composableBuilder(
      column: $state.table.pressure,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));

  drift.ColumnOrderings<DateTime> get timestamp => $state.composableBuilder(
      column: $state.table.timestamp,
      builder: (column, joinBuilders) =>
          drift.ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $$PressureDatasTableTableManager extends drift.RootTableManager<
    _$AppDatabase,
    $PressureDatasTable,
    PressureData,
    $$PressureDatasTableFilterComposer,
    $$PressureDatasTableOrderingComposer,
    $$PressureDatasTableCreateCompanionBuilder,
    $$PressureDatasTableUpdateCompanionBuilder,
    (
      PressureData,
      drift.BaseReferences<_$AppDatabase, $PressureDatasTable, PressureData>
    ),
    PressureData,
    drift.PrefetchHooks Function()> {
  $$PressureDatasTableTableManager(_$AppDatabase db, $PressureDatasTable table)
      : super(drift.TableManagerState(
          db: db,
          table: table,
          filteringComposer: $$PressureDatasTableFilterComposer(
              drift.ComposerState(db, table)),
          orderingComposer: $$PressureDatasTableOrderingComposer(
              drift.ComposerState(db, table)),
          updateCompanionCallback: ({
            drift.Value<int> id = const drift.Value.absent(),
            drift.Value<double> pressure = const drift.Value.absent(),
            drift.Value<DateTime> timestamp = const drift.Value.absent(),
          }) =>
              PressureDatasCompanion(
            id: id,
            pressure: pressure,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            drift.Value<int> id = const drift.Value.absent(),
            required double pressure,
            drift.Value<DateTime> timestamp = const drift.Value.absent(),
          }) =>
              PressureDatasCompanion.insert(
            id: id,
            pressure: pressure,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), drift.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PressureDatasTableProcessedTableManager = drift.ProcessedTableManager<
    _$AppDatabase,
    $PressureDatasTable,
    PressureData,
    $$PressureDatasTableFilterComposer,
    $$PressureDatasTableOrderingComposer,
    $$PressureDatasTableCreateCompanionBuilder,
    $$PressureDatasTableUpdateCompanionBuilder,
    (
      PressureData,
      drift.BaseReferences<_$AppDatabase, $PressureDatasTable, PressureData>
    ),
    PressureData,
    drift.PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PressureDatasTableTableManager get pressureDatas =>
      $$PressureDatasTableTableManager(_db, _db.pressureDatas);
}
