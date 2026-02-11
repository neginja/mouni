import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:mouni/api/api_result.dart';
import 'package:mouni/misc/colors.dart';
import 'package:mouni/misc/textstyle.dart';
import 'package:mouni/models/activity.dart';
import 'package:mouni/models/dates.dart';
import 'package:mouni/models/expense_involved.dart';
import 'package:mouni/models/group.dart';
import 'package:provider/provider.dart';
import 'package:mouni/models/expense.dart';
import 'package:mouni/providers/expense_provider.dart';
import 'package:mouni/providers/member_provider.dart';
import 'package:mouni/widgets/expense_splits_widget.dart';

class ManageExpenseScreen extends StatefulWidget {
  final Group group;
  final Activity activity;
  final Expense? expense;

  const ManageExpenseScreen({
    super.key,
    required this.group,
    required this.activity,
    this.expense,
  });

  @override
  State<ManageExpenseScreen> createState() => _ManageExpenseScreenState();
}

class _ManageExpenseScreenState extends State<ManageExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _descFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  String _currency = "JPY";
  String? _paidById;
  DateTime _selectedDate = DateTime.now();
  bool _equalSplit = true;

  // NEW state variables
  double _amount = 0;
  final Set<String> _selectedMembers = {};
  final Map<String, double> _involvedMap = {};

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;

    _descFocus.addListener(() {
      if (_descFocus.hasFocus) {
        _descController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _descController.text.length,
        );
      }
    });
    _amountFocus.addListener(() {
      if (_amountFocus.hasFocus) {
        _amountController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _amountController.text.length,
        );
      }
    });

    if (expense != null) {
      _descController.text = expense.description;
      _amountController.text = expense.amount.toString();
      _amount = expense.amount;
      _currency = expense.currency;
      _paidById = expense.paidBy;
      _selectedDate = expense.date;

      for (final i in expense.involved) {
        _selectedMembers.add(i.memberId);
        _involvedMap[i.memberId] = i.share ?? 0;
      }

      // Detect equal split
      if (_involvedMap.isNotEmpty) {
        final values = _involvedMap.values.toList();
        final first = values.first;
        final allEqual = values.every((v) => (v - first).abs() < 0.01);
        _equalSplit = allEqual;
      }
    } else {
      final members = Provider.of<MemberProvider>(
        context,
        listen: false,
      ).getMembers(widget.group.id!);

      for (final m in members) {
        _selectedMembers.add(m.id!);
        _involvedMap[m.id!] = 0;
      }

      if (members.isNotEmpty) {
        _paidById = members.first.id!;
      }
    }

    _amountController.addListener(() {
      setState(() {
        _amount = double.tryParse(_amountController.text) ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _descFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DatePicker.showDateTimePicker(
      context,
      showTitleActions: true,
      currentTime: _selectedDate,
      locale: LocaleType.en,
      onConfirm: (date) {
        setState(() {
          _selectedDate = date;
        });
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final members = widget.group.members!;
    final selectedIds = _selectedMembers.toList();

    // Compute shares
    Map<String, double> finalShares = {};
    if (_equalSplit) {
      if (selectedIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "At least one member must be involved",
              style: errorTT,
            ),
            backgroundColor: softRed,
          ),
        );
        return;
      }
      final perHead = _amount / selectedIds.length;
      for (final id in selectedIds) {
        finalShares[id] = perHead;
      }

      // Fix rounding drift (last member gets the remainder)
      double total = finalShares.values.fold(0, (a, b) => a + b);
      double diff = _amount - total;
      if (diff.abs() > 0.01) {
        finalShares[selectedIds.last] = (finalShares[selectedIds.last]! + diff);
      }
    } else {
      // Respect manual shares (default 0 if missing)
      for (final id in selectedIds) {
        finalShares[id] = _involvedMap[id] ?? 0;
      }
    }

    final data = {
      "description": _descController.text,
      "amount": _amount,
      "currency": _currency,
      "paidBy": _paidById ?? (members.isNotEmpty ? members.first.id! : ""),
      "involved": finalShares.entries
          .map((e) => {"memberId": e.key, "share": e.value})
          .toList(),
      "equalSplit": _equalSplit,
      "date": localToISO8601UTCString(_selectedDate),
    };

    final provider = context.read<ExpenseProvider>();
    ApiResult<Expense> result;
    if (widget.expense == null) {
      result = await provider.addExpense(
        widget.group.id!,
        widget.activity.id!,
        data,
      );
    } else {
      result = await provider.updateExpense(
        widget.group.id!,
        widget.activity.id!,
        widget.expense!.id!,
        data,
      );
    }

    if (!mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!, style: errorTT),
          backgroundColor: softRed,
        ),
      );
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<MemberProvider>().getMembers(
      widget.group.id!,
    );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.activity.name, style: detailsDisplayTT),
            Text(
              widget.expense == null ? "Add Expense" : "Edit Expense",
              style: screenTitleTT,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descController,
                focusNode: _descFocus,
                decoration: const InputDecoration(
                  labelText: "Description",
                  labelStyle: labelTT,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Required";
                  if (v.trim().length < 3) {
                    return "Must be at least 3 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                focusNode: _amountFocus,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  labelStyle: labelTT,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Required";
                  }
                  final parsed = double.tryParse(v);
                  if (parsed == null) {
                    return "Invalid number";
                  }
                  if (parsed <= 0) {
                    return "Must be > 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _currency,
                decoration: const InputDecoration(
                  labelText: "Currency",
                  labelStyle: labelTT,
                ),
                items:
                    const [
                          "JPY",
                          "USD",
                          "EUR",
                          "GBP",
                          "AUD",
                          "CAD",
                          "CHF",
                          "CNY",
                          "HKD",
                          "SGD",
                        ]
                        .map(
                          (code) =>
                              DropdownMenuItem(value: code, child: Text(code)),
                        )
                        .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _currency = v);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text("Date: ", style: fieldNameTT),
                  Expanded(
                    child: Text(
                      formatDateWithHour(_selectedDate),
                      style: valueDisplayTT,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text("Pick", style: saveButtonTT),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue:
                    _paidById ?? (members.isNotEmpty ? members.first.id : null),
                decoration: const InputDecoration(
                  labelText: "Paid By",
                  labelStyle: labelTT,
                ),
                items: members
                    .map(
                      (m) => DropdownMenuItem(value: m.id, child: Text(m.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _paidById = v),
              ),
              const SizedBox(height: 12),
              ExpenseSplitsWidget(
                totalAmount: _amount,
                currency: _currency,
                members: members,
                involved: _involvedMap.entries
                    .map(
                      (e) => ExpenseInvolved(memberId: e.key, share: e.value),
                    )
                    .toList(),
                equalSplit: _equalSplit,
                onEqualSplitChanged: (v) {
                  setState(() => _equalSplit = v);
                },
                onSharesChanged: (shares) {
                  setState(() {
                    _involvedMap
                      ..clear()
                      ..addEntries(
                        shares.map((s) => MapEntry(s.memberId, s.share ?? 0)),
                      );

                    _selectedMembers
                      ..clear()
                      ..addAll(shares.map((s) => s.memberId));
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        label: const Text("Save", style: saveButtonTT),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
