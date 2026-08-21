
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:opencv_dart/opencv_dart.dart' as cv;

enum DocFilter { original, auto, gray, bw, noShadow, lowLight }

class DocPoints {
  final double x, y;
  const DocPoints(this.x, this.y);
}

class DocProcessor {
  // Perspective transform to A4 300dpi 2480x3508 portrait
  static Future<String> perspectiveTransform(String inputPath, List<DocPoints> points, {int outW=2480, int outH=3508}) async {
    try {
      final mat = cv.imread(inputPath, flags: cv.IMREAD_COLOR);
      if (mat.isEmpty) throw Exception('empty mat');
      final srcPts = cv.Mat.fromList(4, 2, cv.MatType.CV_32FC1, [
        points[0].x, points[0].y,
        points[1].x, points[1].y,
        points[2].x, points[2].y,
        points[3].x, points[3].y,
      ]);
      final dstPts = cv.Mat.fromList(4, 2, cv.MatType.CV_32FC1, [
        0, 0,
        outW.toDouble(), 0,
        outW.toDouble(), outH.toDouble(),
        0, outH.toDouble(),
      ]);
      final m = cv.getPerspectiveTransform(srcPts, dstPts);
      final warped = cv.warpPerspective(mat, m, (outW, outH), flags: cv.INTER_CUBIC, borderMode: cv.BORDER_REPLICATE);
      final outPath = inputPath.replaceAll('.jpg', '_warped.jpg').replaceAll('.png', '_warped.jpg');
      cv.imwrite(outPath, warped);
      return outPath;
    } catch (e) {
      // fallback pure Dart: just copy
      return inputPath;
    }
  }

  static Future<String> applyFilter(String inputPath, DocFilter filter) async {
    final bytes = await File(inputPath).readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return inputPath;
    img.Image out;
    switch (filter) {
      case DocFilter.original:
        out = image;
        break;
      case DocFilter.auto:
        out = _enhanceAuto(image);
        break;
      case DocFilter.gray:
        out = img.grayscale(image);
        out = img.adjustColor(out, contrast: 25);
        break;
      case DocFilter.bw:
        out = img.grayscale(image);
        out = img.adjustColor(out, contrast: 35);
        // threshold 140
        for (var p in out) {
          final l = p.r.toInt();
          final v = l > 140 ? 255 : 0;
          p..r=v..g=v..b=v;
        }
        break;
      case DocFilter.noShadow:
        out = _removeShadow(image);
        break;
      case DocFilter.lowLight:
        out = img.adjustColor(image, gamma: 1.4, brightness: 10, contrast: 10);
        break;
    }
    final outPath = inputPath.replaceAll('.jpg', '_\${filter.name}.jpg');
    await File(outPath).writeAsBytes(img.encodeJpg(out, quality: 95));
    return outPath;
  }

  static img.Image _enhanceAuto(img.Image src) {
    var im = img.adjustColor(src, contrast: 15, brightness: 5, saturation: -5);
    // simple unsharp mask
    var blurred = img.gaussianBlur(im, radius: 2);
    for (int y=0; y<im.height; y++) {
      for (int x=0; x<im.width; x++) {
        final p = im.getPixel(x,y);
        final b = blurred.getPixel(x,y);
        int r = (p.r*1.5 - b.r*0.5).clamp(0,255).toInt();
        int g = (p.g*1.5 - b.g*0.5).clamp(0,255).toInt();
        int bl = (p.b*1.5 - b.b*0.5).clamp(0,255).toInt();
        im.setPixel(x,y, img.ColorRgb8(r,g,bl));
      }
    }
    return im;
  }

  static img.Image _removeShadow(img.Image src) {
    // dilate -> median -> divide approximation
    var gray = img.grayscale(src);
    var dilated = img.copyResize(gray, width: gray.width);
    // approximate background with large blur
    var background = img.gaussianBlur(gray, radius: 20);
    var result = img.Image(width: src.width, height: src.height);
    for (int y=0; y<src.height; y++) {
      for (int x=0; x<src.width; x++) {
        final s = src.getPixel(x,y);
        final bg = background.getPixel(x,y);
        double divR = bg.r==0? 1: s.r / bg.r;
        double divG = bg.g==0? 1: s.g / bg.g;
        double divB = bg.b==0? 1: s.b / bg.b;
        int r = (divR*255).clamp(0,255).toInt();
        int g = (divG*255).clamp(0,255).toInt();
        int b = (divB*255).clamp(0,255).toInt();
        result.setPixel(x,y, img.ColorRgb8(r,g,b));
      }
    }
    return result;
  }

  static double iou(List<DocPoints> a, List<DocPoints> b) {
    double minAx = a.map((p)=>p.x).reduce(math.min);
    double maxAx = a.map((p)=>p.x).reduce(math.max);
    double minAy = a.map((p)=>p.y).reduce(math.min);
    double maxAy = a.map((p)=>p.y).reduce(math.max);
    double minBx = b.map((p)=>p.x).reduce(math.min);
    double maxBx = b.map((p)=>p.x).reduce(math.max);
    double minBy = b.map((p)=>p.y).reduce(math.min);
    double maxBy = b.map((p)=>p.y).reduce(math.max);
    double interX1 = math.max(minAx, minBx);
    double interY1 = math.max(minAy, minBy);
    double interX2 = math.min(maxAx, maxBx);
    double interY2 = math.min(maxAy, maxBy);
    if (interX2<=interX1 || interY2<=interY1) return 0;
    double inter = (interX2-interX1)*(interY2-interY1);
    double areaA = (maxAx-minAx)*(maxAy-minAy);
    double areaB = (maxBx-minBx)*(maxBy-minBy);
    return inter / (areaA+areaB-inter);
  }
}
