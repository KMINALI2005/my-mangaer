import 'package:flutter/material.dart';
import '../models/debt.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;
  final bool isArchived;

  const DebtCard({required this.debt, this.isArchived = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFF57C00).withOpacity(0.2),
          child: Icon(Icons.person, color: Color(0xFFF57C00)),
        ),
        title: Text(
          debt.customerName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المبلغ: ${debt.amount.toStringAsFixed(2)} دينار'),
            Text('التاريخ: ${DateFormat.yMd().format(debt.date)}'),
          ],
        ),
        trailing: isArchived
            ? IconButton(
                icon: Icon(Icons.restore, color: Colors.blue),
                onPressed: () => Provider.of<DebtProvider>(context, listen: false)
                    .restoreDebt(debt),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF4CAF50),
                ),
                onPressed: () => Provider.of<DebtProvider>(context, listen: false)
                    .markAsPaid(debt),
                child: Text('تم السداد'),
              ),
      ),
    );
  }
}
