class RunningGroupResponse {
  final String message;
  final List<RunningGroup> groups;

  RunningGroupResponse({required this.message, required this.groups});

  factory RunningGroupResponse.fromJson(Map<String, dynamic> json) {
    return RunningGroupResponse(
      message: json['message'],
      groups: (json['Running Group'] as List)
          .map((e) => RunningGroup.fromJson(e))
          .toList(),
    );
  }
}

class RunningGroup {
  final int id;
  final String track;
  final String code;
  final String title;
  final String days;
  final String room;
  final String branch;
  final String instructor;
  final String time;
  final String level;
  final String start;
  final String end;
  final Seat seats;
  final int price;
  final String status;
  final int sessionsCount;
  final String digitalMaterial;

  RunningGroup({
    required this.id,
    required this.track,
    required this.code,
    required this.title,
    required this.days,
    required this.room,
    required this.branch,
    required this.instructor,
    required this.time,
    required this.level,
    required this.start,
    required this.end,
    required this.seats,
    required this.price,
    required this.status,
    required this.sessionsCount,
    required this.digitalMaterial,
  });

  factory RunningGroup.fromJson(Map<String, dynamic> json) {
    return RunningGroup(
      id: json['id'],
      track: json['Track'],
      code: json['code'],
      title: json['title'],
      days: json['Days'],
      room: json['Room'],
      branch: json['Branch'] ?? "",
      instructor: json['Instructor'],
      time: json['Time'],
      level: json['Level'] ?? "",
      start: json['Start'],
      end: json['End'],
      seats: Seat.fromJson(json['seats']),
      price: json['price'],
      status: json['status'],
      sessionsCount: json['sessions_count'],
      digitalMaterial: json['digital_material'],
    );
  }
}

class Seat {
  final int total;
  final int available;

  Seat({required this.total, required this.available});

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      total: json['total'],
      available: json['available'],
    );
  }
}
