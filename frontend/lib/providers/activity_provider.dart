import 'package:flutter/material.dart';
import 'package:mouni/models/activity.dart';
import 'package:mouni/api/services/activity_service.dart';
import 'package:mouni/api/api_result.dart';

class ActivityProvider extends ChangeNotifier {
  final Map<String, List<Activity>> _groupActivities = {};

  /// Get activities for a specific group
  List<Activity> getActivities(String groupId) {
    return _groupActivities[groupId] ?? [];
  }

  /// Load activities from API
  Future<ApiResult<List<Activity>>> loadActivities(String groupId) async {
    notifyListeners();

    final result = await ActivityService.listActivities(groupId);
    if (result.isSuccess) {
      _groupActivities[groupId] = result.data!;
    }

    notifyListeners();
    return result;
  }

  /// Add a new activity
  Future<ApiResult<Activity>> addActivity(
    String groupId,
    Map<String, dynamic> data,
  ) async {
    final result = await ActivityService.createActivity(groupId, data);
    if (result.isSuccess) {
      _groupActivities.putIfAbsent(groupId, () => []);
      _groupActivities[groupId]!.insert(0, result.data!); // newest on top
    }
    notifyListeners();
    return result;
  }

  /// Update an activity
  Future<ApiResult<Activity>> updateActivity(
    String groupId,
    String activityId,
    Map<String, dynamic> data,
  ) async {
    final result = await ActivityService.updateActivity(
      groupId,
      activityId,
      data,
    );

    if (result.isSuccess) {
      final index = _groupActivities[groupId]?.indexWhere(
        (a) => a.id == activityId,
      );
      if (index != null && index >= 0) {
        _groupActivities[groupId]![index] = result.data!;
      }
    }

    notifyListeners();
    return result;
  }

  /// Delete an activity
  Future<ApiResult<void>> deleteActivity(
    String groupId,
    String activityId,
  ) async {
    final result = await ActivityService.deleteActivity(groupId, activityId);
    if (result.isSuccess) {
      _groupActivities[groupId]?.removeWhere((a) => a.id == activityId);
    }
    notifyListeners();
    return result;
  }
}

class ActivityStatusProvider extends ChangeNotifier {
  final Map<String, ActivityStatus> _activityStatuses = {};

  /// Get cached activity status (if available)
  ActivityStatus? getActivityStatus(String activityId) {
    return _activityStatuses[activityId] ?? ActivityStatus("unknown");
  }

  /// Fetch status of a specific activity from API
  Future<ApiResult<ActivityStatus>> fetchActivityStatus(
    String groupId,
    String activityId,
  ) async {
    final result = await ActivityService.getActivityStatus(groupId, activityId);

    if (result.isSuccess && result.data != null) {
      _activityStatuses[activityId] = result.data!;
      notifyListeners();
    }

    return result;
  }
}
