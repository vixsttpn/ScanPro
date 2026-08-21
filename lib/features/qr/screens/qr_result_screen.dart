
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wifi_iot/wifi_iot.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons_svg.dart';
import '../../../core/utils/qr_parser.dart';

class QrResultScreen extends StatefulWidget {
  final ParsedQr parsed;
  const QrResultScreen({super.key, required this.parsed});
  @override State<QrResultScreen> createState()=>_QrResultScreenState();
}

class _QrResultScreenState extends State<QrResultScreen> {
  bool showPass=false;
  @override void initState(){
    super.initState();
    _saveHistory();
  }

  Future<void> _saveHistory() async {
    final box = await Hive.openBox('qr_history');
    await box.add({'raw': widget.parsed.raw, 'type': widget.parsed.type.name, 'date': DateTime.now().toIso8601String()});
  }

  @override Widget build(BuildContext context){
    final p = widget.parsed;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: Text(p.type.name.toUpperCase()), leading: GestureDetector(onTap: ()=>Navigator.pop(context), child: const Icon(Icons.arrow_back, color: AppColors.text))),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Center(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: QrImageView(data: p.raw, size: 200))),
        const SizedBox(height: 24),
        if(p.type==QrType.wifi && p.wifi!=null) _wifiCard(p.wifi!),
        if(p.type==QrType.url) _urlCard(p),
        if(p.type!=QrType.wifi && p.type!=QrType.url) _textCard(p),
        const SizedBox(height: 24),
        _actions(p),
      ]),
    );
  }

  Widget _wifiCard(QrWifi wifi){
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [SvgPicture.asset(AppIconSvg.wifiQr, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn)), const SizedBox(width: 8), const Text('WIFI', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5))]),
        const SizedBox(height: 16),
        _row('SSID', wifi.ssid),
        _row('Security', wifi.security),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Text(showPass? wifi.password : '••••••••', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
          GestureDetector(onTap: ()=>setState(()=>showPass=!showPass), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(8)), child: Icon(showPass? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.text2))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _primaryBtn('CONNECT', () async {
            try{
              final ok = await WiFiForIoTPlugin.connect(wifi.ssid, password: wifi.password, security: NetworkSecurity.WPA, joinOnce: false);
              if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok? 'Connected to \${wifi.ssid}':'Failed'), backgroundColor: AppColors.surface2));
            }catch(e){
              if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e'), backgroundColor: AppColors.surface2));
            }
          })),
          const SizedBox(width: 12),
          Expanded(child: _secondaryBtn('COPY PASS', (){ Clipboard.setData(ClipboardData(text: wifi.password)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password copied'), backgroundColor: AppColors.surface2)); })),
        ]),
      ]),
    );
  }

  Widget _urlCard(ParsedQr p){
    final uri = Uri.tryParse(p.url!);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [SvgPicture.asset(AppIconSvg.linkQr, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn)), const SizedBox(width: 8), const Text('URL • SAFE PREVIEW', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 0.6))]),
        const SizedBox(height: 12),
        Text(p.url!, style: const TextStyle(color: AppColors.text, fontSize: 15)),
        const SizedBox(height: 8),
        Text('Domain: \${uri?.host ?? 'unknown'}', style: const TextStyle(color: AppColors.text2, fontSize: 12)),
      ]),
    );
  }

  Widget _textCard(ParsedQr p){
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Text(p.raw, style: const TextStyle(color: AppColors.text)),
    );
  }

  Widget _actions(ParsedQr p){
    return Row(children: [
      Expanded(child: _secondaryBtn('SHARE', ()=>Share.share(p.raw))),
      const SizedBox(width: 12),
      Expanded(child: _secondaryBtn('COPY', (){ Clipboard.setData(ClipboardData(text: p.raw)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied'), backgroundColor: AppColors.surface2)); })),
    ]);
  }

  Widget _row(String k, String v)=> Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(k, style: const TextStyle(color: AppColors.text3, fontSize: 11, letterSpacing: 0.5)), Text(v, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w500))]));
  Widget _primaryBtn(String label, VoidCallback onTap)=> GestureDetector(onTap: (){ HapticFeedback.lightImpact(); onTap(); }, child: Container(height: 44, decoration: BoxDecoration(color: AppColors.text, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.5, color: AppColors.bg)))));
  Widget _secondaryBtn(String label, VoidCallback onTap)=> GestureDetector(onTap: (){ HapticFeedback.lightImpact(); onTap(); }, child: Container(height: 44, decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)), child: Center(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, letterSpacing: 0.5, color: AppColors.text)))));
}
