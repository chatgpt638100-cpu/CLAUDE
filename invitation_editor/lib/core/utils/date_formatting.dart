/// Turns a timestamp into the short, human phrasing the Library uses
/// under each thumbnail ("Edited just now", "Edited yesterday").
///
/// Deliberately relative and wordy rather than a bare date: "Edited
/// yesterday" is easier to place than "29/07/2026", and this audience is
/// scanning for *which* invitation, not auditing a timestamp.
///
/// No `intl` dependency — the app ships one locale and this keeps the
/// offline dependency list short.
String formatLastEdited(DateTime timestamp, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final difference = reference.difference(timestamp);

  if (difference.inMinutes < 1) return 'Edited just now';
  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return 'Edited $minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  }
  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return 'Edited $hours ${hours == 1 ? 'hour' : 'hours'} ago';
  }
  if (difference.inDays == 1) return 'Edited yesterday';
  if (difference.inDays < 7) return 'Edited ${difference.inDays} days ago';

  return 'Edited ${_day(timestamp)} ${_month(timestamp.month)}'
      '${timestamp.year == reference.year ? '' : ' ${timestamp.year}'}';
}

String _day(DateTime date) => date.day.toString();

String _month(int month) => const [
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
    ][month - 1];

/// Human-readable file size for the Settings storage row.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
