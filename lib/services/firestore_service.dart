import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/debt.dart';

class FirestoreService {
  final CollectionReference _debtsCollection =
      FirebaseFirestore.instance.collection('debts');

  Future<void> addDebt(Debt debt) async {
    await _debtsCollection.add(debt.toMap());
  }

  Future<void> updateDebt(Debt debt) async {
    await _debtsCollection.doc(debt.id).update(debt.toMap());
  }

  Stream<List<Debt>> getDebts() {
    return _debtsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Debt.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
