
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';

class QrCreateScreen extends StatefulWidget {
  const QrCreateScreen({super.key});
  @override State<QrCreateScreen> createState()=>_QrCreateScreenState();
}

class _QrCreateScreenState extends State<QrCreateScreen> {
  final controller = TextEditingController(text: 'https://scanpro.app');
  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('CREATE QR')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          TextField(controller: controller, style: const TextStyle(color: AppColors.text), decoration: const InputDecoration(hintText: 'Enter text / URL / WIFI string', hintStyle: TextStyle(color: AppColors.text3), filled: true, fillColor: AppColors.surface, border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: AppColors.border)))), onChanged: (_)=>setState((){})),
          const SizedBox(height: 24),
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: QrImageView(data: controller.text, size: 200)),
          const SizedBox(height: 24),
          GestureDetector(onTap: ()=>Share.share(controller.text), child: Container(height: 48, decoration: BoxDecoration(color: AppColors.text, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('SHARE QR', style: TextStyle(color: AppColors.bg, fontWeight: FontWeight.w600))))),
        ]),
      ),
    );
  }
}
