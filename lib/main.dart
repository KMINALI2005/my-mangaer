import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'providers/debt_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DebtProvider(),
      child: MaterialApp(
        title: 'My Manager - دفتر الديون',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          primaryColor: Color(0xFFF57C00),
          scaffoldBackgroundColor: Color(0xFFF5F5F5),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFFF57C00),
            foregroundColor: Colors.white,
            elevation: 2,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
          ),
          cardTheme: CardTheme(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Color(0xFF212121)),
            bodyMedium: TextStyle(color: Color(0xFF212121)),
            titleLarge: TextStyle(
              color: Color(0xFF212121),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}

// تعريف ChangeNotifierProvider محلي لتجنب مشاكل الاستيراد
class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {
  final T Function(BuildContext context) create;
  final Widget child;

  const ChangeNotifierProvider({
    Key? key,
    required this.create,
    required this.child,
  }) : super(key: key);

  @override
  State<ChangeNotifierProvider<T>> createState() => _ChangeNotifierProviderState<T>();

  static T of<T extends ChangeNotifier>(BuildContext context, {bool listen = true}) {
    final state = context.findAncestorStateOfType<_ChangeNotifierProviderState<T>>();
    if (state == null) {
      throw StateError('No ChangeNotifierProvider<$T> found in context');
    }
    if (listen) {
      context.dependOnInheritedElement(state._element!);
    }
    return state._notifier;
  }
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {
  late T _notifier;
  InheritedElement? _element;

  @override
  void initState() {
    super.initState();
    _notifier = widget.create(context);
    _notifier.addListener(_listener);
  }

  @override
  void dispose() {
    _notifier.removeListener(_listener);
    _notifier.dispose();
    super.dispose();
  }

  void _listener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedProvider<T>(
      notifier: _notifier,
      child: widget.child,
    );
  }
}

class _InheritedProvider<T extends ChangeNotifier> extends InheritedWidget {
  final T notifier;

  const _InheritedProvider({
    Key? key,
    required this.notifier,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedProvider<T> oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
