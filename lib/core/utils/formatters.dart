import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String date(DateTime? d) =>
      d == null ? '-' : DateFormat('dd/MM/yyyy').format(d);

  static String dateTime(DateTime? d) =>
      d == null ? '-' : DateFormat('dd/MM/yyyy HH:mm').format(d);

  static String time(DateTime? d) =>
      d == null ? '-' : DateFormat('HH:mm').format(d);

  static String weight(double? kg) => kg == null ? '-' : '${kg.toStringAsFixed(1)} kg';

  static String age(DateTime? birth) {
    if (birth == null) return '-';
    final now = DateTime.now();
    final years = now.year - birth.year;
    final m = now.month - birth.month;
    final adjustedYears = (m < 0 || (m == 0 && now.day < birth.day))
        ? years - 1
        : years;
    if (adjustedYears <= 0) {
      final months = (now.year - birth.year) * 12 + m;
      final adj = months < 0 ? 0 : months;
      return '$adj ${adj == 1 ? 'mes' : 'meses'}';
    }
    return '$adjustedYears ${adjustedYears == 1 ? 'ano' : 'anos'}';
  }
}
