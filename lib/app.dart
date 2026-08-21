import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/scanner/bloc/scanner_bloc.dart';
import 'features/home/screens/home_screen.dart';
import 'features/legal/screens/eula_screen.dart';

class ScanProApp extends StatelessWidget {
  const ScanProApp({super.key});

  Future<bool> _checkEula() async {
    final box = await Hive.openBox('settings');
    return box.get('eula_accepted_v1', defaultValue: false) as bool;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => ScannerBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ScanPro',
        theme: AppTheme.dark,
        home: FutureBuilder<bool>(
          future: _checkEula(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Scaffold(backgroundColor: AppColors.bg, body: Center(child: CircularProgressIndicator(color: AppColors.text)));
            }
            final accepted = snap.data!;
            if (!accepted) {
              return const EulaScreen();
            }
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}
