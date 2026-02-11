import 'package:flutter/material.dart';
import 'package:mouni/misc/textstyle.dart';
import 'package:mouni/widgets/group_card.dart';
import 'package:provider/provider.dart';
import 'package:mouni/models/group.dart';
import 'package:mouni/providers/group_provider.dart';
import 'package:mouni/screens/group_screen.dart';
import 'package:mouni/misc/colors.dart';
import 'package:mouni/widgets/name_input_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGroups();
    });
  }

  Future<void> _fetchGroups() async {
    setState(() => _loading = true);

    final result = await Provider.of<GroupProvider>(
      context,
      listen: false,
    ).fetchGroups();
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

  void _navigateToGroupScreen(Group group) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GroupScreen(group: group)),
    );
  }

  Future<void> _createGroup() async {
    final groupName = await showDialog<String>(
      context: context,
      builder: (context) =>
          const NameInputDialog(title: "Create Group", label: "Group name"),
    );

    if (!mounted) return;

    if (groupName != null && groupName.trim().isNotEmpty) {
      final result = await Provider.of<GroupProvider>(
        context,
        listen: false,
      ).addGroup(groupName.trim());
      if (!mounted) return;

      if (!result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!, style: errorTT),
            backgroundColor: softRed,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group created", style: successTT)),
        );
      }
    }
  }

  Future<void> _updateGroup(Group group) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => NameInputDialog(
        title: "Update Group Name",
        label: "New group name",
        initialValue: group.name,
      ),
    );

    if (!mounted) return;

    if (newName != null && newName.trim().isNotEmpty) {
      final result = await Provider.of<GroupProvider>(
        context,
        listen: false,
      ).updateGroup(group.id!, newName.trim());
      if (!mounted) return;

      if (!result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!, style: errorTT),
            backgroundColor: softRed,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group updated", style: successTT)),
        );
      }
    }
  }

  Future<void> _deleteGroup(Group group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Group", style: dialogTitleTT),
        content: Text(
          "Are you sure you want to delete the group '${group.name}'?",
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
      final result = await Provider.of<GroupProvider>(
        context,
        listen: false,
      ).deleteGroup(group.id!);
      if (!mounted) return;

      if (!result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!, style: errorTT),
            backgroundColor: softRed,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group deleted", style: successTT)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = Provider.of<GroupProvider>(context).groups;

    return Scaffold(
      appBar: AppBar(title: const Text("Groups", style: screenTitleTT)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
          ? const Center(child: Text("No groups found."))
          : RefreshIndicator(
              onRefresh: _fetchGroups,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return GroupCard(
                    group: group,
                    onTap: () => _navigateToGroupScreen(group),
                    onEdit: () => _updateGroup(group),
                    onDelete: () => _deleteGroup(group),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createGroup,
        tooltip: "Create Group",
        child: const Icon(Icons.add),
      ),
    );
  }
}
