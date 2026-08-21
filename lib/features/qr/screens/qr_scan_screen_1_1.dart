
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons_svg.dart';
import '../../../core/utils/qr_parser.dart';
import 'qr_result_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});
  @override State<QrScanScreen> createState()=>_QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController controller = MobileScannerController(facing: CameraFacing.back, torchEnabled: false);
  bool scanned=false;
  @override void dispose(){ controller.dispose(); super.dispose(); }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('QR LAB'), leading: GestureDetector(onTap: ()=>Navigator.pop(context), child: const Icon(Icons.close, color: AppColors.text))),
      body: Stack(children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture){
            if(scanned) return;
            final barcodes = capture.barcodes;
            if(barcodes.isEmpty) return;
            final raw = barcodes.first.rawValue;
            if(raw==null) return;
            scanned=true;
            final parsed = QrParser.parse(raw);
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>QrResultScreen(parsed: parsed)));
          },
        ),
        Center(child: Container(width: 240, height: 240, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(16)))),
        Positioned(bottom: 32, left: 0, right: 0, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(onTap: ()=>controller.toggleTorch(), child: Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border)), child: Center(child: SvgPicture.asset(AppIconSvg.flash, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn))))),
        ])),
      ]),
    );
  }
}
