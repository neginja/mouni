import 'package:flutter/material.dart';
import 'package:mouni/misc/colors.dart';
import 'package:mouni/models/dates.dart';
import 'package:provider/provider.dart';
import 'package:mouni/misc/textstyle.dart';
import 'package:mouni/models/activity.dart';
import 'package:mouni/providers/activity_provider.dart';

class ActivityCard extends StatefulWidget {
  final Activity activity;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  ActivityStatus? _status;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final provider = Provider.of<ActivityStatusProvider>(
      context,
      listen: false,
    );
    setState(() => _loading = true);

    final result = await provider.fetchActivityStatus(
      widget.activity.groupId,
      widget.activity.id!,
    );

    if (mounted) {
      setState(() {
        _status = result.data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = formatDateOnly(widget.activity.startDate);
    final end = formatDateOnly(widget.activity.endDate);
    final subtitle =
        (widget.activity.startDate != null || widget.activity.endDate != null)
        ? "$start - $end"
        : "No dates set";

    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(widget.activity.name, style: cardTitleTT),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: valueDisplayTT),
            const SizedBox(height: 4),
            _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: statusColor(_status?.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _status?.prettyStatus() ?? "Unknown",
                        style: valueDisplayTT.copyWith(
                          color: statusColor(_status?.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
        onTap: widget.onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: "Edit",
                onPressed: widget.onEdit,
              ),
            if (widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: "Delete",
                onPressed: widget.onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
