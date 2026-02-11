import "dates.dart";
import 'expense_involved.dart';

class Expense {
  final String? id;
  final String description;
  final double amount;
  final String currency;
  final String paidBy;
  final List<ExpenseInvolved> involved;
  final DateTime date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.currency,
    required this.paidBy,
    required this.involved,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'],
      paidBy: json['paidBy'],
      involved: (json['involved'] as List)
          .map((i) => ExpenseInvolved.fromJson(i))
          .toList(),
      date: parseUTCToLocal(json['date'])!,
      createdAt: parseUTCToLocal(json['createdAt']),
      updatedAt: parseUTCToLocal(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'description': description,
      'amount': amount,
      'currency': currency,
      'paidBy': paidBy,
      'involved': involved.map((i) => i.toJson()).toList(),
      'date': localToISO8601UTCString(date),
    };
  }
}
