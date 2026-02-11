import 'package:flutter/material.dart';
import 'package:mouni/misc/textstyle.dart';

class ActivityDialog extends StatefulWidget {
  final String? initialName;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const ActivityDialog({
    super.key,
    this.initialName,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<ActivityDialog> createState() => _ActivityDialogState();
}

class _ActivityDialogState extends State<ActivityDialog> {
  late final TextEditingController _nameController;
  late FocusNode _nameFocusNode;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? "");
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;

    _nameFocusNode = FocusNode();
    _nameFocusNode.addListener(() {
      if (_nameFocusNode.hasFocus) {
        _nameController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _nameController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    Navigator.pop(context, {
      "name": _nameController.text.trim(),
      "startDate": _startDate,
      "endDate": _endDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.initialName != null;
    return AlertDialog(
      title: Text(
        isUpdate ? "Update Activity" : "Add Activity",
        style: dialogTitleTT,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            decoration: const InputDecoration(
              labelText: "Activity name",
              labelStyle: labelTT,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _startDate != null && _endDate != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text("From: "),
                              Expanded(
                                child: Text(
                                  _startDate!.toLocal().toString().split(
                                    ' ',
                                  )[0],
                                  style: valueDisplayTT,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text("To:   "),
                              Expanded(
                                child: Text(
                                  _endDate!.toLocal().toString().split(' ')[0],
                                  style: valueDisplayTT,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Text("Period not selected", style: valueDisplayTT),
              ),
              ElevatedButton(
                onPressed: _pickDateRange,
                child: const Text("Pick", style: saveButtonTT),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: cancelButtonTT),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isUpdate ? "Update" : "Add", style: saveButtonTT),
        ),
      ],
    );
  }
}
