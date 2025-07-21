import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../widgets/result_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _birthDate;
  Map<String, int> _age = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel(); // إيقاف المؤقت عند الخروج من الشاشة لمنع تسريب الذاكرة
    super.dispose();
  }

  void _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'اختر تاريخ ميلادك',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );

    if (pickedDate != null && pickedDate != _birthDate) {
      setState(() {
        _birthDate = pickedDate;
        _calculateAge();
        _startTimer();
      });
    }
  }

  void _calculateAge() {
    if (_birthDate == null) return;

    final now = DateTime.now();
    int years = now.year - _birthDate!.year;
    int months = now.month - _birthDate!.month;
    int days = now.day - _birthDate!.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final seconds = now.difference(_birthDate!).inSeconds;

    _age = {
      'years': years,
      'months': months,
      'days': days,
      'seconds': seconds,
    };
  }

  void _startTimer() {
    _timer?.cancel(); // إيقاف أي مؤقت سابق
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _age['seconds'] = (_age['seconds'] ?? 0) + 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حساب العمر الذكي'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff1e1e2f), Color(0xff121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'اختر تاريخ ميلادك لتبدأ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                label: Text(
                  _birthDate == null
                      ? 'اختيار التاريخ'
                      : intl.DateFormat.yMMMMd('ar').format(_birthDate!),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.deepPurple.withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (_birthDate != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: _buildResultsGrid(),
                )
              else
                Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsGrid() {
    final formatter = intl.NumberFormat("#,###", "ar");

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        ResultCard(
          title: 'السنوات',
          value: formatter.format(_age['years']),
          icon: Icons.cake,
          color: Colors.orange,
        ),
        ResultCard(
          title: 'الأشهر',
          value: formatter.format(_age['months']),
          icon: Icons.calendar_view_month,
          color: Colors.green,
        ),
        ResultCard(
          title: 'الأيام',
          value: formatter.format(_age['days']),
          icon: Icons.calendar_today,
          color: Colors.blue,
        ),
        ResultCard(
          title: 'الثواني',
          value: formatter.format(_age['seconds']),
          icon: Icons.timer,
          color: Colors.red,
        ),
      ],
    );
  }
}
