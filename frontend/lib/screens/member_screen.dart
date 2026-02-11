import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mouni/misc/textstyle.dart';
import 'package:mouni/widgets/member_card.dart';
import 'package:mouni/models/group.dart';
import 'package:mouni/models/member.dart';
import 'package:mouni/providers/member_provider.dart';
import 'package:mouni/misc/colors.dart';
import 'package:mouni/widgets/name_input_dialog.dart';

class MemberScreen extends StatefulWidget {
  final Group group;

  const MemberScreen({super.key, required this.group});

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMembers());
  }

  Future<void> _fetchMembers() async {
    setState(() => _loading = true);
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

    setState(() => _loading = false);
  }

  Future<void> _addMember() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) =>
          const NameInputDialog(title: "Add Member", label: "Member name"),
    );

    if (name != null && name.trim().isNotEmpty) {
      if (!mounted) return;
      final result = await Provider.of<MemberProvider>(
        context,
        listen: false,
      ).addMember(widget.group.id!, name.trim());

      if (!mounted) return;
      if (!result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!, style: errorTT),
            backgroundColor: softRed,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Member added")));
      }
    }
  }

  Future<void> _updateMember(Member member) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => NameInputDialog(
        title: "Update Member Name",
        label: "New member name",
        initialValue: member.name,
      ),
    );

    if (newName != null && newName.trim().isNotEmpty) {
      if (!mounted) return;
      final result = await Provider.of<MemberProvider>(
        context,
        listen: false,
      ).updateMember(widget.group.id!, member.id!, newName.trim());

      if (!mounted) return;
      if (!result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!, style: errorTT),
            backgroundColor: softRed,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Member updated")));
      }
    }
  }

  Future<void> _deleteMember(Member member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Member", style: dialogTitleTT),
        content: Text("Are you sure you want to delete '${member.name}'?"),
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
      final result = await Provider.of<MemberProvider>(
        context,
        listen: false,
      ).deleteMember(widget.group.id!, member.id!);

      if (!mounted) return;
      if (!result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!, style: errorTT),
            backgroundColor: softRed,
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Member deleted")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = Provider.of<MemberProvider>(
      context,
    ).getMembers(widget.group.id!);

    return Scaffold(
      appBar: AppBar(title: Text("Members of ${widget.group.name}")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : members.isEmpty
          ? const Center(child: Text("No members found."))
          : RefreshIndicator(
              onRefresh: _fetchMembers,
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return MemberCard(
                    member: member,
                    onEdit: () => _updateMember(member),
                    onDelete: () => _deleteMember(member),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMember,
        tooltip: "Add Member",
        child: const Icon(Icons.add),
      ),
    );
  }
}
