import 'package:flutter/material.dart';
import 'package:mouni/models/expense.dart';
import 'package:mouni/api/services/expense_service.dart';
import 'package:mouni/api/api_result.dart';

class ExpenseProvider extends ChangeNotifier {
  final Map<String, List<Expense>> _activityExpenses = {};

  /// Get expenses for a specific activity
  List<Expense> getExpenses(String activityId) {
    return _activityExpenses[activityId] ?? [];
  }

  /// Load expenses from API
  Future<ApiResult<List<Expense>>> loadExpenses(
    String groupId,
    String activityId,
  ) async {
    final result = await ExpenseService.listExpenses(groupId, activityId);

    if (result.isSuccess) {
      _activityExpenses[activityId] = result.data!;
    }
    notifyListeners();
    return result;
  }

  /// Add a new expense
  Future<ApiResult<Expense>> addExpense(
    String groupId,
    String activityId,
    Map<String, dynamic> expenseData,
  ) async {
    final result = await ExpenseService.createExpense(
      groupId,
      activityId,
      expenseData,
    );

    if (result.isSuccess) {
      _activityExpenses.putIfAbsent(activityId, () => []);
      _activityExpenses[activityId]!.insert(0, result.data!); // newest on top
    }
    notifyListeners();
    return result;
  }

  /// Update an expense
  Future<ApiResult<Expense>> updateExpense(
    String groupId,
    String activityId,
    String expenseId,
    Map<String, dynamic> expenseData,
  ) async {
    final result = await ExpenseService.updateExpense(
      groupId,
      activityId,
      expenseId,
      expenseData,
    );

    if (result.isSuccess) {
      final index = _activityExpenses[activityId]?.indexWhere(
        (e) => e.id == expenseId,
      );
      if (index != null && index >= 0) {
        _activityExpenses[activityId]![index] = result.data!;
      }
    }
    notifyListeners();
    return result;
  }

  /// Delete an expense
  Future<ApiResult<void>> deleteExpense(
    String groupId,
    String activityId,
    String expenseId,
  ) async {
    final result = await ExpenseService.deleteExpense(
      groupId,
      activityId,
      expenseId,
    );

    if (result.isSuccess) {
      _activityExpenses[activityId]?.removeWhere((e) => e.id == expenseId);
    }

    notifyListeners();
    return result;
  }

  /// Clear cached expenses for an activity
  void clearActivityExpenses(String activityId) {
    _activityExpenses.remove(activityId);
    notifyListeners();
  }

  /// Clear all cached expenses
  void clearAll() {
    _activityExpenses.clear();
    notifyListeners();
  }
}
