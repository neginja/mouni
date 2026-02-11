import '../api_client.dart';
import '../api_result.dart';
import 'package:mouni/models/settlement.dart';

class SettlementService {
  /// POST /groups/{groupId}/activities/{activityId}/settle
  static Future<ApiResult<List<Settlement>>> settleActivity(
    String groupId,
    String activityId,
  ) async {
    return handleApi<List<Settlement>>(
      action: () => ApiClient.postRequest(
        '/groups/$groupId/activities/$activityId/settle',
        {}, // request body optional
      ),
      actionName: "Settle",
      resourceName: "Activity",
      fromJson: (json) =>
          (json as List).map((e) => Settlement.fromJson(e)).toList(),
    );
  }

  /// GET /groups/{groupId}/activities/{activityId}/settlements
  static Future<ApiResult<List<Settlement>>> listSettlements(
    String groupId,
    String activityId, {
    bool? simulate,
  }) async {
    final query = simulate != null
        ? '?simulate=${simulate ? "true" : "false"}'
        : '';

    return handleApi<List<Settlement>>(
      action: () => ApiClient.getRequest(
        '/groups/$groupId/activities/$activityId/settlements$query',
      ),
      actionName: "Fetch",
      resourceName: "Settlements",
      fromJson: (json) =>
          (json as List).map((e) => Settlement.fromJson(e)).toList(),
    );
  }

  /// POST /groups/{groupId}/activities/{activityId}/settlements
  static Future<ApiResult<Settlement>> createSettlement(
    String groupId,
    String activityId,
    Map<String, dynamic> payload,
  ) async {
    return handleApi<Settlement>(
      action: () => ApiClient.postRequest(
        '/groups/$groupId/activities/$activityId/settlements',
        payload,
      ),
      actionName: "Create",
      resourceName: "Settlement",
      fromJson: (json) => Settlement.fromJson(json),
    );
  }

  /// GET /groups/{groupId}/activities/{activityId}/settlements/{settlementId}
  static Future<ApiResult<Settlement>> getSettlement(
    String groupId,
    String activityId,
    String settlementId,
  ) async {
    return handleApi<Settlement>(
      action: () => ApiClient.getRequest(
        '/groups/$groupId/activities/$activityId/settlements/$settlementId',
      ),
      actionName: "Fetch",
      resourceName: "Settlement",
      fromJson: (json) => Settlement.fromJson(json),
    );
  }

  /// PATCH /groups/{groupId}/activities/{activityId}/settlements/{settlementId}
  static Future<ApiResult<Settlement>> updateSettlementStatus(
    String groupId,
    String activityId,
    String settlementId,
    bool paid,
  ) async {
    return handleApi<Settlement>(
      action: () => ApiClient.patchRequest(
        '/groups/$groupId/activities/$activityId/settlements/$settlementId',
        {'paid': paid},
      ),
      actionName: "Update",
      resourceName: "Settlement",
      fromJson: (json) => Settlement.fromJson(json),
    );
  }

  /// DELETE /groups/{groupId}/activities/{activityId}/settlements/{settlementId}
  static Future<ApiResult<void>> deleteSettlement(
    String groupId,
    String activityId,
    String settlementId,
  ) async {
    return handleApi<void>(
      action: () => ApiClient.deleteRequest(
        '/groups/$groupId/activities/$activityId/settlements/$settlementId',
      ),
      actionName: "Delete",
      resourceName: "Settlement",
      fromJson: (_) {},
    );
  }

  /// DELETE /groups/{groupId}/activities/{activityId}/settlements
  static Future<ApiResult<void>> clearSettlements(
    String groupId,
    String activityId,
  ) async {
    return handleApi<void>(
      action: () => ApiClient.deleteRequest(
        '/groups/$groupId/activities/$activityId/settlements',
      ),
      actionName: "Clear",
      resourceName: "Settlements",
      fromJson: (_) {},
    );
  }
}
