import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/debt_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DebtProvider(),
      child: MaterialApp(
        title: 'دفتر الديون',
        theme: ThemeData(
          primaryColor: Color(0xFFF57C00),
          scaffoldBackgroundColor: Color(0xFFF5F5F5),
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Color(0xFF4CAF50),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFFF57C00),
            elevation: 0,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFF57C00),
          ),
        ),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
