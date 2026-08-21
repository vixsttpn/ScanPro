# ScanPro — The Last Scanner You Will Ever Need.

![Build](https://github.com/scanpro/scanpro/actions/workflows/build-apk.yml/badge.svg)

**100% FREE, NO ADS, NO WATERMARK, OFFLINE, 4K, OPEN SOURCE**

> CamScanner выглядит как поделка 2015 года.

### Design System OLED Black & 120FPS
- Bg #000000 true black, Surface #0A0A0A, Border #1E1E1E
- Accent #FFFFFF — дорого как Linear/Raycast
- Inter Tight 600/400, Curves.easeOutExpo 220ms/350ms
- const constructors, RepaintBoundary, Isolate.run(), Impeller, Haptic

### Features vs CamScanner
| Feature | ScanPro ✅ | CamScanner ❌💰 |
|---|---|---|
| 4K ultraHigh | ✅ | ❌ |
| Offline OCR MLKit | ✅ | ❌💰 |
| No Watermark | ✅ | ❌💰 |
| No Ads | ✅ | ❌ |
| Batch / ID Card / Book | ✅ | ✅💰 |
| Filters NoShadow B&W | ✅ | ✅💰 |
| Searchable PDF | ✅ | ✅💰 |
| QR WiFi Connect | ✅ | ❌ |
| Open Source | ✅ | ❌ |

### Install
Actions → Build ScanPro APK → Artifacts → ScanPro-APK → install universal APK

```bash
flutter pub get
flutter analyze # 0 errors
flutter build apk --release --split-per-abi
```
