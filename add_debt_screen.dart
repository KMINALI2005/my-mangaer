import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';

class AddDebtScreen extends StatefulWidget {
  @override
  _AddDebtScreenState createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends State<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إضافة دين جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم الزبون',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'أدخل اسم الزبون' : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'مبلغ الدين',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'أدخل المبلغ';
                  if (double.tryParse(value) == null) return 'أدخل رقم صحيح';
                  return null;
                },
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text('التاريخ: ${DateFormat.yMd().format(_selectedDate)}'),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: Text('تغيير التاريخ'),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF2196F3),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final newDebt = Debt(
                        customerName: _nameController.text,
                        amount: double.parse(_amountController.text),
                        date: _selectedDate,
                      );
                      await Provider.of<DebtProvider>(context, listen: false)
                          .addDebt(newDebt);
                      Navigator.pop(context);
                    }
                  },
                  child: Text('إضافة الدين', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
