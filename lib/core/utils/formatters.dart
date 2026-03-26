import 'package:intl/intl.dart';

class Formatters {
  Formatters._();
  static String formatDate(DateTime date) {
    return DateFormat('EEE, MMM d,yyyy').format(date);
  }
}
