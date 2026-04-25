class SubCalendarModel {
  final int id;
  final String syncCalendarId;
  final String displayName;
  final String color;
  final bool isPrimary;
  final bool isSyncOn;
  final bool isWritable;
  final String timeZone;

  const SubCalendarModel({
    required this.id,
    required this.syncCalendarId,
    required this.displayName,
    required this.color,
    required this.isPrimary,
    required this.isSyncOn,
    required this.isWritable,
    required this.timeZone,
  });

  factory SubCalendarModel.fromJson(Map<String, dynamic> json) {
    return SubCalendarModel(
      id: (json['id'] as num).toInt(),
      syncCalendarId: json['syncCalendarId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      color: json['color'] as String? ?? '#9fe1e7',
      isPrimary: json['isPrimary'] as bool? ?? false,
      isSyncOn: json['isSyncOn'] as bool? ?? false,
      isWritable: json['isWritable'] as bool? ?? false,
      timeZone: json['timeZone'] as String? ?? '',
    );
  }

  String get label {
    if (displayName.isNotEmpty) return displayName;
    if (syncCalendarId.isNotEmpty) return syncCalendarId;
    return 'Unknown';
  }

  SubCalendarModel copyWith({bool? isSyncOn}) => SubCalendarModel(
        id: id,
        syncCalendarId: syncCalendarId,
        displayName: displayName,
        color: color,
        isPrimary: isPrimary,
        isSyncOn: isSyncOn ?? this.isSyncOn,
        isWritable: isWritable,
        timeZone: timeZone,
      );
}
