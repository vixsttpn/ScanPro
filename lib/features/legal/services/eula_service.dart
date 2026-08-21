
import 'package:hive_flutter/hive_flutter.dart';

class EulaService {
  static const String boxName = 'settings';
  static const String keyAccepted = 'eula_accepted_v1';
  static const String keyDate = 'eula_accepted_date';

  static Future<bool> isAccepted() async {
    final box = await Hive.openBox(boxName);
    return box.get(keyAccepted, defaultValue: false) as bool;
  }

  static Future<void> accept() async {
    final box = await Hive.openBox(boxName);
    await box.put(keyAccepted, true);
    await box.put(keyDate, DateTime.now().toIso8601String());
  }

  static Future<void> reset() async {
    final box = await Hive.openBox(boxName);
    await box.delete(keyAccepted);
    await box.delete(keyDate);
  }
}
