import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/debt_provider.dart';
import '../models/debt.dart';
import '../main.dart';
import 'add_debt_screen.dart';
import 'archive_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ar_SA',
    symbol: 'ر.س',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChangeNotifierProvider.of<DebtProvider>(context, listen: false).loadDebts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Manager - دفتر الديون'),
        actions: [
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ArchiveScreen()),
              );
            },
            tooltip: 'الأرشيف',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          _buildSearchBar(),
          Expanded(
            child: _buildDebtsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDebtScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'إضافة دين جديد',
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<DebtProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'إجمالي الديون',
                  _currencyFormat.format(provider.totalDebt),
                  Colors.red,
                  Icons.money_off,
                ),
                _buildSummaryItem(
                  'عدد العملاء',
                  '${provider.totalCustomers}',
                  Colors.blue,
                  Icons.people,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'البحث عن عميل...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ChangeNotifierProvider.of<DebtProvider>(context, listen: false)
                        .clearSearch();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFF57C00)),
          ),
        ),
        onChanged: (value) {
          ChangeNotifierProvider.of<DebtProvider>(context, listen: false)
              .searchDebts(value);
        },
      ),
    );
  }

  Widget _buildDebtsList() {
    return Consumer<DebtProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        final unpaidDebts = provider.unpaidDebts;

        if (unpaidDebts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  provider.searchQuery.isNotEmpty
                      ? 'لم يتم العثور على نتائج للبحث'
                      : 'لا توجد ديون مستحقة',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  provider.searchQuery.isNotEmpty
                      ? 'حاول البحث بكلمة مختلفة'
                      : 'جميع الديون تم تحصيلها',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: unpaidDebts.length,
          itemBuilder: (context, index) {
            final debt = unpaidDebts[index];
            return _buildDebtCard(debt);
          },
        );
      },
    );
  }

  Widget _buildDebtCard(Debt debt) {
    final dateFormat = DateFormat('yyyy/MM/dd', 'ar');
    
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Color(0xFFF57C00),
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          debt.customerName,
          style: TextStyle(
            fontSize: 18,
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
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
        trailing: ElevatedButton(
          onPressed: () => _showPaymentConfirmation(debt),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'تم السداد',
            style: TextStyle(color: Colors.white),
          ),
        ),
        onLongPress: () => _showDeleteConfirmation(debt),
      ),
    );
  }

  void _showPaymentConfirmation(Debt debt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد السداد'),
          content: Text(
            'هل تم سداد دين ${debt.customerName} بمبلغ ${_currencyFormat.format(debt.amount)}؟',
          ),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('تأكيد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ChangeNotifierProvider.of<DebtProvider>(context, listen: false)
                    .markAsPaid(debt.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تسجيل السداد بنجاح'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Debt debt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('حذف الدين'),
          content: Text(
            'هل تريد حذف دين ${debt.customerName} نهائياً؟\nلا يمكن التراجع عن هذا الإجراء.',
          ),
          actions: [
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('حذف'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ChangeNotifierProvider.of<DebtProvider>(context, listen: false)
                    .deleteDebt(debt.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف الدين'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

// تعريف Consumer محلي
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
