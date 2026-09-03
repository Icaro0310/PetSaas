import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/core/utils/extensions.dart';

void main() {
  group('StringX.capitalize', () {
    test('capitaliza primeira letra', () {
      expect('hello'.capitalize(), 'Hello');
      expect('world'.capitalize(), 'World');
    });

    test('string vazia retorna vazia', () {
      expect(''.capitalize(), '');
    });

    test('string de 1 char', () {
      expect('a'.capitalize(), 'A');
    });

    test('nao altera ja capitalizada', () {
      expect('Hello'.capitalize(), 'Hello');
    });

    test('nao altera resto da string', () {
      expect('hELLO'.capitalize(), 'HELLO');
    });
  });

  group('DateTimeX.dateOnly', () {
    test('remove horas/minutos/segundos', () {
      final dt = DateTime(2025, 3, 15, 14, 30, 45);
      expect(dt.dateOnly, DateTime(2025, 3, 15));
    });

    test('meia-noite mantem igual', () {
      final dt = DateTime(2025, 3, 15);
      expect(dt.dateOnly, DateTime(2025, 3, 15));
    });
  });

  group('DateTimeX.isToday', () {
    test('agora e today', () {
      expect(DateTime.now().isToday, true);
    });

    test('ontem nao e today', () {
      expect(DateTime.now().subtract(const Duration(days: 1)).isToday, false);
    });

    test('amanha nao e today', () {
      expect(DateTime.now().add(const Duration(days: 1)).isToday, false);
    });
  });
}
