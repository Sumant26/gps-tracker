// GENERATED CODE - DO NOT MODIFY BY HAND
// Run: flutter pub run build_runner build

part of 'tracking_session.dart';

class TrackingSessionAdapter extends TypeAdapter<TrackingSession> {
  @override
  final int typeId = HiveConstants.trackingSessionAdapterId;

  @override
  TrackingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackingSession(
      id: fields[0] as String,
      startTime: fields[1] as DateTime,
      endTime: fields[2] as DateTime?,
      isActive: fields[3] as bool,
      totalLocations: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TrackingSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startTime)
      ..writeByte(2)
      ..write(obj.endTime)
      ..writeByte(3)
      ..write(obj.isActive)
      ..writeByte(4)
      ..write(obj.totalLocations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackingSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
