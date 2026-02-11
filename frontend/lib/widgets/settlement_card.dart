import 'package:flutter/material.dart';
import 'package:mouni/misc/colors.dart';
import 'package:mouni/providers/activity_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mouni/models/settlement.dart';
import 'package:mouni/providers/settlement_provider.dart';
import 'package:mouni/providers/member_provider.dart';
import 'package:mouni/misc/textstyle.dart';

class SettlementCard extends StatelessWidget {
  final String groupId;
  final String activityId;
  final Settlement settlement;

  const SettlementCard({
    super.key,
    required this.groupId,
    required this.activityId,
    required this.settlement,
  });

  Future<void> _markAsPaid(
    BuildContext context,
    Settlement currentSettlement,
    String fromName,
    String toName,
  ) async {
    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Payment"),
        content: Text(
          "Mark this settlement from $fromName to $toName as paid?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await settlementProvider.updateSettlementStatus(
      groupId,
      activityId,
      currentSettlement.id!,
      true,
    );

    if (!context.mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!, style: errorTT),
          backgroundColor: softRed,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Settlement marked as paid")),
      );
    }
    final statusProvider = Provider.of<ActivityStatusProvider>(
      context,
      listen: false,
    );
    // refresh activity status
    statusProvider.fetchActivityStatus(groupId, activityId);
  }

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);

    final fromMember =
        memberProvider.getMemberById(settlement.fromMember)?.name ??
        settlement.fromMember;
    final toMember =
        memberProvider.getMemberById(settlement.toMember)?.name ??
        settlement.toMember;

    return Consumer<SettlementProvider>(
      builder: (context, settlementProvider, _) {
        final currentSettlement = settlementProvider
            .getSettlements(activityId)
            .firstWhere((s) => s.id == settlement.id, orElse: () => settlement);

        final isPaid = currentSettlement.paid == true;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$fromMember → $toMember", style: cardTitleTT),
                const SizedBox(height: 4),
                Text(
                  "${currentSettlement.amount.toStringAsFixed(2)} ${currentSettlement.currency}",
                  style: valueDisplayTT,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text("Status: ", style: fieldNameTT),
                    Text(
                      isPaid ? "Paid 🤑" : "Unpaid 🥹",
                      style: isPaid
                          ? detailsDisplayTT.copyWith(color: Colors.green)
                          : detailsDisplayTT.copyWith(color: Colors.red),
                    ),
                  ],
                ),
                if (currentSettlement.paidOn != null)
                  Row(
                    children: [
                      Text("Paid On: ", style: fieldNameTT),
                      Text(
                        DateFormat(
                          'yyyy-MM-dd HH:mm',
                        ).format(currentSettlement.paidOn!.toLocal()),
                        style: valueDisplayTT,
                      ),
                    ],
                  ),
                if (!isPaid)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Mark as Paid"),
                      onPressed: () => _markAsPaid(
                        context,
                        currentSettlement,
                        fromMember,
                        toMember,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
