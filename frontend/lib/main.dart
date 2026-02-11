import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/group_provider.dart';
import 'providers/member_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/settlement_provider.dart';
import 'package:mouni/env/env.dart';
import 'package:mouni/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => ActivityStatusProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => SettlementProvider()),
      ],
      child: MaterialApp(
        title: 'Mouni 💸💸💸',
        theme: ThemeData.light(),
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
