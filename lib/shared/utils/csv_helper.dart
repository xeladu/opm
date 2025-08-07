class CsvHelper {
  static List<List<String>> parseCsv(String csvContent) {
    final lines = csvContent.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return lines.map(_parseCsvLine).toList();
  }

  static Map<String, String> mapCsvRowToHeader(List<String> header, List<String> row) {
    final map = <String, String>{};
    for (int i = 0; i < header.length && i < row.length; i++) {
      map[header[i]] = row[i];
    }
    return map;
  }

  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString());
    return result;
  }
}
