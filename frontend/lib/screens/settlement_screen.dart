import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mouni/models/group.dart';
import 'package:mouni/models/activity.dart';
import 'package:mouni/models/settlement.dart';
import 'package:mouni/providers/settlement_provider.dart';
import 'package:mouni/widgets/settlement_card.dart';
import 'package:mouni/misc/colors.dart';
import 'package:mouni/misc/textstyle.dart';

class SettlementScreen extends StatefulWidget {
  final Group group;
  final Activity activity;

  const SettlementScreen({
    super.key,
    required this.group,
    required this.activity,
  });

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  bool _loading = true;
  bool _firstFetchDone = false;
  List<Settlement> _settlements = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchSettlements());
  }

  Future<void> _fetchSettlements() async {
    setState(() => _loading = true);

    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    final result = await settlementProvider.loadSettlements(
      widget.group.id!,
      widget.activity.id!,
    );

    if (!mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? "Failed to load settlements",
            style: errorTT,
          ),
          backgroundColor: softRed,
        ),
      );
    }

    final fetchedSettlements = settlementProvider.getSettlements(
      widget.activity.id!,
    );

    // automatically settle activity if activity has no settlement yet
    if (!_firstFetchDone && fetchedSettlements.isEmpty) {
      _firstFetchDone = true;
      await _settleActivity();
      return;
    }

    setState(() {
      _settlements = fetchedSettlements;
      _loading = false;
    });
  }

  Future<void> _settleActivity() async {
    final settlementProvider = Provider.of<SettlementProvider>(
      context,
      listen: false,
    );

    final result = await settlementProvider.settleActivity(
      widget.group.id!,
      widget.activity.id!,
    );

    if (!mounted) return;

    if (!result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to settle activity: ${result.error}",
            style: errorTT,
          ),
          backgroundColor: softRed,
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Activity settled!")));
    }

    await _fetchSettlements();
  }

  bool get _anyPaid =>
      _settlements.any((settlement) => settlement.paid == true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.activity.name, style: detailsDisplayTT),
            Text("Settlements", style: screenTitleTT),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Settlements",
            onPressed: _anyPaid ? null : _settleActivity,
            color: _anyPaid ? Colors.grey : null,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _settlements.isEmpty
          ? const Center(child: Text("No settlements found."))
          : RefreshIndicator(
              onRefresh: _fetchSettlements,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: _settlements.length,
                itemBuilder: (context, index) {
                  final s = _settlements[index];
                  return SettlementCard(
                    groupId: widget.group.id!,
                    activityId: widget.activity.id!,
                    settlement: s,
                  );
                },
              ),
            ),
    );
  }
}
