
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/scanner/bloc/scanner_bloc.dart';
import 'features/home/screens/home_screen.dart';

class ScanProApp extends StatelessWidget {
  const ScanProApp({super.key});
  @override Widget build(BuildContext context){
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_)=>ScannerBloc())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ScanPro',
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );
  }
}
