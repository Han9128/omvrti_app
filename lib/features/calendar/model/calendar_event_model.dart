class CalendarEventModel {
  final String id;
  final String summary;
  final String? description;
  final String? location;
  final String? startDateTime;
  final String? startDate;
  final String? endDateTime;
  final String? endDate;

  const CalendarEventModel({
    required this.id,
    required this.summary,
    this.description,
    this.location,
    this.startDateTime,
    this.startDate,
    this.endDateTime,
    this.endDate,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      description: json['description'] as String?,
      location: json['location'] as String?,
      startDateTime: json['startDateTime'] as String?,
      startDate: json['startDate'] as String?,
      endDateTime: json['endDateTime'] as String?,
      endDate: json['endDate'] as String?,
    );
  }

  DateTime? get startTime {
    if (startDateTime != null) return DateTime.tryParse(startDateTime!);
    if (startDate != null) return DateTime.tryParse(startDate!);
    return null;
  }
}
