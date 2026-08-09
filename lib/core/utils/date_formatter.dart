const List<String> _kMonthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a timestamp for display in the admin app as a local date/time,
/// e.g. "Today • 8:42 PM", "Yesterday • 6:15 PM", "24 Jul • 8:42 PM".
///
/// [dateTime] must already be in local time — conversion from the backend's
/// UTC timestamps happens once, at parse time, in the repository layer
/// (see `ApiOrderRepository._mapOrder`). Do not call `.toLocal()` again here;
/// that would just be a confusing no-op on data that's already local.
String formatOrderTimestamp(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

  final hour12 = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  final timeStr = '$hour12:$minute $period';

  final String dayLabel;
  if (date == today) {
    dayLabel = 'Today';
  } else if (date == yesterday) {
    dayLabel = 'Yesterday';
  } else {
    dayLabel = '${dateTime.day} ${_kMonthAbbreviations[dateTime.month - 1]}';
  }

  return '$dayLabel • $timeStr';
}

/// Formats a plain date (no time-of-day) as e.g. "31 Aug" — used for promo
/// code validity/expiry, where only the calendar date matters. Same
/// month-abbreviation convention as [formatOrderTimestamp].
String formatShortDate(DateTime date) =>
    '${date.day} ${_kMonthAbbreviations[date.month - 1]}';

/// Formats a timestamp as a short relative string, e.g. "Just now",
/// "5 mins ago", "3 hrs ago", "2 days ago" — for compact contexts like a
/// notification list. [dateTime] must already be in local time (see
/// [formatOrderTimestamp]).
String formatRelativeTime(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60)
    return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
  if (diff.inHours < 24)
    return '${diff.inHours} hr${diff.inHours > 1 ? 's' : ''} ago';
  return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
}
