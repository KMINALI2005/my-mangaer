import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../main.dart';

class AddDebtScreen extends StatefulWidget {
  @override
  _AddDebtScreenState createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة دين جديد'),
        backgroundColor: Color(0xFFF57C00),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(),
              SizedBox(height: 24),
              _buildNameField(),
              SizedBox(height: 16),
              _buildAmountField(),
              SizedBox(height: 16),
              _buildDateField(),
              SizedBox(height: 32),
              _buildAddButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.add_business,
              size: 60,
              color: Color(0xFFF57C00),
            ),
            SizedBox(height: 12),
            Text(
              'إضافة دين جديد',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'أدخل بيانات الدين الجديد بعناية',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
