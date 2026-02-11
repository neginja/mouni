import 'package:flutter/material.dart';
import 'package:mouni/misc/colors.dart';
import 'package:mouni/misc/textstyle.dart';
import 'package:mouni/models/group.dart';
import 'package:mouni/providers/activity_provider.dart';
import 'package:mouni/screens/settlement_screen.dart';
import 'package:provider/provider.dart';
import 'package:mouni/models/activity.dart';
import 'package:mouni/models/expense.dart';
import 'package:mouni/providers/expense_provider.dart';
import 'package:mouni/providers/member_provider.dart';
import 'package:mouni/providers/settlement_provider.dart';
import 'package:mouni/widgets/expense_card.dart';
import 'package:mouni/widgets/activity_stats_card.dart';
import 'package:mouni/screens/manage_expense_screen.dart';

class ActivityScreen extends StatefulWidget {
  final Group group;
  final Activity activity;

  const ActivityScreen({
    super.key,
    required this.group,
    required this.activity,
  });

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchExpenses();
      _fetchMembers();
      _fetchSettlements(simulate: true);
      _fetchSettlements(simulate: false);
    });
  }

  Future<void> _fetchExpenses() async {
    setState(() => _loading = true);

    final result = await Provider.of<ExpenseProvider>(
      context,
      listen: false,
    ).loadExpenses(widget.group.id!, widget.activity.id!);
    if (!mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!, style: errorTT),
          backgroundColor: softRed,
        ),
      );
    }

    setState(() => _loading = false);
  }

  Future<void> _fetchMembers() async {
    final result = await Provider.of<MemberProvider>(
      context,
      listen: false,
    ).loadMembers(widget.activity.groupId);
    if (!mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!, style: errorTT),
          backgroundColor: softRed,
        ),
      );
    }
  }

  Future<void> _fetchSettlements({bool simulate = true}) async {
    final result = await Provider.of<SettlementProvider>(context, listen: false)
        .loadSettlements(
          widget.activity.groupId,
          widget.activity.id!,
          simulate: simulate,
        );
    if (!mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error!, style: errorTT),
          backgroundColor: softRed,
        ),
      );
    }
  }

  void _openManageExpense({Expense? expense}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ManageExpenseScreen(
          group: widget.group,
          activity: widget.activity,
          expense: expense,
        ),
      ),
    );

    if (result == true) {
      _fetchExpenses();
      _fetchSettlements(simulate: true);
    }
  }

  void _deleteExpense(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Expense", style: dialogTitleTT),
        content: Text(
          "Are you sure you want to delete '${expense.description}'?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: saveButtonTT),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: cancelButtonTT),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirm == true) {
      final result = await Provider.of<ExpenseProvider>(
        context,
        listen: false,
      ).deleteExpense(widget.group.id!, widget.activity.id!, expense.id!);
      if (!mounted) return;

      if (!result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!, style: errorTT),
            backgroundColor: softRed,
          ),
        );
      }
      _fetchSettlements(simulate: true); // refresh
    }
  }

  void _navigateToSettlements() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SettlementScreen(group: widget.group, activity: widget.activity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final settlementProvider = Provider.of<SettlementProvider>(context);
    final memberProvider = Provider.of<MemberProvider>(context);
    final activityProvider = Provider.of<ActivityStatusProvider>(context);

    final expenses = expenseProvider.getExpenses(widget.activity.id!)
      ..sort((a, b) => b.date.compareTo(a.date));

    // simulated settlements for top stats card
    final settlements = settlementProvider.getSettlements(
      widget.activity.id!,
      simulated: true,
    );
    final members = memberProvider.getMembers(widget.activity.groupId);
    final activityStatus = activityProvider.getActivityStatus(
      widget.activity.id!,
    );

    final List<Widget> expenseListWidgets = [
      ActivityStatsCard(
        expenses: expenses,
        members: members,
        settlements: settlements,
        activityStatus: activityStatus,
      ),
    ];

    final Map<String, List<Expense>> groupedExpenses = {};
    for (var expense in expenses) {
      final dateStr = expense.date.toLocal().toString().split(' ')[0];
      groupedExpenses.putIfAbsent(dateStr, () => []).add(expense);
    }

    groupedExpenses.forEach((date, expenseList) {
      expenseListWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Text(date, style: sepTitleTT),
        ),
      );

      for (var expense in expenseList) {
        expenseListWidgets.add(
          ExpenseCard(
            expense: expense,
            onEdit: () => _openManageExpense(expense: expense),
            onDelete: () => _deleteExpense(expense),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.group.name, style: detailsDisplayTT),
            Text(widget.activity.name, style: screenTitleTT),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: "Settle Activity",
            onPressed: _navigateToSettlements,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : expenses.isEmpty
          ? const Center(child: Text("No expenses yet"))
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchExpenses();
                await _fetchSettlements();
              },
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: expenseListWidgets,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (members.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Add members before you can add expenses."),
              ),
            );
            return;
          }
          _openManageExpense();
        },
        tooltip: "Add Expense",
        child: const Icon(Icons.add),
      ),
    );
  }
}
