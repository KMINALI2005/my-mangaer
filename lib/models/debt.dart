class Debt {
  String? id;
  final String customerName;
  final double amount;
  final DateTime date;
  bool isPaid;

  Debt({
    this.id,
    required this.customerName,
    required this.amount,
    required this.date,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'amount': amount,
      'date': date.toIso8601String(),
      'isPaid': isPaid,
    };
  }

  factory Debt.fromMap(String id, Map<String, dynamic> map) {
    return Debt(
      id: id,
      customerName: map['customerName'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isPaid: map['isPaid'],
    );
  }
}
