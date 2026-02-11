import 'package:flutter/material.dart';
import 'package:mouni/models/settlement.dart';
import 'package:mouni/api/services/settlement_service.dart';
import 'package:mouni/api/api_result.dart';

class SettlementProvider extends ChangeNotifier {
  final Map<String, List<Settlement>> _settlementsByActivity = {};
  final Map<String, List<Settlement>> _simulatedSettlementsByActivity = {};

  /// Get settlements, optionally simulated
  List<Settlement> getSettlements(
    String? activityId, {
    bool simulated = false,
  }) {
    if (activityId == null) return [];
    if (simulated) {
      return _simulatedSettlementsByActivity[activityId] ?? [];
    }
    return _settlementsByActivity[activityId] ?? [];
  }

  /// Fetch all settlements for an activity
  Future<ApiResult<List<Settlement>>> loadSettlements(
    String groupId,
    String activityId, {
    bool simulate = false,
  }) async {
    notifyListeners();

    final result = await SettlementService.listSettlements(
      groupId,
      activityId,
      simulate: simulate,
    );

    if (result.isSuccess && result.data != null) {
      if (simulate) {
        _simulatedSettlementsByActivity[activityId] = result.data!;
      } else {
        _settlementsByActivity[activityId] = result.data!;
      }
    }

    notifyListeners();
    return result;
  }

  /// Trigger settlement calculation for an activity
  Future<ApiResult<List<Settlement>>> settleActivity(
    String groupId,
    String activityId,
  ) async {
    notifyListeners();

    final result = await SettlementService.settleActivity(groupId, activityId);

    if (result.isSuccess && result.data != null) {
      _settlementsByActivity[activityId] = result.data!;
      // Clear simulated settlements since they are now outdated
      _simulatedSettlementsByActivity.remove(activityId);
    }

    notifyListeners();
    return result;
  }

  /// Update settlement status (paid/unpaid)
  Future<ApiResult<Settlement>> updateSettlementStatus(
    String groupId,
    String activityId,
    String settlementId,
    bool paid,
  ) async {
    final result = await SettlementService.updateSettlementStatus(
      groupId,
      activityId,
      settlementId,
      paid,
    );

    if (result.isSuccess && result.data != null) {
      final list = _settlementsByActivity[activityId];
      if (list != null) {
        final idx = list.indexWhere((s) => s.id == settlementId);
        if (idx != -1) {
          list[idx] = result.data!;
          notifyListeners();
        }
      }
    }

    return result;
  }

  /// Delete a settlement
  Future<ApiResult<void>> deleteSettlement(
    String groupId,
    String activityId,
    String settlementId,
  ) async {
    final result = await SettlementService.deleteSettlement(
      groupId,
      activityId,
      settlementId,
    );

    if (result.isSuccess) {
      _settlementsByActivity[activityId]?.removeWhere(
        (s) => s.id == settlementId,
      );
      notifyListeners();
    }

    return result;
  }

  /// Clear all settlements for an activity
  Future<ApiResult<void>> clearSettlements(
    String groupId,
    String activityId, {
    bool simulated = false,
  }) async {
    final result = await SettlementService.clearSettlements(
      groupId,
      activityId,
    );

    if (result.isSuccess) {
      if (simulated) {
        _simulatedSettlementsByActivity[activityId]?.clear();
      } else {
        _settlementsByActivity[activityId]?.clear();
      }
      notifyListeners();
    }

    return result;
  }
}
