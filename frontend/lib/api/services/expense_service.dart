import '../api_client.dart';
import '../api_result.dart';
import 'package:mouni/models/expense.dart';

class ExpenseService {
  /// Create a new expense in an activity
  static Future<ApiResult<Expense>> createExpense(
    String groupId,
    String activityId,
    Map<String, dynamic> expenseData,
  ) async {
    return handleApi<Expense>(
      action: () => ApiClient.postRequest(
        "/groups/$groupId/activities/$activityId/expenses",
        expenseData,
      ),
      actionName: "Create",
      resourceName: "Expense",
      fromJson: (json) => Expense.fromJson(json),
    );
  }

  /// List all expenses in an activity
  static Future<ApiResult<List<Expense>>> listExpenses(
    String groupId,
    String activityId,
  ) async {
    return handleApi<List<Expense>>(
      action: () => ApiClient.getRequest(
        "/groups/$groupId/activities/$activityId/expenses",
      ),
      actionName: "Fetch",
      resourceName: "Expenses",
      fromJson: (json) =>
          (json as List).map((e) => Expense.fromJson(e)).toList(),
    );
  }

  /// Get details of a specific expense
  static Future<ApiResult<Expense>> getExpense(
    String groupId,
    String activityId,
    String expenseId,
  ) async {
    return handleApi<Expense>(
      action: () => ApiClient.getRequest(
        "/groups/$groupId/activities/$activityId/expenses/$expenseId",
      ),
      actionName: "Fetch",
      resourceName: "Expense",
      fromJson: (json) => Expense.fromJson(json),
    );
  }

  /// Update an expense
  static Future<ApiResult<Expense>> updateExpense(
    String groupId,
    String activityId,
    String expenseId,
    Map<String, dynamic> expenseData,
  ) async {
    return handleApi<Expense>(
      action: () => ApiClient.putRequest(
        "/groups/$groupId/activities/$activityId/expenses/$expenseId",
        expenseData,
      ),
      actionName: "Update",
      resourceName: "Expense",
      fromJson: (json) => Expense.fromJson(json),
    );
  }

  /// Delete an expense
  static Future<ApiResult<void>> deleteExpense(
    String groupId,
    String activityId,
    String expenseId,
  ) async {
    return handleApi<void>(
      action: () => ApiClient.deleteRequest(
        "/groups/$groupId/activities/$activityId/expenses/$expenseId",
      ),
      actionName: "Delete",
      resourceName: "Expense",
      fromJson: (_) {},
    );
  }
}
