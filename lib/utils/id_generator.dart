import 'package:uuid/uuid.dart';

/// توليد معرف فريد للمهمة
String generateId() {
  return const Uuid().v4();
}
