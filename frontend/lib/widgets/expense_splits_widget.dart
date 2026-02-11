import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mouni/misc/textstyle.dart';
import 'package:mouni/models/member.dart';
import 'package:mouni/models/expense_involved.dart';

class ExpenseSplitsWidget extends StatefulWidget {
  final double totalAmount;
  final String currency;
  final List<Member> members;
  final List<ExpenseInvolved> involved; // ← replaces selectedMembers
  final bool equalSplit;
  final ValueChanged<bool>? onEqualSplitChanged;
  final void Function(List<ExpenseInvolved>)? onSharesChanged;

  const ExpenseSplitsWidget({
    super.key,
    required this.totalAmount,
    required this.currency,
    required this.members,
    required this.involved,
    required this.equalSplit,
    this.onEqualSplitChanged,
    this.onSharesChanged,
  });

  @override
  State<ExpenseSplitsWidget> createState() => _ExpenseSplitsWidgetState();
}

class _ExpenseSplitsWidgetState extends State<ExpenseSplitsWidget> {
  bool equalSplit = true;
  final Set<String> lockedMembers = {};
  final Map<String, TextEditingController> shareControllers = {};
  final Map<String, FocusNode> focusNodes = {};

  @override
  void initState() {
    super.initState();

    for (var member in widget.members) {
      final controller = TextEditingController();
      final focus = FocusNode();

      focus.addListener(() {
        if (focus.hasFocus) {
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        } else {
          final val = double.tryParse(controller.text) ?? 0;
          _handleShareAfterEditing(member.id!, val);
        }
      });

      shareControllers[member.id!] = controller;
      focusNodes[member.id!] = focus;

      final existing = widget.involved.firstWhere(
        (e) => e.memberId == member.id,
        orElse: () => ExpenseInvolved(memberId: member.id!, share: 0),
      );
      controller.text = existing.share?.toStringAsFixed(2) ?? "0.00";
    }

    equalSplit = widget.equalSplit;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeShares());
  }

  void _initializeShares() {
    if (widget.involved.isEmpty) {
      final perHead = widget.members.isEmpty
          ? 0.0
          : widget.totalAmount / widget.members.length;
      for (var member in widget.members) {
        shareControllers[member.id!]!.text = perHead.toStringAsFixed(2);
        widget.involved.add(
          ExpenseInvolved(memberId: member.id!, share: perHead),
        );
      }
    } else {
      for (var involved in widget.involved) {
        shareControllers[involved.memberId]?.text = (involved.share ?? 0)
            .toStringAsFixed(2);
      }
    }

    _notifyParent();
  }

  @override
  void didUpdateWidget(covariant ExpenseSplitsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldIds = {for (final m in oldWidget.members) m.id!};
    final newIds = {for (final m in widget.members) m.id!};

    // Handle added members
    for (final id in newIds.difference(oldIds)) {
      shareControllers[id] = TextEditingController();
      focusNodes[id] = FocusNode();
    }

    // Handle removed members
    for (final id in oldIds.difference(newIds)) {
      shareControllers[id]?.dispose();
      focusNodes[id]?.dispose();
      shareControllers.remove(id);
      focusNodes.remove(id);
      widget.involved.removeWhere((e) => e.memberId == id);
      lockedMembers.remove(id);
    }

    if (oldWidget.totalAmount != widget.totalAmount ||
        !setEquals(oldIds, newIds)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _recalculateShares();
      });
    }
  }

  @override
  void dispose() {
    for (final c in shareControllers.values) {
      c.dispose();
    }
    for (final f in focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  void _toggleMember(String id, bool selected) {
    setState(() {
      if (selected) {
        if (!widget.involved.any((e) => e.memberId == id)) {
          widget.involved.add(ExpenseInvolved(memberId: id, share: 0));
        }
      } else {
        widget.involved.removeWhere((e) => e.memberId == id);
        lockedMembers.remove(id);
        shareControllers[id]?.text = "0.00";
      }
    });
    _recalculateShares();
  }

  void _recalculateShares([String? editedId]) {
    if (widget.involved.isEmpty) {
      _notifyParent();
      return;
    }

    final lockedSum = widget.involved
        .where((e) => lockedMembers.contains(e.memberId))
        .fold<double>(
          0,
          (sum, e) =>
              sum +
              (double.tryParse(shareControllers[e.memberId]?.text ?? '') ??
                  0.0),
        );

    final remaining = widget.totalAmount - lockedSum;

    final unlocked = widget.involved
        .where((e) => !lockedMembers.contains(e.memberId))
        .map((e) => e.memberId)
        .toList();

    final perHead = unlocked.isEmpty ? 0.0 : remaining / unlocked.length;

    for (final id in unlocked) {
      if (id == editedId) continue;
      final controller = shareControllers[id]!;
      if (controller.text != perHead.toStringAsFixed(2)) {
        controller.text = perHead.toStringAsFixed(2);
      }
    }

    _notifyParent();
  }

  void _notifyParent() {
    widget.onSharesChanged?.call(
      widget.involved
          .map(
            (e) => ExpenseInvolved(
              memberId: e.memberId,
              share:
                  double.tryParse(shareControllers[e.memberId]?.text ?? '') ??
                  0.0,
            ),
          )
          .toList(),
    );
  }

  void _handleShareAfterEditing(String id, double val) {
    lockedMembers.add(id);

    final othersTotal = widget.involved
        .where((e) => e.memberId != id)
        .fold<double>(
          0,
          (sum, e) =>
              sum + (double.tryParse(shareControllers[e.memberId]!.text) ?? 0),
        );

    double corrected = val;

    if (val < 0) {
      corrected = (widget.totalAmount - othersTotal).clamp(
        0,
        widget.totalAmount,
      );
      shareControllers[id]!.text = corrected.toStringAsFixed(2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Negative values are not allowed")),
      );
      FocusScope.of(context).unfocus();
    } else if (val > widget.totalAmount) {
      corrected = (widget.totalAmount - othersTotal).clamp(
        0,
        widget.totalAmount,
      );
      shareControllers[id]!.text = corrected.toStringAsFixed(2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Shares exceed total amount, value has been adjusted"),
        ),
      );
      FocusScope.of(context).unfocus();
    }

    _recalculateShares(id);
  }

  void _onShareChanged(String id, String value) {
    final val = double.tryParse(value);
    if (val == null) return;
    lockedMembers.add(id);
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.currency;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text("Equal Split"),
          value: equalSplit,
          onChanged: (v) {
            widget.onEqualSplitChanged?.call(v);
            setState(() {
              equalSplit = v;
              lockedMembers.clear();
              if (equalSplit) {
                widget.involved.clear();
                for (var member in widget.members) {
                  widget.involved.add(
                    ExpenseInvolved(memberId: member.id!, share: 0),
                  );
                }
              }
              _recalculateShares();
            });
          },
        ),
        const SizedBox(height: 12),
        const Text(
          "Involved Members:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Wrap(
          spacing: 6,
          children: widget.members.map((m) {
            final isSelected = widget.involved.any((e) => e.memberId == m.id);
            final amountText = shareControllers[m.id]?.text ?? '';
            return FilterChip(
              label: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(m.name),
                  if (amountText.isNotEmpty)
                    Text("$amountText $currency", style: smallLabelTT),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) => _toggleMember(m.id!, selected),
            );
          }).toList(),
        ),
        if (!equalSplit)
          Column(
            children: widget.involved.map((e) {
              final id = e.memberId;
              final isLocked = lockedMembers.contains(id);
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  controller: shareControllers[id],
                  focusNode: focusNodes[id],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        "${widget.members.firstWhere((m) => m.id == id).name}'s share",
                    suffixIcon: isLocked ? const Icon(Icons.lock) : null,
                  ),
                  onChanged: (v) => _onShareChanged(id, v),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
