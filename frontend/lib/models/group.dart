import "dates.dart";
import 'member.dart';

class Group {
  final String? id;
  final String name;
  final List<Member>? members;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Group({
    this.id,
    required this.name,
    this.members,
    this.createdAt,
    this.updatedAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'],
      name: json['name'],
      members: json['members'] != null
          ? (json['members'] as List).map((m) => Member.fromJson(m)).toList()
          : null,
      createdAt: parseUTCToLocal(json['createdAt']),
      updatedAt: parseUTCToLocal(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (members != null) 'members': members!.map((m) => m.toJson()).toList(),
    };
  }
}
