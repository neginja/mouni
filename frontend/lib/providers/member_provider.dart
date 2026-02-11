import 'package:flutter/material.dart';
import 'package:mouni/models/member.dart';
import 'package:mouni/api/services/member_service.dart';
import 'package:mouni/api/api_result.dart';

class MemberProvider extends ChangeNotifier {
  final Map<String, List<Member>> _groupMembers = {};

  /// Get members for a specific group
  List<Member> getMembers(String groupId) {
    return _groupMembers[groupId] ?? [];
  }

  /// Load members from API
  Future<ApiResult<List<Member>>> loadMembers(String groupId) async {
    notifyListeners();

    final result = await MemberService.listMembers(groupId);
    if (result.isSuccess) {
      _groupMembers[groupId] = result.data!;
    } else {}

    notifyListeners();
    return result;
  }

  /// Get a member by ID within all groups (searches locally only)
  Member? getMemberById(String memberId) {
    for (var members in _groupMembers.values) {
      final match = members.where((m) => m.id == memberId);
      if (match.isNotEmpty) return match.first;
    }
    return null;
  }

  /// Add a new member
  Future<ApiResult<Member>> addMember(String groupId, String name) async {
    final result = await MemberService.addMember(groupId, name);
    if (result.isSuccess) {
      _groupMembers.putIfAbsent(groupId, () => []);
      _groupMembers[groupId]!.add(result.data!);
    } else {}
    notifyListeners();
    return result;
  }

  /// Update a member
  Future<ApiResult<Member>> updateMember(
    String groupId,
    String memberId,
    String name,
  ) async {
    final result = await MemberService.updateMember(groupId, memberId, name);
    if (result.isSuccess) {
      final index = _groupMembers[groupId]?.indexWhere((m) => m.id == memberId);
      if (index != null && index >= 0) {
        _groupMembers[groupId]![index] = result.data!;
      }
    } else {}
    notifyListeners();
    return result;
  }

  /// Delete a member
  Future<ApiResult<void>> deleteMember(String groupId, String memberId) async {
    final result = await MemberService.deleteMember(groupId, memberId);
    if (result.isSuccess) {
      _groupMembers[groupId]?.removeWhere((m) => m.id == memberId);
    } else {}
    notifyListeners();
    return result;
  }
}
