class TripEventModel {
  final String id;
  final String tripId;
  final int sequenceOrder;
  final String title;
  final String? eventStartDatetime;
  final String? eventEndDatetime;
  final String? eventTimezone;
  final bool allDay;
  final String? venueName;
  final String? addressLine1;

  const TripEventModel({
    required this.id,
    required this.tripId,
    required this.sequenceOrder,
    required this.title,
    this.eventStartDatetime,
    this.eventEndDatetime,
    this.eventTimezone,
    this.allDay = false,
    this.venueName,
    this.addressLine1,
  });

  factory TripEventModel.fromJson(Map<String, dynamic> json) {
    return TripEventModel(
      id: json['id'] as String? ?? '',
      tripId: json['tripId'] as String? ?? '',
      sequenceOrder: json['sequenceOrder'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      eventStartDatetime: json['eventStartDatetime'] as String?,
      eventEndDatetime: json['eventEndDatetime'] as String?,
      eventTimezone: json['eventTimezone'] as String?,
      allDay: json['allDay'] as bool? ?? false,
      venueName: json['venueName'] as String?,
      addressLine1: json['addressLine1'] as String?,
    );
  }

  DateTime? get startTime {
    if (eventStartDatetime != null) return DateTime.tryParse(eventStartDatetime!);
    return null;
  }

  DateTime? get endTime {
    if (eventEndDatetime != null) return DateTime.tryParse(eventEndDatetime!);
    return null;
  }
}

class CalendarEventModel {
  final String id;
  final String title;
  final String? status;
  final String? mode;
  final String? departureDate;
  final String? returnDate;
  final String? originCity;
  final bool fromCalendar;
  final List<TripEventModel> tripEvents;

  const CalendarEventModel({
    required this.id,
    required this.title,
    this.status,
    this.mode,
    this.departureDate,
    this.returnDate,
    this.originCity,
    this.fromCalendar = false,
    this.tripEvents = const [],
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['tripEvents'] as List<dynamic>? ?? [];
    return CalendarEventModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      status: json['status'] as String?,
      mode: json['mode'] as String?,
      departureDate: json['departureDate'] as String?,
      returnDate: json['returnDate'] as String?,
      originCity: json['originCity'] as String?,
      fromCalendar: json['fromCalendar'] as bool? ?? false,
      tripEvents: rawEvents
          .map((e) => TripEventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  DateTime? get startTime {
    if (departureDate != null) return DateTime.tryParse(departureDate!);
    return null;
  }
}
