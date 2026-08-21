
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons_svg.dart';
import '../../../core/utils/doc_processor.dart';
import 'preview_screen.dart';

class CropScreen extends StatefulWidget {
  final String imagePath;
  const CropScreen({super.key, required this.imagePath});
  @override State<CropScreen> createState()=>_CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  List<DocPoints> points = const [
    DocPoints(0.08,0.18),
    DocPoints(0.92,0.18),
    DocPoints(0.92,0.73),
    DocPoints(0.08,0.73),
  ];
  int selectedIndex=-1;

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('CROP'),
        leading: GestureDetector(onTap: ()=>Navigator.pop(context), child: const Icon(Icons.close, color: AppColors.text)),
        actions: [
          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              // auto redetect simulation
              setState((){
                points = const [DocPoints(0.1,0.2),DocPoints(0.9,0.2),DocPoints(0.9,0.7),DocPoints(0.1,0.7)];
              });
            },
            child: Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)), child: Row(children: [SvgPicture.asset(AppIconSvg.scan, width: 14, height: 14, colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn)), const SizedBox(width: 6), const Text('AUTO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text))],)),
          )
        ],
      ),
      body: Column(children: [
        Expanded(child: RepaintBoundary(child: LayoutBuilder(builder: (ctx, constraints){
          return GestureDetector(
            onPanStart: (d){
              final local = d.localPosition;
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              for(int i=0;i<4;i++){
                final p = points[i];
                final dx = (p.x*w - local.dx).abs();
                final dy = (p.y*h - local.dy).abs();
                if(dx<40 && dy<40){
                  selectedIndex=i;
                  break;
                }
              }
            },
            onPanUpdate: (d){
              if(selectedIndex==-1) return;
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              double nx = (d.localPosition.dx / w).clamp(0.0,1.0);
              double ny = (d.localPosition.dy / h).clamp(0.0,1.0);
              // magnet to edges 20px ~ 0.02
              if(nx<0.02) nx=0.02;
              if(nx>0.98) nx=0.98;
              if(ny<0.02) ny=0.02;
              if(ny>0.98) ny=0.98;
              setState(()=>points[selectedIndex]=DocPoints(nx, ny));
            },
            onPanEnd: (_)=>selectedIndex=-1,
            child: Stack(children: [
              Positioned.fill(child: Image.file(File(widget.imagePath), fit: BoxFit.contain)),
              Positioned.fill(child: CustomPaint(painter: _CropPainter(points))),
            ]),
          );
        }))),
        _toolbar(),
        const SizedBox(height: 16),
        _doneButton(),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _toolbar(){
    return Container(
      height: 64,
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _tool(AppIconSvg.rotate, 'ROTATE', () async {
          // rotate 90 implemented via image lib in isolate would be here
          HapticFeedback.lightImpact();
        }),
        _tool(AppIconSvg.flip, 'FLIP', (){ HapticFeedback.lightImpact(); }),
        _tool(AppIconSvg.crop, 'A4', (){ setState(()=>points=[const DocPoints(0.15,0.1), const DocPoints(0.85,0.1), const DocPoints(0.85,0.9), const DocPoints(0.15,0.9)]); }),
        _tool(AppIconSvg.scan, 'ORIGINAL', (){ setState(()=>points=[const DocPoints(0.0,0.0), const DocPoints(1.0,0.0), const DocPoints(1.0,1.0), const DocPoints(0.0,1.0)]); }),
      ]),
    );
  }

  Widget _tool(String asset, String label, VoidCallback onTap){
    return GestureDetector(onTap: onTap, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SvgPicture.asset(asset, width: 20, height: 20, colorFilter: const ColorFilter.mode(AppColors.text, BlendMode.srcIn)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 9, letterSpacing: 0.5, color: AppColors.text2, fontWeight: FontWeight.w500)),
    ]));
  }

  Widget _doneButton(){
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        showDialog(context: context, barrierDismissible: false, builder: (_)=>const Center(child: CircularProgressIndicator(color: AppColors.text)));
        final out = await DocProcessor.perspectiveTransform(widget.imagePath, points);
        if(mounted){
          Navigator.pop(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>PreviewScreen(imagePaths: [out], originalPath: widget.imagePath)));
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        height: 52,
        decoration: BoxDecoration(color: AppColors.text, borderRadius: BorderRadius.circular(14)),
        child: const Center(child: Text('DONE → PREVIEW', style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.bg))),
      ),
    );
  }
}

class _CropPainter extends CustomPainter {
  final List<DocPoints> points;
  _CropPainter(this.points);
  @override void paint(Canvas canvas, Size size){
    final paint = Paint()..color=Colors.white..strokeWidth=2..style=PaintingStyle.stroke;
    final path=Path()
      ..moveTo(points[0].x*size.width, points[0].y*size.height)
      ..lineTo(points[1].x*size.width, points[1].y*size.height)
      ..lineTo(points[2].x*size.width, points[2].y*size.height)
      ..lineTo(points[3].x*size.width, points[3].y*size.height)
      ..close();
    canvas.drawPath(path, paint);
    for(var p in points){
      canvas.drawCircle(Offset(p.x*size.width, p.y*size.height), 12, Paint()..color=Colors.black..style=PaintingStyle.fill);
      canvas.drawCircle(Offset(p.x*size.width, p.y*size.height), 9, Paint()..color=Colors.white..style=PaintingStyle.fill);
    }
  }
  @override bool shouldRepaint(covariant _CropPainter old)=>old.points!=points;
}
