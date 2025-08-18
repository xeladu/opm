import 'package:flutter_test/flutter_test.dart';
import 'package:open_password_manager/shared/utils/csv_helper.dart';

void main() {
  group('Test CsvHelper', () {
    test('parseCsv parses simple CSV', () {
      final csv = 'a,b,c\n1,2,3\n4,5,6';
      final result = CsvHelper.parseCsv(csv);
      expect(result, [
        ['a', 'b', 'c'],
        ['1', '2', '3'],
        ['4', '5', '6'],
      ]);
    });

    test('parseCsv ignores empty lines', () {
      final csv = 'a,b\n\n1,2\n\n';
      final result = CsvHelper.parseCsv(csv);
      expect(result, [
        ['a', 'b'],
        ['1', '2'],
      ]);
    });

    test('parseCsv handles quoted fields with commas', () {
      final csv = 'a,"b,b",c\n1,2,3';
      final result = CsvHelper.parseCsv(csv);
      expect(result, [
        ['a', 'b,b', 'c'],
        ['1', '2', '3'],
      ]);
    });

    test('parseCsv handles quoted fields with quotes', () {
      final csv = 'a,"b""b",c\n1,2,3';
      final result = CsvHelper.parseCsv(csv);
      expect(result, [
        ['a', 'b""b', 'c'],
        ['1', '2', '3'],
      ]);
    });

    test('mapCsvRowToHeader maps row to header', () {
      final header = ['name', 'age', 'city'];
      final row = ['Alice', '30', 'Paris'];
      final map = CsvHelper.mapCsvRowToHeader(header, row);
      expect(map, {'name': 'Alice', 'age': '30', 'city': 'Paris'});
    });

    test('mapCsvRowToHeader handles row shorter than header', () {
      final header = ['name', 'age', 'city'];
      final row = ['Bob', '25'];
      final map = CsvHelper.mapCsvRowToHeader(header, row);
      expect(map, {'name': 'Bob', 'age': '25'});
    });

    test('mapCsvRowToHeader handles row longer than header', () {
      final header = ['name', 'age'];
      final row = ['Carol', '40', 'London'];
      final map = CsvHelper.mapCsvRowToHeader(header, row);
      expect(map, {'name': 'Carol', 'age': '40'});
    });

    test('_parseCsvLine handles empty line', () {
      final result = CsvHelper.parseCsv('\n');
      expect(result, []);
    });

    test('_parseCsvLine handles single value', () {
      final result = CsvHelper.parseCsv('abc');
      expect(result, [
        ['abc'],
      ]);
    });

    test('parseCsv handles trailing commas', () {
      final csv = 'a,b,c,\n1,2,3,';
      final result = CsvHelper.parseCsv(csv);
      expect(result, [
        ['a', 'b', 'c', ''],
        ['1', '2', '3', ''],
      ]);
    });

    test("Test complex CSV", () {
      final csv =
          """
a,b,c,d,e,f\n1,2,3,4\n5\n6,7,8
1,2,3,4,5\n6\n7,8
1\n2,3\n4,5,6,7,8
"""
              .trim();

      final result = CsvHelper.parseCsv(csv);
      expect(result, [
        ['a', 'b', 'c', 'd', 'e', 'f'],
        ['1', '2', '3', '4'],
        ['5'],
        ['6', '7', '8'],
        ['1', '2', '3', '4', '5'],
        ['6'],
        ['7', '8'],
        ['1'],
        ['2', '3'],
        ['4', '5', '6', '7', '8'],
      ]);
    });
  });

  test('countCsvRows with header counts complete rows', () {
    final csv = 'a,b,c\n1,2,3\n4,5,6\n';
    final count = CsvHelper.countCsvRows(csv);
    expect(count, 2);
  });

  test('countCsvRows handles quoted multiline fields', () {
    final csv =
        'a,b,notes\n'
        '1,2,"line1\nline2"\n'
        '3,4,ok\n';

    final count = CsvHelper.countCsvRows(csv);
    expect(count, 2);
  });
}
