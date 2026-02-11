import 'package:mouni/api/api_client.dart';
import 'package:mouni/api/api_result.dart';
import 'package:mouni/models/activity.dart';

class ActivityService {
  /// Create a new activity in a group
  static Future<ApiResult<Activity>> createActivity(
    String groupId,
    Map<String, dynamic> activityData,
  ) async {
    return handleApi<Activity>(
      action: () =>
          ApiClient.postRequest("/groups/$groupId/activities", activityData),
      actionName: "Create",
      resourceName: "Activity",
      fromJson: (json) => Activity.fromJson(json),
    );
  }

  /// List all activities in a group
  static Future<ApiResult<List<Activity>>> listActivities(
    String groupId,
  ) async {
    return handleApi<List<Activity>>(
      action: () => ApiClient.getRequest("/groups/$groupId/activities"),
      actionName: "Fetch",
      resourceName: "Activities",
      fromJson: (json) =>
          (json as List).map((e) => Activity.fromJson(e)).toList(),
    );
  }

  /// Get details of a specific activity
  static Future<ApiResult<Activity>> getActivity(
    String groupId,
    String activityId,
  ) async {
    return handleApi<Activity>(
      action: () =>
          ApiClient.getRequest("/groups/$groupId/activities/$activityId"),
      actionName: "Fetch",
      resourceName: "Activity",
      fromJson: (json) => Activity.fromJson(json),
    );
  }

  /// Get details of a specific activity
  static Future<ApiResult<ActivityStatus>> getActivityStatus(
    String groupId,
    String activityId,
  ) async {
    return handleApi<ActivityStatus>(
      action: () => ApiClient.getRequest(
        "/groups/$groupId/activities/$activityId/status",
      ),
      actionName: "Fetch",
      resourceName: "ActivityStatus",
      fromJson: (json) => ActivityStatus.fromJson(json),
    );
  }

  /// Update an activity
  static Future<ApiResult<Activity>> updateActivity(
    String groupId,
    String activityId,
    Map<String, dynamic> activityData,
  ) async {
    return handleApi<Activity>(
      action: () => ApiClient.putRequest(
        "/groups/$groupId/activities/$activityId",
        activityData,
      ),
      actionName: "Update",
      resourceName: "Activity",
      fromJson: (json) => Activity.fromJson(json),
    );
  }

  /// Delete an activity
  static Future<ApiResult<void>> deleteActivity(
    String groupId,
    String activityId,
  ) async {
    return handleApi<void>(
      action: () =>
          ApiClient.deleteRequest("/groups/$groupId/activities/$activityId"),
      actionName: "Delete",
      resourceName: "Activity",
      fromJson: (_) {},
    );
  }
}
