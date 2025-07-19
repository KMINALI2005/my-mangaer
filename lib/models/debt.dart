class Debt {
  final int? id;
  final String customerName;
  final double amount;
  final DateTime date;
  final bool isPaid;

  Debt({
    this.id,
    required this.customerName,
    required this.amount,
    required this.date,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'isPaid': isPaid ? 1 : 0,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id']?.toInt(),
      customerName: map['customerName'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isPaid: map['isPaid'] == 1,
    );
  }

  Debt copyWith({
    int? id,
    String? customerName,
    double? amount,
    DateTime? date,
    bool? isPaid,
  }) {
    return Debt(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}
