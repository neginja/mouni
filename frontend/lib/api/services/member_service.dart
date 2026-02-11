import '../api_client.dart';
import '../api_result.dart';
import 'package:mouni/models/member.dart';

class MemberService {
  /// Add a member to a group
  static Future<ApiResult<Member>> addMember(
    String groupId,
    String name,
  ) async {
    return handleApi<Member>(
      action: () =>
          ApiClient.postRequest("/groups/$groupId/members", {"name": name}),
      actionName: "Add",
      resourceName: "Member",
      fromJson: (json) => Member.fromJson(json),
    );
  }

  /// List members of a group
  static Future<ApiResult<List<Member>>> listMembers(String groupId) async {
    return handleApi<List<Member>>(
      action: () => ApiClient.getRequest("/groups/$groupId/members"),
      actionName: "Fetch",
      resourceName: "Members",
      fromJson: (json) =>
          (json as List).map((e) => Member.fromJson(e)).toList(),
    );
  }

  /// Get a specific member’s details in a group
  static Future<ApiResult<Member>> getMember(
    String groupId,
    String memberId,
  ) async {
    return handleApi<Member>(
      action: () => ApiClient.getRequest("/groups/$groupId/members/$memberId"),
      actionName: "Fetch",
      resourceName: "Member",
      fromJson: (json) => Member.fromJson(json),
    );
  }

  /// Update a member in a group
  static Future<ApiResult<Member>> updateMember(
    String groupId,
    String memberId,
    String name,
  ) async {
    return handleApi<Member>(
      action: () => ApiClient.putRequest("/groups/$groupId/members/$memberId", {
        "name": name,
      }),
      actionName: "Update",
      resourceName: "Member",
      fromJson: (json) => Member.fromJson(json),
    );
  }

  /// Remove a member from a group
  static Future<ApiResult<void>> deleteMember(
    String groupId,
    String memberId,
  ) async {
    return handleApi<void>(
      action: () =>
          ApiClient.deleteRequest("/groups/$groupId/members/$memberId"),
      actionName: "Delete",
      resourceName: "Member",
      fromJson: (_) {},
    );
  }
}
