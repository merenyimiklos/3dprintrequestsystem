import 'package:hive/hive.dart';
import 'enums.dart';

/// The main data model for a 3D print request.
/// Uses Hive for local persistence via a manually written TypeAdapter.
class PrintRequest extends HiveObject {
  String id;
  String requesterName;
  String classGroup;
  String projectName;
  String description;
  PrinterType printer;
  MaterialType material;
  String color;
  double estimatedPrintTime;
  Priority priority;
  PrintStatus status;
  String notes;
  DateTime createdAt;
  DateTime updatedAt;

  PrintRequest({
    required this.id,
    required this.requesterName,
    required this.classGroup,
    required this.projectName,
    this.description = '',
    required this.printer,
    required this.material,
    this.color = '',
    required this.estimatedPrintTime,
    this.priority = Priority.normal,
    this.status = PrintStatus.pending,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a copy of this request with the given fields replaced.
  PrintRequest copyWith({
    String? id,
    String? requesterName,
    String? classGroup,
    String? projectName,
    String? description,
    PrinterType? printer,
    MaterialType? material,
    String? color,
    double? estimatedPrintTime,
    Priority? priority,
    PrintStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PrintRequest(
      id: id ?? this.id,
      requesterName: requesterName ?? this.requesterName,
      classGroup: classGroup ?? this.classGroup,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      printer: printer ?? this.printer,
      material: material ?? this.material,
      color: color ?? this.color,
      estimatedPrintTime: estimatedPrintTime ?? this.estimatedPrintTime,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Hive TypeAdapter for [PrintRequest].
/// Written manually to avoid needing build_runner code generation.
class PrintRequestAdapter extends TypeAdapter<PrintRequest> {
  @override
  final int typeId = 0;

  @override
  PrintRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrintRequest(
      id: fields[0] as String,
      requesterName: fields[1] as String,
      classGroup: fields[2] as String,
      projectName: fields[3] as String,
      description: fields[4] as String? ?? '',
      printer: PrinterType.values[fields[5] as int],
      material: MaterialType.values[fields[6] as int],
      color: fields[7] as String? ?? '',
      estimatedPrintTime: fields[8] as double,
      priority: Priority.values[fields[9] as int],
      status: PrintStatus.values[fields[10] as int],
      notes: fields[11] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[12] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(fields[13] as int),
    );
  }

  @override
  void write(BinaryWriter writer, PrintRequest obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.requesterName)
      ..writeByte(2)
      ..write(obj.classGroup)
      ..writeByte(3)
      ..write(obj.projectName)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.printer.index)
      ..writeByte(6)
      ..write(obj.material.index)
      ..writeByte(7)
      ..write(obj.color)
      ..writeByte(8)
      ..write(obj.estimatedPrintTime)
      ..writeByte(9)
      ..write(obj.priority.index)
      ..writeByte(10)
      ..write(obj.status.index)
      ..writeByte(11)
      ..write(obj.notes)
      ..writeByte(12)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(13)
      ..write(obj.updatedAt.millisecondsSinceEpoch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrintRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
