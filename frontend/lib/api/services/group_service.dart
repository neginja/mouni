import '../api_client.dart';
import '../api_result.dart';
import 'package:mouni/models/group.dart';

class GroupService {
  /// Create a new group
  static Future<ApiResult<Group>> createGroup(String name) async {
    return handleApi<Group>(
      action: () => ApiClient.postRequest("/groups", {"name": name}),
      actionName: "Create",
      resourceName: "Group",
      fromJson: (json) => Group.fromJson(json),
    );
  }

  /// List all groups
  static Future<ApiResult<List<Group>>> listGroups() async {
    return handleApi<List<Group>>(
      action: () => ApiClient.getRequest("/groups"),
      actionName: "Fetch",
      resourceName: "Groups",
      fromJson: (json) => (json as List).map((e) => Group.fromJson(e)).toList(),
    );
  }

  /// Get details of a specific group
  static Future<ApiResult<Group>> getGroup(String groupId) async {
    return handleApi<Group>(
      action: () => ApiClient.getRequest("/groups/$groupId"),
      actionName: "Fetch",
      resourceName: "Group",
      fromJson: (json) => Group.fromJson(json),
    );
  }

  /// Update an existing group
  static Future<ApiResult<Group>> updateGroup(
    String groupId,
    String name,
  ) async {
    return handleApi<Group>(
      action: () => ApiClient.putRequest("/groups/$groupId", {"name": name}),
      actionName: "Update",
      resourceName: "Group",
      fromJson: (json) => Group.fromJson(json),
    );
  }

  /// Delete a group
  static Future<ApiResult<void>> deleteGroup(String groupId) async {
    return handleApi<void>(
      action: () => ApiClient.deleteRequest("/groups/$groupId"),
      actionName: "Delete",
      resourceName: "Group",
      fromJson: (_) {},
    );
  }
}
