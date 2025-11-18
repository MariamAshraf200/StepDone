import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../domain/scheduled_reminder.dart';
import '../../data/local_notification_service.dart';
import 'reminder_state.dart';

class ReminderCubit extends Cubit<ReminderState> {
  static const String boxName = 'reminders';
  Box<ScheduledReminder>? _box;

  ReminderCubit() : super(ReminderInitial()) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await _openBoxIfNeeded();
      _emitLoaded();
    } catch (e) {
      emit(ReminderError('Failed to initialize reminders storage: $e'));
    }
  }

  Future<Box<ScheduledReminder>> _openBoxIfNeeded() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<ScheduledReminder>(boxName);
    }
    return await Hive.openBox<ScheduledReminder>(boxName);
  }

  Future<void> _ensureBox() async {
    _box ??= await _openBoxIfNeeded();
  }

  List<ScheduledReminder> get reminders => _box?.values.toList() ?? [];

  Future<void> scheduleReminder({
    required String text,
    required DateTime firstDateTime,
    int daysInterval = 1,
  }) async {
    emit(ReminderLoading());
    try {
      await _ensureBox();

      final idBaseString =
          'rem_${text}_${firstDateTime.toIso8601String()}_${DateTime.now().millisecondsSinceEpoch}';

      final ids = await LocalNotificationService.scheduleTextRepeatNotification(
        idBaseString: idBaseString,
        title: 'StepDone',
        text: text,
        firstDateTime: firstDateTime,
        daysInterval: daysInterval,
      );

      final reminder = ScheduledReminder(
        text: text,
        dateTime: firstDateTime,
        daysInterval: daysInterval,
        ids: ids,
      );

      await _box!.add(reminder);
      _emitLoaded();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  Future<void> cancelReminder(int index) async {
    try {
      await _ensureBox();
      final keys = _box!.keys.toList();
      if (index < 0 || index >= keys.length) return;

      final key = keys[index];
      final reminder = _box!.get(key);

      if (reminder != null) {
        for (final id in reminder.ids) {
          await LocalNotificationService.cancelNotification(id);
        }
      }

      await _box!.delete(key);
      _emitLoaded();
    } catch (e) {
      emit(ReminderError(e.toString()));
    }
  }

  void _emitLoaded() {
    emit(ReminderLoaded(_box?.values.toList() ?? []));
  }
}
