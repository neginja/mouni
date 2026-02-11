DateTime? parseUTCToLocal(String? value) {
  if (value == null) return null;
  // Ensure the string ends with 'Z' to indicate UTC
  final utcString = value.endsWith('Z') ? value : '${value}Z';
  return DateTime.parse(utcString).toLocal();
}

String? localToISO8601UTCString(DateTime? value) {
  if (value == null) return null;
  return value.toUtc().toIso8601String();
}

String? localToISO8601DateOnlyString(DateTime? value) {
  if (value == null) return null;
  return value.toUtc().toIso8601String().split('T').first;
}

String formatDateOnly(DateTime? date) {
  if (date == null) return "N/A";
  return date.toLocal().toString().split(' ')[0];
}

String formatDateWithHour(DateTime date) {
  return "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')} "
      "${date.hour.toString().padLeft(2, '0')}:"
      "${date.minute.toString().padLeft(2, '0')}";
}
