import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/accounts_repository.dart';
import '../../domain/models/wage_record.dart';
import '../../domain/models/material_item.dart';
import '../../domain/models/expense_item.dart';
import '../../domain/models/bill_statement.dart';

class ProjectAccountsState {
  final bool isLoading;
  final String? errorMessage;
  final ProjectAccountsSummary? summary;
  final List<WageRecord> wages;
  final List<MaterialItem> materials;
  final List<ExpenseItem> expenses;
  final List<ClientPayment> clientPayments;
  final List<BillStatement> statements;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String activePreset; // all, weekly, monthly

  const ProjectAccountsState({
    this.isLoading = false,
    this.errorMessage,
    this.summary,
    this.wages = const [],
    this.materials = const [],
    this.expenses = const [],
    this.clientPayments = const [],
    this.statements = const [],
    this.dateFrom,
    this.dateTo,
    this.activePreset = 'all',
  });

  ProjectAccountsState copyWith({
    bool? isLoading,
    String? errorMessage,
    ProjectAccountsSummary? summary,
    List<WageRecord>? wages,
    List<MaterialItem>? materials,
    List<ExpenseItem>? expenses,
    List<ClientPayment>? clientPayments,
    List<BillStatement>? statements,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? activePreset,
  }) {
    return ProjectAccountsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      summary: summary ?? this.summary,
      wages: wages ?? this.wages,
      materials: materials ?? this.materials,
      expenses: expenses ?? this.expenses,
      clientPayments: clientPayments ?? this.clientPayments,
      statements: statements ?? this.statements,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      activePreset: activePreset ?? this.activePreset,
    );
  }
}

final projectAccountsControllerProvider = StateNotifierProvider.family<
    ProjectAccountsController, ProjectAccountsState, String>((ref, projectId) {
  final repo = ref.watch(accountsRepositoryProvider);
  return ProjectAccountsController(repo, projectId);
});

class ProjectAccountsController extends StateNotifier<ProjectAccountsState> {
  final AccountsRepository _repo;
  final String _projectId;

  ProjectAccountsController(this._repo, this._projectId)
      : super(const ProjectAccountsState()) {
    loadAll();
  }

  Future<void> loadAll({
    String projectName = '',
    double budgetOrContractValue = 0.0,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final summary = await _repo.getProjectAccountsSummary(
        _projectId,
        projectName,
        budgetOrContractValue,
      );
      final wages = await _repo.getProjectWages(
        _projectId,
        from: state.dateFrom,
        to: state.dateTo,
      );
      final materials = await _repo.getProjectMaterials(_projectId);
      final expenses = await _repo.getProjectExpenses(_projectId);
      final clientPayments = await _repo.getClientPayments(_projectId);
      final statements = await _repo.getBillStatements(_projectId);

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        wages: wages,
        materials: materials,
        expenses: expenses,
        clientPayments: clientPayments,
        statements: statements,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setPreset(String preset, String projectName, double budget) {
    final now = DateTime.now();
    DateTime? from;
    DateTime? to = now;

    if (preset == 'weekly') {
      from = now.subtract(const Duration(days: 7));
    } else if (preset == 'monthly') {
      from = DateTime(now.year, now.month, 1);
    } else {
      from = null;
      to = null;
    }

    state = state.copyWith(
      activePreset: preset,
      dateFrom: from,
      dateTo: to,
    );

    loadAll(projectName: projectName, budgetOrContractValue: budget);
  }

  Future<bool> addMaterial(MaterialItem item) async {
    try {
      await _repo.addMaterial(item);
      final list = await _repo.getProjectMaterials(_projectId);
      state = state.copyWith(materials: list);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteMaterial(String materialId) async {
    try {
      await _repo.deleteMaterial(materialId);
      final list = await _repo.getProjectMaterials(_projectId);
      state = state.copyWith(materials: list);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> addExpense(ExpenseItem item) async {
    try {
      await _repo.addExpense(item);
      final list = await _repo.getProjectExpenses(_projectId);
      state = state.copyWith(expenses: list);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      await _repo.deleteExpense(expenseId);
      final list = await _repo.getProjectExpenses(_projectId);
      state = state.copyWith(expenses: list);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> recordClientPayment(ClientPayment payment) async {
    try {
      await _repo.recordClientPayment(payment);
      final list = await _repo.getClientPayments(_projectId);
      state = state.copyWith(clientPayments: list);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> lockAndSendStatement(
    String statementId,
    Map<String, dynamic> snapshot,
  ) async {
    try {
      await _repo.lockAndSendStatementToClient(statementId, snapshot);
      final list = await _repo.getBillStatements(_projectId);
      state = state.copyWith(statements: list);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }
}
