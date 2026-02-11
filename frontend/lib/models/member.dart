import "dates.dart";

class Member {
  final String? id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Member({this.id, required this.name, this.createdAt, this.updatedAt});

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      name: json['name'],
      createdAt: parseUTCToLocal(json['createdAt']),
      updatedAt: parseUTCToLocal(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'name': name};
  }
}
