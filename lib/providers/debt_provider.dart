import 'package:flutter/material.dart';
import '../models/debt.dart';
import '../services/firestore_service.dart';

class DebtProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Debt> _debts = [];

  List<Debt> get activeDebts => _debts.where((debt) => !debt.isPaid).toList();
  List<Debt> get archivedDebts => _debts.where((debt) => debt.isPaid).toList();

  DebtProvider() {
    _loadDebts();
  }

  void _loadDebts() {
    _firestoreService.getDebts().listen((debts) {
      _debts = debts;
      notifyListeners();
    });
  }

  Future<void> addDebt(Debt debt) async {
    await _firestoreService.addDebt(debt);
  }

  Future<void> markAsPaid(Debt debt) async {
    debt.isPaid = true;
    await _firestoreService.updateDebt(debt);
  }

  Future<void> restoreDebt(Debt debt) async {
    debt.isPaid = false;
    await _firestoreService.updateDebt(debt);
  }
}
