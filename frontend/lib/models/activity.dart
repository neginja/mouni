import "dates.dart";

class Activity {
  final String? id;
  final String groupId;
  final String name;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Activity({
    this.id,
    required this.groupId,
    required this.name,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      groupId: json['groupId'],
      name: json['name'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdAt: parseUTCToLocal(json['createdAt']),
      updatedAt: parseUTCToLocal(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'group_id': groupId,
      'name': name,
      'startDate': localToISO8601UTCString(startDate),
      'endDate': localToISO8601UTCString(endDate),
    };
  }
}

class ActivityStatus {
  final String status;

  ActivityStatus(this.status);

  factory ActivityStatus.fromJson(Map<String, dynamic> json) {
    return ActivityStatus(json['status']);
  }

  String prettyStatus() {
    return status.replaceAll('_', ' ');
  }
}
