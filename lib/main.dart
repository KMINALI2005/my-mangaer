import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const SmartCalculatorApp());
}

class SmartCalculatorApp extends StatelessWidget {
  const SmartCalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الآلة الحاسبة الذكية',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        fontFamily: 'Arial',
      ),
      home: const CalculatorHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CalculationResult {
  final List<double> numbers;
  final double sum;
  final double max;
  final double min;
  final int count;
  final DateTime timestamp;
  final String input;

  CalculationResult({
    required this.numbers,
    required this.sum,
    required this.max,
    required this.min,
    required this.count,
    required this.timestamp,
    required this.input,
  });

  Map<String, dynamic> toJson() {
    return {
      'numbers': numbers,
      'sum': sum,
      'max': max,
      'min': min,
      'count': count,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'input': input,
    };
  }

  factory CalculationResult.fromJson(Map<String, dynamic> json) {
    return CalculationResult(
      numbers: List<double>.from(json['numbers']),
      sum: json['sum'].toDouble(),
      max: json['max'].toDouble(),
      min: json['min'].toDouble(),
      count: json['count'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      input: json['input'],
    );
  }
}

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({Key? key}) : super(key: key);

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  CalculationResult? _currentResult;
  List<CalculationResult> _history = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _setupAnimations();
    _inputController.addListener(_onInputChanged);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onInputChanged() {
    if (_inputController.text.isNotEmpty) {
      _calculateNumbers();
    } else {
      setState(() {
        _currentResult = null;
      });
    }
  }

  void _calculateNumbers() {
    String input = _inputController.text.trim();
    if (input.isEmpty) return;

    try {
      // تنظيف النص وإزالة المسافات الزائدة
      List<String> numberStrings = input
          .split(',')
          .map((s) => s.trim().replaceAll(RegExp(r'[^\d.]'), ''))
          .where((s) => s.isNotEmpty)
          .toList();

      if (numberStrings.isEmpty) return;

      List<double> numbers = numberStrings
          .map((s) => double.tryParse(s))
          .where((n) => n != null)
          .cast<double>()
          .toList();

      if (numbers.isEmpty) return;

      double sum = numbers.reduce((a, b) => a + b);
      double maxNum = numbers.reduce(max);
      double minNum = numbers.reduce(min);

      setState(() {
        _currentResult = CalculationResult(
          numbers: numbers,
          sum: sum,
          max: maxNum,
          min: minNum,
          count: numbers.length,
          timestamp: DateTime.now(),
          input: input,
        );
      });

      _animationController.forward();
    } catch (e) {
      // في حالة وجود خطأ، لا نعرض شيئاً
      setState(() {
        _currentResult = null;
      });
    }
  }

  void _saveToHistory() {
    if (_currentResult == null) return;

    setState(() {
      _history.insert(0, _currentResult!);
      if (_history.length > 50) {
        _history = _history.take(50).toList();
      }
    });

    _saveHistoryToPrefs();
    _showSuccessAnimation();
  }

  void _showSuccessAnimation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حفظ العملية في السجل ✅'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _saveHistoryToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _history.map((e) => e.toJson()).toList();
    await prefs.setString('calculator_history', json.encode(historyJson));
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyString = prefs.getString('calculator_history');
    
    if (historyString != null) {
      try {
        final historyJson = json.decode(historyString) as List;
        setState(() {
          _history = historyJson
              .map((e) => CalculationResult.fromJson(e))
              .toList();
        });
      } catch (e) {
        // في حالة وجود خطأ في التحميل، نبدأ بسجل فارغ
        setState(() {
          _history = [];
        });
      }
    }
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السجل'),
        content: const Text('هل أنت متأكد من مسح جميع العمليات السابقة؟'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _history.clear();
              });
              _saveHistoryToPrefs();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('تم مسح السجل بنجاح'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  void _reuseCalculation(CalculationResult result) {
    _inputController.text = result.input;
    setState(() {
      _currentResult = result;
      _showHistory = false;
    });
  }

  void _deleteHistoryItem(int index) {
    setState(() {
      _history.removeAt(index);
    });
    _saveHistoryToPrefs();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'الآلة الحاسبة الذكية',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
              });
            },
            icon: Icon(
              _showHistory ? Icons.calculate : Icons.history,
              size: 28,
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showHistory ? _buildHistoryView() : _buildCalculatorView(),
      ),
    );
  }

  Widget _buildCalculatorView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputCard(),
          const SizedBox(height: 20),
          if (_currentResult != null) _buildResultCard(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 8,
      shadowColor: Colors.blue.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.blue.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calculate_outlined,
                  color: const Color(0xFF2196F3),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'أدخل الأرقام',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'مثال: 1000, 2000, 300',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.numbers,
                  color: const Color(0xFF2196F3),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF2196F3),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.\s]')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'اكتب الأرقام مفصولة بفواصل (,)',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Card(
        elevation: 12,
        shadowColor: Colors.purple.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6B73FF),
                const Color(0xFF9575CD),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'النتائج',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildResultRow('المجموع', _formatNumber(_currentResult!.sum)),
              _buildResultRow('أكبر رقم', _formatNumber(_currentResult!.max)),
              _buildResultRow('أصغر رقم', _formatNumber(_currentResult!.min)),
              _buildResultRow('عدد الأرقام', '${_currentResult!.count}'),
              _buildResultRow(
                'التاريخ',
                _formatDateTime(_currentResult!.timestamp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _currentResult != null ? _saveToHistory : null,
            icon: const Icon(Icons.save_alt),
            label: const Text(
              'حفظ في السجل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              _inputController.clear();
              setState(() {
                _currentResult = null;
              });
              _animationController.reset();
            },
            icon: const Icon(Icons.clear_all),
            label: const Text(
              'مسح',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFF5722),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              side: const BorderSide(color: Color(0xFFFF5722), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryView() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السجل (${_history.length} عملية)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
              if (_history.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'مسح الكل',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد عمليات محفوظة',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    return _buildHistoryCard(_history[index], index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(CalculationResult result, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _reuseCalculation(result),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'المدخل: ${result.input}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _reuseCalculation(result),
                        icon: const Icon(Icons.replay, color: Colors.green),
                        iconSize: 20,
                      ),
                      IconButton(
                        onPressed: () => _deleteHistoryItem(index),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniResult('المجموع', _formatNumber(result.sum)),
                  _buildMiniResult('أكبر', _formatNumber(result.max)),
                  _buildMiniResult('أصغر', _formatNumber(result.min)),
                  _buildMiniResult('العدد', '${result.count}'),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatDateTime(result.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniResult(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
