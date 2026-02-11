import 'package:flutter/material.dart';
import 'package:mouni/misc/colors.dart';
import 'package:mouni/misc/textstyle.dart';
import 'package:mouni/models/expense.dart';
import 'package:mouni/models/settlement.dart';
import 'package:mouni/models/member.dart';
import 'package:mouni/models/activity.dart';

class ActivityStatsCard extends StatelessWidget {
  final List<Expense> expenses;
  final List<Settlement> settlements;
  final List<Member> members;
  final ActivityStatus? activityStatus; // Injected activity status

  const ActivityStatsCard({
    super.key,
    required this.expenses,
    required this.settlements,
    required this.members,
    this.activityStatus,
  });

  Map<String, double> _totalsByCurrency(List<Expense> expenses) {
    final Map<String, double> totalsByCurrency = {};
    for (var expense in expenses) {
      totalsByCurrency[expense.currency] =
          (totalsByCurrency[expense.currency] ?? 0) + expense.amount;
    }
    return totalsByCurrency;
  }

  String _memberName(String memberId, Map<String, Member> lookup) {
    return lookup[memberId]?.name ?? "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    final totals = _totalsByCurrency(expenses);
    final totalExpenses = expenses.length;

    final memberLookup = {for (var m in members) m.id!: m};

    return Card(
      color: statsBGCol,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expense totals section
            Row(
              children: [
                Text("Total expenses:", style: statsFieldNameTT),
                const SizedBox(width: 4),
                Text("$totalExpenses", style: valueDisplayTT),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              children: totals.entries.map((e) {
                return Text(
                  "${e.value.toStringAsFixed(2)} ${e.key}",
                  style: statsValueDisplayTT,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // Activity status
            if (activityStatus != null) ...[
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor(activityStatus!.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    activityStatus!.prettyStatus(),
                    style: statsValueDisplayTT.copyWith(
                      color: statusColor(activityStatus!.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Settlements section
            if (settlements.isNotEmpty) ...[
              Text("Current settlement(s):", style: statsFieldNameTT),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: settlements.map((s) {
                  final fromName = _memberName(s.fromMember, memberLookup);
                  final toName = _memberName(s.toMember, memberLookup);
                  final text =
                      "📉 $fromName 💸 $toName 📈: ${s.amount.toStringAsFixed(2)} ${s.currency}";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(text, style: statsValueDisplayTT),
                  );
                }).toList(),
              ),
            ] else
              Text("No settlements", style: statsFieldNameTT),
          ],
        ),
      ),
    );
  }
}
