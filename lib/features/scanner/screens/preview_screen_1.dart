
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:archive/archive.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons_svg.dart';
import '../../../core/utils/doc_processor.dart';
import '../widgets/filter_carousel.dart';

class PreviewScreen extends StatefulWidget {
  final List<String> imagePaths;
  final String originalPath;
  const PreviewScreen({super.key, required this.imagePaths, required this.originalPath});
  @override State<PreviewScreen> createState()=>_PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  DocFilter filter = DocFilter.auto;
  List<String> filteredPaths = [];
  String? ocrText;
  bool ocrLoading=false;
  double brightness=0;
  double contrast=0;

  @override void initState(){
    super.initState();
    filteredPaths = List.from(widget.imagePaths);
    _applyFilter(filter);
  }

  Future<void> _applyFilter(DocFilter f) async {
    setState(()=>filter=f);
    HapticFeedback.lightImpact();
    final out=[];
    for(var p in widget.imagePaths){
      final res = await DocProcessor.applyFilter(p, f);
      out.add(res);
    }
    if(mounted) setState(()=>filteredPaths=out);
  }

  Future<void> _runOcr() async {
    setState(()=>ocrLoading=true);
    try{
      final input = InputImage.fromFilePath(filteredPaths.first);
      final rec = TextRecognizer();
      final res = await rec.processImage(input);
      await rec.close();
      setState(()=>ocrText=res.text);
    }catch(e){
      setState(()=>ocrText='OCR error: \$e');
    }
    setState(()=>ocrLoading=false);
  }

  Future<void> _exportPdf({bool searchable=false, bool withPassword=false}) async {
    final pdf = pw.Document();
    for(var path in filteredPaths){
      final bytes = await File(path).readAsBytes();
      final image = pw.MemoryImage(bytes);
      pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx){
          return pw.Stack(children: [
            pw.Positioned.fill(child: pw.Image(image, fit: pw.BoxFit.contain)),
            if(searchable && ocrText!=null)
              pw.Positioned.fill(child: pw.Opacity(opacity: 0, child: pw.Text(ocrText!, style: pw.TextStyle(fontSize: 2, color: PdfColors.black)))),
          ]);
        },
      ));
    }
    Uint8List pdfBytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final name = 'ScanPro_\${DateTime.now().toIso8601String().substring(0,10)}_001.pdf';
    final file = File('\${dir.path}/\$name');
    await file.writeAsBytes(pdfBytes);
    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF saved: \${file.path} (\${(pdfBytes.length/1024).toStringAsFixed(1)} KB)'), backgroundColor: AppColors.surface2));
    }
  }

  Future<void> _exportJpg() async {
    final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    final scanPro = Directory('\${dir.path}/ScanPro');
    if(!await scanPro.exists()) await scanPro.create(recursive: true);
    for(int i=0;i<filteredPaths.length;i++){
      final src = File(filteredPaths[i]);
      final dest = File('\${scanPro.path}/ScanPro_\${DateTime.now().toIso8601String().substring(0,10)}_\${i+1}.jpg');
      await src.copy(dest.path);
    }
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to DCIM/ScanPro'), backgroundColor: AppColors.surface2));
  }

  Future<void> _exportTxt() async {
    if(ocrText==null) await _runOcr();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('\${dir.path}/ScanPro_\${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(ocrText??'');
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('TXT saved: \${file.path}'), backgroundColor: AppColors.surface2));
  }

  Future<void> _exportZip() async {
    final archive = Archive();
    for(var p in filteredPaths){
      final bytes = await File(p).readAsBytes();
      archive.addFile(ArchiveFile(p.split('/').last, bytes.length, bytes));
    }
    final zipBytes = ZipEncoder().encode(archive);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('\${dir.path}/ScanPro_\${DateTime.now().millisecondsSinceEpoch}.zip');
    await file.writeAsBytes(zipBytes!);
    if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ZIP saved: \${file.path}'), backgroundColor: AppColors.surface2));
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('PREVIEW'),
        actions: [
          GestureDetector(onTap: (){ HapticFeedback.lightImpact(); Share.shareXFiles(filteredPaths.map((e)=>XFile(e)).toList()); }, child: Padding(padding: const EdgeInsets.only(right: 16), child: SvgPicture.asset(AppIconSvg.share, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn)))),
        ],
      ),
      body: Column(children: [
        Expanded(child: PageView.builder(
          itemCount: filteredPaths.length,
          itemBuilder: (_, i)=> RepaintBoundary(child: Padding(padding: const EdgeInsets.all(16), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(filteredPaths[i]), fit: BoxFit.contain)))),
        )),
        FilterCarousel(selected: filter, onSelect: _applyFilter),
        const SizedBox(height: 12),
        _ocrSection(),
        const SizedBox(height: 12),
        _exportPanel(),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _ocrSection(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          SvgPicture.asset(AppIconSvg.textOcr, width: 16, height: 16, colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn)),
          const SizedBox(width: 8),
          const Text('OCR • OFFLINE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: AppColors.text)),
          const Spacer(),
          GestureDetector(
            onTap: _runOcr,
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: AppColors.text, borderRadius: BorderRadius.circular(20)), child: Text(ocrLoading? '...':'RUN OCR', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.bg))),
          ),
        ]),
        if(ocrText!=null)...[
          const SizedBox(height: 8),
          Text(ocrText!, maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 6),
          GestureDetector(onTap: (){ Clipboard.setData(ClipboardData(text: ocrText!)); HapticFeedback.lightImpact(); }, child: const Text('COPY TEXT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.text))),
        ]
      ]),
    );
  }

  Widget _exportPanel(){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('EXPORT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8, color: AppColors.text3)),
          Text('\${filteredPaths.length} page(s) • 4K', style: const TextStyle(fontSize: 11, color: AppColors.text3)),
        ]),
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
          _exportBtn(AppIconSvg.filePdf, 'PDF', ()=>_exportPdf()),
          _exportBtn(AppIconSvg.filePdf, 'PDF+', ()=>_exportPdf(searchable: true)),
          _exportBtn(AppIconSvg.fileJpg, 'JPG 4K', _exportJpg),
          _exportBtn(AppIconSvg.fileTxt, 'TXT', _exportTxt),
          _exportBtn(AppIconSvg.folder, 'ZIP', _exportZip),
          _exportBtn(AppIconSvg.share, 'PRINT', () async { await Printing.layoutPdf(onLayout: (_) async => (await File(filteredPaths.first).readAsBytes())); }),
        ])),
      ]),
    );
  }

  Widget _exportBtn(String icon, String label, VoidCallback onTap){
    return GestureDetector(
      onTap: (){ HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          SvgPicture.asset(icon, width: 16, height: 16, colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text)),
        ]),
      ),
    );
  }
}
