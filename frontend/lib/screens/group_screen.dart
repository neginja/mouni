import 'package:flutter/material.dart';
import 'package:mouni/misc/colors.dart';
import 'package:mouni/misc/textstyle.dart';
import 'package:provider/provider.dart';
import 'package:mouni/models/dates.dart';
import 'package:mouni/models/group.dart';
import 'package:mouni/models/activity.dart';
import 'package:mouni/providers/activity_provider.dart';
import 'package:mouni/providers/member_provider.dart';
import 'package:mouni/widgets/activity_card.dart';
import 'package:mouni/screens/member_screen.dart';
import 'package:mouni/screens/activity_screen.dart';
import 'package:mouni/widgets/activity_dialog.dart';

class GroupScreen extends StatefulWidget {
  final Group group;

  const GroupScreen({super.key, required this.group});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    // Defer provider call after first frame to avoid build-phase errors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchActivities();
      _fetchMembers();
    });
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _loading = true;
    });

    final result = await Provider.of<ActivityProvider>(
      context,
      listen: false,
    ).loadActivities(widget.group.id!);
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
    ).loadMembers(widget.group.id!);
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

  void _addActivity() async {
    final newActivity = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const ActivityDialog(),
    );

    if (newActivity != null) {
      if (!mounted) return;
      final activityProvider = Provider.of<ActivityProvider>(
        context,
        listen: false,
      );

      final result = await activityProvider.addActivity(widget.group.id!, {
        "name": newActivity['name'],
        "startDate": localToISO8601DateOnlyString(newActivity['startDate']),
        "endDate": localToISO8601DateOnlyString(newActivity['endDate']),
      });
      if (!mounted) return;

      if (!result.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error!, style: errorTT)));
      } else {
        _fetchActivities(); // Refresh list
      }
    }
  }

  void _updateActivity(Activity activity) async {
    // Show edit dialog
    final updated = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ActivityDialog(
        initialName: activity.name,
        initialStartDate: activity.startDate,
        initialEndDate: activity.endDate,
      ),
    );

    if (updated != null && mounted) {
      final activityProvider = Provider.of<ActivityProvider>(
        context,
        listen: false,
      );
      final result = await activityProvider
          .updateActivity(widget.group.id!, activity.id!, {
            "name": updated['name'],
            "startDate": localToISO8601DateOnlyString(updated['startDate']),
            "endDate": localToISO8601DateOnlyString(updated['endDate']),
          });

      if (!mounted) return;

      if (!result.isSuccess) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error!, style: errorTT)));
      } else {
        _fetchActivities(); // refresh list
      }
    }
  }

  void _deleteActivity(Activity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Activity"),
        content: Text("Are you sure you want to delete '${activity.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      final result = await Provider.of<ActivityProvider>(
        context,
        listen: false,
      ).deleteActivity(widget.group.id!, activity.id!);

      if (!result.isSuccess) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.error!, style: errorTT)));
      } else {
        _fetchActivities();
      }
    }
  }

  void _navigateToActivityScreen(Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ActivityScreen(group: widget.group, activity: activity),
      ),
    ).then((_) => _fetchActivities()); // refresh list after returning
  }

  void _navigateToManageMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberScreen(group: widget.group),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = Provider.of<ActivityProvider>(
      context,
    ).getActivities(widget.group.id!);

    final members = Provider.of<MemberProvider>(
      context,
    ).getMembers(widget.group.id!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name, style: screenTitleTT),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: "Manage Members",
            onPressed: _navigateToManageMembers,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchActivities();
                await _fetchMembers();
              },
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  // Member pills
                  if (members.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: members
                          .map(
                            (m) => Chip(
                              avatar: const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey,
                              ),
                              label: Text(m.name, style: valueDisplayTT),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 12),
                  // Activities
                  if (activities.isEmpty)
                    const Center(child: Text("No activities found."))
                  else
                    ...activities.map(
                      (a) => ActivityCard(
                        activity: a,
                        onTap: () => _navigateToActivityScreen(a),
                        onEdit: () => _updateActivity(a),
                        onDelete: () => _deleteActivity(a),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addActivity,
        tooltip: "Add Activity",
        child: const Icon(Icons.add),
      ),
    );
  }
}
