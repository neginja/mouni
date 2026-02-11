class ExpenseInvolved {
  final String memberId;
  final double? share;

  ExpenseInvolved({required this.memberId, this.share});

  factory ExpenseInvolved.fromJson(Map<String, dynamic> json) {
    return ExpenseInvolved(
      memberId: json['memberId'],
      share: json['share'] != null ? (json['share'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'memberId': memberId, if (share != null) 'share': share};
  }
}
