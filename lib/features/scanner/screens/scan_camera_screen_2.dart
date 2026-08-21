
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_icons_svg.dart';
import '../../../core/utils/doc_processor.dart';
import '../bloc/scanner_bloc.dart';
import '../widgets/edge_painter.dart';
import '../widgets/scan_overlay.dart';
import '../widgets/shutter_button.dart';
import 'crop_screen.dart';
import 'package:edge_detection/edge_detection.dart' as ed;

class ScanCameraScreen extends StatefulWidget {
  const ScanCameraScreen({super.key});
  @override State<ScanCameraScreen> createState()=>_ScanCameraScreenState();
}

class _ScanCameraScreenState extends State<ScanCameraScreen> {
  CameraController? controller;
  bool isReady=false;
  List<CameraDescription>? cameras;
  List<DocPoints>? detected;
  List<DocPoints>? lastStable;
  DateTime lastDetect=DateTime.now();
  Timer? detectTimer;
  bool stable=false;
  DateTime stableSince=DateTime.now();
  bool autoMode=true;
  bool torch=false;

  @override void initState(){
    super.initState();
    _initCamera();
    detectTimer=Timer.periodic(const Duration(milliseconds: 300), (_) => _detectEdge());
  }

  Future<void> _initCamera() async {
    cameras=await availableCameras();
    if(cameras==null||cameras!.isEmpty) return;
    final cam = cameras!.firstWhere((c)=>c.lensDirection==CameraLensDirection.back, orElse:()=>cameras!.first);
    controller=CameraController(cam, ResolutionPreset.ultraHigh, enableAudio:false, imageFormatGroup: ImageFormatGroup.jpeg);
    await controller!.initialize();
    if(mounted) setState(()=>isReady=true);
  }

  Future<void> _detectEdge() async {
    if(controller==null||!controller!.value.isInitialized) return;
    try{
      // Using edge_detection plugin requires file path, so we simulate with last picture? For demo, we use dummy stable detection after 1s
      // Real implementation: capture frame to temp file via controller.takePicture low res, but to keep 120fps we use Isolate
      // Here we generate fake quadrilateral centered
      if(!mounted) return;
      final now=DateTime.now();
      if(now.difference(lastDetect).inMilliseconds<300) return;
      lastDetect=now;
      // simulate detection: center rect 84% width 55% height as in overlay
      final points = [
        const DocPoints(0.08,0.18),
        const DocPoints(0.92,0.18),
        const DocPoints(0.92,0.73),
        const DocPoints(0.08,0.73),
      ];
      if(detected!=null){
        final iou = DocProcessor.iou(detected!, points);
        if(iou>0.92){
          if(!stable){
            stable=true;
            stableSince=DateTime.now();
          } else {
            if(DateTime.now().difference(stableSince).inMilliseconds>800 && autoMode){
              stable=false;
              await _capture();
            }
          }
        } else {
          stable=false;
        }
      }
      setState(()=>detected=points);
    }catch(_){}
  }

  Future<void> _capture() async {
    if(controller==null) return;
    HapticFeedback.mediumImpact();
    final file = await controller!.takePicture();
    if(!mounted) return;
    context.read<ScannerBloc>().add(ScannerImageCaptured(file.path));
    final mode = context.read<ScannerBloc>().state.mode;
    if(mode==ScanMode.single){
      Navigator.push(context, MaterialPageRoute(builder: (_)=>CropScreen(imagePath: file.path)));
    } else {
      // batch stay
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Captured'), backgroundColor: AppColors.surface2, duration: Duration(milliseconds: 600)));
    }
  }

  @override void dispose(){
    detectTimer?.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: isReady? RepaintBoundary(
        child: Stack(children: [
          Positioned.fill(child: CameraPreview(controller!)),
          ScanOverlay(child: CustomPaint(painter: EdgePainter(points: detected, imageSize: const Size(1,1), stable: stable), child: Container())),
          // top modes
          SafeArea(child: Column(children: [
            const SizedBox(height: 12),
            _modeSelector(),
            const Spacer(),
            _bottomBar(),
            const SizedBox(height: 24),
          ])),
        ]),
      ) : const Center(child: CircularProgressIndicator(color: AppColors.text)),
    );
  }

  Widget _modeSelector(){
    final modes = ScanMode.values;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(children: modes.map((m){
        final isSel = context.watch<ScannerBloc>().state.mode==m;
        return GestureDetector(
          onTap: ()=>context.read<ScannerBloc>().add(ScannerModeChanged(m)),
          child: AnimatedContainer(
            duration: AppDurations.ui,
            curve: AppDurations.curve,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSel? AppColors.text : AppColors.surface.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSel? AppColors.text: AppColors.border),
            ),
            child: Text(m.name.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: isSel? AppColors.bg: AppColors.text2)),
          ),
        );
      }).toList()),
    );
  }

  Widget _bottomBar(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _roundIcon(AppIconSvg.flash, () async {
          torch=!torch;
          await controller?.setFlashMode(torch? FlashMode.torch: FlashMode.off);
          setState((){});
        }, active: torch),
        ShutterButton(onTap: _capture),
        _roundIcon(AppIconSvg.gallery, () async {
          final picker=ImagePicker();
          final x = await picker.pickImage(source: ImageSource.gallery);
          if(x!=null && mounted){
            Navigator.push(context, MaterialPageRoute(builder: (_)=>CropScreen(imagePath: x.path)));
          }
        }),
      ]),
    );
  }

  Widget _roundIcon(String asset, VoidCallback onTap, {bool active=false}){
    return GestureDetector(
      onTap: (){ HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(shape: BoxShape.circle, color: active? AppColors.text : AppColors.surface.withOpacity(0.8), border: Border.all(color: AppColors.border)),
        child: Center(child: SvgPicture.asset(asset, width: 20, height: 20, colorFilter: ColorFilter.mode(active? AppColors.bg: AppColors.text, BlendMode.srcIn))),
      ),
    );
  }
}
