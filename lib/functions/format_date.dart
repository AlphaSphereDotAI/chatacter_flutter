import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));

  final dateFormatter = DateFormat('MM/dd/yyyy hh:mm a');

  if (date.year == now.year && date.month == now.month && date.day == now.day) {
    // Today 12:45 PM
    return 'Today ${DateFormat('hh:mm a').format(date)}';
  }

  if (date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day) {
    // Yesterday 12:45 PM
    return 'Yesterday ${DateFormat('hh:mm a').format(date)}';
  }

  return dateFormatter.format(date);
}
