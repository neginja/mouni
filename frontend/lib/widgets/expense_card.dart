import 'package:flutter/material.dart';
import 'package:mouni/misc/textstyle.dart';
import 'package:mouni/models/dates.dart';
import 'package:mouni/models/expense.dart';
import 'package:mouni/providers/member_provider.dart';
import 'package:provider/provider.dart';

class ExpenseCard extends StatefulWidget {
  final Expense expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ExpenseCard> createState() => _ExpenseCardState();
}

class _ExpenseCardState extends State<ExpenseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);

    final paidByMember = memberProvider.getMemberById(widget.expense.paidBy);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.expense.description, style: cardTitleTT),
            subtitle: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${widget.expense.amount.toStringAsFixed(2)} ${widget.expense.currency}",
                          style: valueDisplayTT,
                        ),
                        const TextSpan(text: " • "),
                        TextSpan(
                          text:
                              "Paid by: ${paidByMember?.name ?? widget.expense.paidBy}",
                          style: detailsDisplayTT,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Text("Date: ", style: fieldNameTT),
                      Expanded(
                        child: Text(
                          formatDateWithHour(widget.expense.date),
                          style: valueDisplayTT,
                        ),
                      ),
                    ],
                  ),
                  Text("Involved Members: ", style: fieldNameTT),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.expense.involved.map((i) {
                      final member = memberProvider.getMemberById(i.memberId);
                      final shareAmount = i.share ?? 0;
                      final sharePct =
                          ((shareAmount / widget.expense.amount) * 100);
                      final shareText = i.share != null
                          ? "${shareAmount.toStringAsFixed(2)} ${widget.expense.currency} (${sharePct.toStringAsFixed(0)}%)"
                          : "N/A";

                      return Chip(
                        label: Text(
                          "${member?.name ?? i.memberId}: $shareText",
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        labelStyle: valueDisplayTT,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: widget.onEdit,
                        ),
                      if (widget.onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: widget.onDelete,
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
