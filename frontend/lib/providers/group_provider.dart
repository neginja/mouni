import 'package:flutter/material.dart';
import 'package:mouni/models/group.dart';
import 'package:mouni/api/services/group_service.dart';
import 'package:mouni/api/api_result.dart';

class GroupProvider with ChangeNotifier {
  final List<Group> _groups = [];
  List<Group> get groups => List.unmodifiable(_groups);

  /// Fetch all groups
  Future<ApiResult<List<Group>>> fetchGroups() async {
    notifyListeners();

    final result = await GroupService.listGroups();
    if (result.isSuccess) {
      _groups
        ..clear()
        ..addAll(result.data!);
    } else {}

    notifyListeners();
    return result;
  }

  /// Create a new group
  Future<ApiResult<Group>> addGroup(String name) async {
    final result = await GroupService.createGroup(name);
    if (result.isSuccess) {
      _groups.insert(0, result.data!); // show new group on top
    }
    notifyListeners();
    return result;
  }

  /// Update a group
  Future<ApiResult<Group>> updateGroup(String groupId, String newName) async {
    final result = await GroupService.updateGroup(groupId, newName);
    if (result.isSuccess) {
      final index = _groups.indexWhere((g) => g.id == groupId);
      if (index != -1) {
        _groups[index] = result.data!;
      }
    }
    notifyListeners();
    return result;
  }

  /// Delete a group
  Future<ApiResult<void>> deleteGroup(String groupId) async {
    final result = await GroupService.deleteGroup(groupId);
    if (result.isSuccess) {
      _groups.removeWhere((g) => g.id == groupId);
    }
    notifyListeners();
    return result;
  }
}
