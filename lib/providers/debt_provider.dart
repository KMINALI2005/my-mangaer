import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import '../services/database_helper.dart';

class DebtProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Debt> _debts = [];
  List<Debt> _filteredDebts = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Debt> get debts => _filteredDebts;
  List<Debt> get unpaidDebts => _filteredDebts.where((debt) => !debt.isPaid).toList();
  List<Debt> get paidDebts => _filteredDebts.where((debt) => debt.isPaid).toList();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  double get totalDebt {
    return unpaidDebts.fold(0.0, (sum, debt) => sum + debt.amount);
  }

  int get totalCustomers {
    return unpaidDebts.map((debt) => debt.customerName).toSet().length;
  }

  Future<void> loadDebts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _debts = await _dbHelper.getAllDebts();
      _filterDebts();
    } catch (e) {
      print('خطأ في تحميل الديون: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDebt(Debt debt) async {
    try {
      await _dbHelper.insertDebt(debt);
      await loadDebts();
    } catch (e) {
      print('خطأ في إضافة الدين: $e');
      throw e;
    }
  }

  Future<void> markAsPaid(int debtId) async {
    try {
      final debt = _debts.firstWhere((d) => d.id == debtId);
      final updatedDebt = debt.copyWith(isPaid: true);
      await _dbHelper.updateDebt(updatedDebt);
      await loadDebts();
    } catch (e) {
      print('خطأ في تحديث حالة السداد: $e');
      throw e;
    }
  }

  Future<void> deleteDebt(int debtId) async {
    try {
      await _dbHelper.deleteDebt(debtId);
      await loadDebts();
    } catch (e) {
      print('خطأ في حذف الدين: $e');
      throw e;
    }
  }

  void searchDebts(String query) {
    _searchQuery = query;
    _filterDebts();
    notifyListeners();
  }

  void _filterDebts() {
    if (_searchQuery.isEmpty) {
      _filteredDebts = List.from(_debts);
    } else {
      _filteredDebts = _debts
          .where((debt) =>
              debt.customerName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filterDebts();
    notifyListeners();
  }
}
