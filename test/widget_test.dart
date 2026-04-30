import 'package:flutter_test/flutter_test.dart';
import 'package:purewill/utils/indonesia_timezone.dart';

void main() {
  setUpAll(() {
    initializeIndonesiaTimezone();
  });

  test('parseUtcToIndonesia converts UTC midnight to Jakarta time', () {
    final jakartaTime = parseUtcToIndonesia('2026-04-30T00:00:00Z');

    expect(jakartaTime.year, 2026);
    expect(jakartaTime.month, 4);
    expect(jakartaTime.day, 30);
    expect(jakartaTime.hour, 7);
    expect(jakartaTime.minute, 0);
  });

  test('dateOnlyInIndonesia returns local Jakarta date', () {
    final jakartaTime = parseUtcToIndonesia('2026-04-29T18:30:00Z');
    final dateOnly = dateOnlyInIndonesia(jakartaTime);

    expect(dateOnly.year, 2026);
    expect(dateOnly.month, 4);
    expect(dateOnly.day, 30);
  });
}
