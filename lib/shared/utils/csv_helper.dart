class CsvHelper {
  /// Parse CSV content into rows and fields.
  /// Supports quoted fields with embedded newlines and preserves escaped
  /// double-quotes as two quote characters to match project expectations.
  static List<List<String>> parseCsv(String csvContent) {
    final rows = <List<String>>[];
    final field = StringBuffer();
    final currentRow = <String>[];
    bool inQuotes = false;

    for (int i = 0; i < csvContent.length; i++) {
      final char = csvContent[i];

      if (char == '"') {
        if (inQuotes && i + 1 < csvContent.length && csvContent[i + 1] == '"') {
          // Preserve the double-quote sequence as two quote characters
          field.write('""');
          i++; // skip the second quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        currentRow.add(field.toString());
        field.clear();
      } else if ((char == '\n' || char == '\r') && !inQuotes) {
        // Handle CRLF as single newline
        if (char == '\r' && i + 1 < csvContent.length && csvContent[i + 1] == '\n') {
          i++;
        }
        currentRow.add(field.toString());
        field.clear();

        final isEmptyRow = currentRow.every((c) => c.trim().isEmpty);
        if (!isEmptyRow) rows.add(List<String>.from(currentRow));
        currentRow.clear();
      } else {
        field.write(char);
      }
    }

    if (field.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(field.toString());
      final isEmptyRow = currentRow.every((c) => c.trim().isEmpty);
      if (!isEmptyRow) rows.add(List<String>.from(currentRow));
    }

    return rows;
  }

  /// Count CSV rows that are complete (have data for every header column).
  static int countCsvRows(String csvContent) {
    final rows = parseCsv(csvContent);
    if (rows.isEmpty) return 0;

    int expectedColumns;
    int startIndex = 0;

    expectedColumns = rows.first.length;
    startIndex = 1;

    int count = 0;
    for (int i = startIndex; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < expectedColumns) continue;

      count++;
    }
    return count;
  }

  static Map<String, String> mapCsvRowToHeader(List<String> header, List<String> row) {
    final map = <String, String>{};
    for (int i = 0; i < header.length && i < row.length; i++) {
      map[header[i]] = row[i];
    }
    return map;
  }
}
