import "dates.dart";

class Settlement {
  final String? id;
  final String fromMember;
  final String toMember;
  final double amount;
  final String currency;
  final bool? paid;
  final DateTime? paidOn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Settlement({
    this.id,
    required this.fromMember,
    required this.toMember,
    required this.amount,
    required this.currency,
    this.paid,
    this.paidOn,
    this.createdAt,
    this.updatedAt,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'],
      fromMember: json['fromMember'],
      toMember: json['toMember'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      paid: json['paid'],
      paidOn: parseUTCToLocal(json['paidOn']),
      createdAt: parseUTCToLocal(json['createdAt']),
      updatedAt: parseUTCToLocal(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'fromMember': fromMember,
      'toMember': toMember,
      'amount': amount,
      'currency': currency,
      if (paid != null) 'paid': paid,
      'paidOn': localToISO8601UTCString(paidOn),
    };
  }
}
