
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons_svg.dart';
import '../../scanner/screens/scan_camera_screen.dart';
import '../../qr/screens/qr_scan_screen.dart';
import '../../qr/screens/qr_create_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState()=>_HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FileSystemEntity> recentFiles = [];
  String search = '';

  @override void initState(){
    super.initState();
    _loadRecents();
  }

  Future<void> _loadRecents() async {
    final box = await Hive.openBox('scans');
    // load from docs
    setState((){});
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(slivers: [
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20,20,20,12), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ScanPro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.8, color: AppColors.text)),
              const SizedBox(height: 2),
              Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF00FF88), shape: BoxShape.circle)), const SizedBox(width: 6), const Text('OFFLINE • 4K • NO ADS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.text3))]),
            ]),
            GestureDetector(onTap: (){ HapticFeedback.lightImpact(); Navigator.push(context, MaterialPageRoute(builder: (_)=>const QrScanScreen())); }, child: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Center(child: SvgPicture.asset(AppIconSvg.scan, width: 18, height: 18, colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn))))),
          ]))),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Container(padding: const EdgeInsets.symmetric(horizontal: 14), height: 44, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Row(children: [SvgPicture.asset(AppIconSvg.scan, width: 16, height: 16, colorFilter: const ColorFilter.mode(AppColors.text3, BlendMode.srcIn)), const SizedBox(width: 10), Expanded(child: TextField(onChanged: (v)=>setState(()=>search=v), style: const TextStyle(color: AppColors.text, fontSize: 14), decoration: const InputDecoration(border: InputBorder.none, hintText: 'Search by OCR text...', hintStyle: TextStyle(color: AppColors.text3, fontSize: 14))))]))))),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
            _actionCard('SCAN', AppIconSvg.scan, AppColors.text, AppColors.bg, ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const ScanCameraScreen()))),
            const SizedBox(width: 12),
            _actionCard('QR LAB', AppIconSvg.wifiQr, AppColors.surface2, AppColors.text, ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const QrScanScreen()))),
            const SizedBox(width: 12),
            _actionCard('CREATE', AppIconSvg.add, AppColors.surface2, AppColors.text, ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const QrCreateScreen()))),
          ]))),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text('FOLDERS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: AppColors.text3)), Text('SEE ALL', style: TextStyle(fontSize: 11, color: AppColors.text3))]))),
          SliverToBoxAdapter(child: SizedBox(height: 96, child: ListView.builder(scrollDirection: Axis.horizontal, padding: const EdgeInsets.fromLTRB(20,12,20,0), itemCount: 5, itemBuilder: (_, i){
            final names=['All Scans','Invoices','IDs','Books','Trash'];
            final counts=['128','24','12','8','3'];
            return Container(margin: const EdgeInsets.only(right: 12), width: 140, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SvgPicture.asset(AppIconSvg.folder, width: 22, height: 22, colorFilter: const ColorFilter.mode(AppColors.text2, BlendMode.srcIn)), const Spacer(), Text(names[i], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)), const SizedBox(height: 4), Text('\${counts[i]} files', style: const TextStyle(fontSize: 11, color: AppColors.text3))]));
          }))),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: const [Text('RECENT • 4K', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1, color: AppColors.text3))]))),
          SliverPadding(padding: const EdgeInsets.fromLTRB(20,12,20,100), sliver: SliverGrid.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75), itemCount: 6, itemBuilder: (_, i)=> Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Container(color: AppColors.surface2, child: Center(child: SvgPicture.asset(AppIconSvg.filePdf, width: 28, height: 28, colorFilter: const ColorFilter.mode(AppColors.text3, BlendMode.srcIn)))))), Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ScanPro_2026-08-21_\${i+1}.pdf', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.text), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 2), const Text('4K • 2.4 MB • OCR', style: TextStyle(fontSize: 10, color: AppColors.text3))]))]))),
        ]),
      ),
      floatingActionButton: GestureDetector(
        onTap: (){ HapticFeedback.mediumImpact(); Navigator.push(context, MaterialPageRoute(builder: (_)=>const ScanCameraScreen())); },
        child: Container(width: 64, height: 64, decoration: BoxDecoration(color: AppColors.text, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 24)]), child: Center(child: SvgPicture.asset(AppIconSvg.scan, width: 26, height: 26, colorFilter: const ColorFilter.mode(AppColors.bg, BlendMode.srcIn)))),
      ),
    );
  }

  Widget _actionCard(String label, String icon, Color bg, Color fg, VoidCallback onTap){
    return Expanded(child: GestureDetector(onTap: (){ HapticFeedback.lightImpact(); onTap(); }, child: Container(height: 84, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: bg==AppColors.text? Colors.transparent: AppColors.border)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [SvgPicture.asset(icon, width: 22, height: 22, colorFilter: ColorFilter.mode(fg, BlendMode.srcIn)), const SizedBox(height: 8), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: fg))]))));
  }
}
