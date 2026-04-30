import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String indonesiaTimezoneName = 'Asia/Jakarta';

tz.Location get indonesiaLocation => tz.getLocation(indonesiaTimezoneName);

void initializeIndonesiaTimezone() {
  tz.initializeTimeZones();
  tz.setLocalLocation(indonesiaLocation);
}

DateTime nowInIndonesia() {
  return tz.TZDateTime.now(indonesiaLocation);
}

DateTime toIndonesiaDateTime(DateTime dateTime) {
  return tz.TZDateTime.from(dateTime.toUtc(), indonesiaLocation);
}

DateTime parseUtcToIndonesia(dynamic value, {DateTime? fallback}) {
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return toIndonesiaDateTime(parsed);
    }
  } else if (value is DateTime) {
    return toIndonesiaDateTime(value);
  }

  return fallback ?? nowInIndonesia();
}

DateTime dateOnlyInIndonesia(DateTime dateTime) {
  final local = toIndonesiaDateTime(dateTime);
  return DateTime(local.year, local.month, local.day);
}

bool isSameIndonesiaDate(DateTime a, DateTime b) {
  final da = dateOnlyInIndonesia(a);
  final db = dateOnlyInIndonesia(b);
  return da.year == db.year && da.month == db.month && da.day == db.day;
}
