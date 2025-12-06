import 'package:hive/hive.dart';
import '../domain/scheduled_reminder.dart';

class ScheduledReminderAdapter extends TypeAdapter<ScheduledReminder> {
  @override
  final int typeId = 1; // Changed from 2 to 1 to avoid collision with CategoryModelAdapter (typeId=2)

  @override
  ScheduledReminder read(BinaryReader reader) {
    final text = reader.readString();
    final millis = reader.readInt();
    final dateTime = DateTime.fromMillisecondsSinceEpoch(millis);
    final idsLength = reader.readInt();
    final ids = <int>[];
    for (var i = 0; i < idsLength; i++) {
      ids.add(reader.readInt());
    }
    return ScheduledReminder(
      text: text,
      dateTime: dateTime,
      ids: ids,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduledReminder obj) {
    writer.writeString(obj.text);
    writer.writeInt(obj.dateTime.millisecondsSinceEpoch);
    writer.writeInt(obj.ids.length);
    for (final id in obj.ids) {
      writer.writeInt(id);
    }
  }
}
