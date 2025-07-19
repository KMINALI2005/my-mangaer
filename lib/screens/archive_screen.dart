import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../main.dart';

class ArchiveScreen extends StatelessWidget {
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ar_SA',
    symbol: 'ر.س',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('أرشيف الديون المحصلة'),
        backgroundColor: Color(0xFFF57C00),
      ),
      body: Consumer<DebtProvider>(
        builder: (context, provider, child) {
          final paidDebts = provider.paidDebts;
          
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (paidDebts.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              _buildSummaryCard(paidDebts),
              Expanded(
                child: ListView.builder(
                  itemCount: paidDebts.length,
                  itemBuilder: (context, index) {
                    final debt = paidDebts[index];
                    return _buildPaidDebtCard(debt);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد ديون محصلة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ستظهر هنا الديون التي تم تحصيلها',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<Debt> paidDebts) {
    final totalPaidAmount = paidDebts.fold(0.0, (sum, debt) => sum + debt.amount);
    final uniqueCustomers = paidDebts.map((debt) => debt.customerName).toSet().length;

    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildSummaryItem(
              'إجمالي المحصل',
              _currencyFormat.format(totalPaidAmount),
              Color(0xFF4CAF50),
              Icons.check_circle,
            ),
            _buildSummaryItem(
              'عدد العملاء',
              '$uniqueCustomers',
              Colors.blue,
              Icons.people,
            ),
            _buildSummaryItem(
              'عدد الديون',
              '${paidDebts.length}',
              Colors.orange,
              Icons.receipt_long,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaidDebtCard(Debt debt) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Color(0xFF4CAF50),
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          debt.customerName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              _currencyFormat.format(debt.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4CAF50),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'تاريخ التسجيل: ${dateFormat.format(debt.date)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFF4CAF50), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.paid,
                color: Color(0xFF4CAF50),
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                'محصل',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// استخدام Consumer المحلي
class Consumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const Consumer({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final value = ChangeNotifierProvider.of<T>(context);
    return builder(context, value, child);
  }
}
