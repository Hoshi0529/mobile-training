const double caloriesPerAlcoholGram = 8.5;

class DailyRecordSummary {
  const DailyRecordSummary({required this.date, required this.records});

  final DateTime date;
  final List<Map<String, dynamic>> records;

  double get alcoholGrams => records.fold<double>(0, (sum, record) {
    final value = record['alcoholGrams'];
    if (value is num) {
      return sum + value.toDouble();
    }
    return sum + (double.tryParse(value.toString()) ?? 0);
  });

  int get calories => (alcoholGrams * caloriesPerAlcoholGram).round();
}

class RecordSummary {
  const RecordSummary({required this.restDays, required this.overGoalDays});

  final int restDays;
  final int overGoalDays;
}
