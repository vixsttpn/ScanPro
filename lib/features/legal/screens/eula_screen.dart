
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../services/eula_service.dart';
import '../../home/screens/home_screen.dart';

class EulaScreen extends StatefulWidget {
  const EulaScreen({super.key});
  @override State<EulaScreen> createState() => _EulaScreenState();
}

class _EulaScreenState extends State<EulaScreen> {
  bool checked = false;
  bool scrolledToEnd = false;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 40) {
        if (!scrolledToEnd) setState(() => scrolledToEnd = true);
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text('SCANPRO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.text)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                child: const Text('USER AGREEMENT • EULA v1.0', style: TextStyle(fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.w600, color: AppColors.text3)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Scrollbar(
                    controller: _scroll,
                    child: SingleChildScrollView(
                      controller: _scroll,
                      child: const Text(
'''ПОЛЬЗОВАТЕЛЬСКОЕ СОГЛАШЕНИЕ / EULA — ScanPro
Владелец: vixsttpn | Официальный источник: https://github.com/vixsttpn/ScanPro
Версия 1.0 от 21.08.2026

1. ОБЩИЕ ПОЛОЖЕНИЯ
1.1. Устанавливая или используя ScanPro, вы полностью принимаете условия LICENSE и данного Соглашения.
1.2. Если не согласны — удалите приложение.

2. ЛИЦЕНЗИЯ
2.1. Вам предоставляется право личного некоммерческого использования на ваших устройствах.
2.2. Запрещено коммерческое использование, перепродажа, публикация в сторах без письменного разрешения vixsttpn.

3. ИНТЕЛЛЕКТУАЛЬНАЯ СОБСТВЕННОСТЬ
3.1. Все права на ScanPro принадлежат vixsttpn.
3.2. Название, иконка, дизайн OLED Black, код — интеллектуальная собственность.

4. ЗАПРЕТ НА ПУБЛИКАЦИЮ В СТОРАХ
4.1. Официальное распространение ТОЛЬКО через GitHub: https://github.com/vixsttpn/ScanPro
4.2. Запрещена публикация APK/AAB/IPA или клона в Google Play, App Store, RuStore, Galaxy Store, AppGallery, APKPure, APKMirror, Telegram.
4.3. Нарушение п.4.2 считается КРАЖЕЙ ТОВАРА.

5. ОТВЕТСТВЕННОСТЬ И КОМПЕНСАЦИЯ
5.1. При обнаружении неавторизованной публикации владелец направляет DMCA и жалобу в стор.
5.2. Нарушитель обязан выплатить компенсацию минимум $5,000 USD за каждый факт + 100% дохода от незаконной публикации + судебные издержки.
5.3. Блокировка аккаунта нарушителя в сторе.

6. ОГРАНИЧЕНИЕ ОТВЕТСТВЕННОСТИ
Приложение предоставляется "как есть". Владелец не несет ответственности за ущерб.

7. КОНФИДЕНЦИАЛЬНОСТЬ
7.1. ScanPro работает 100% оффлайн. Не собирает данные, не отправляет на сервера, нет трекеров и рекламы.
7.2. Все сканы хранятся только на устройстве.

8. ПРИНЯТИЕ
Нажимая "СОГЛАСЕН И ОЗНАКОМИЛСЯ", вы подтверждаете что прочитали, поняли и принимаете условия.

---
ENGLISH:

Owner: vixsttpn | Official: https://github.com/vixsttpn/ScanPro
Proprietary. Official distribution only via GitHub.
Any republication on stores without permission is prohibited and considered theft. Compensation $5,000 per instance + legal fees + 100% illegal revenue. See LICENSE.
''',
                        style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.text2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => checked = !checked),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: checked ? AppColors.text : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: checked ? AppColors.text : AppColors.border, width: 1.5),
                        ),
                        child: checked ? const Icon(Icons.check, size: 14, color: AppColors.bg) : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Я прочитал, понял и принимаю соглашение и лицензию', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.text)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GestureDetector(
                  onTap: () async {
                    if (!checked) {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сначала поставьте галочку и пролистайте до конца'), backgroundColor: AppColors.surface2));
                      return;
                    }
                    if (!scrolledToEnd) {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Пролистайте соглашение до конца'), backgroundColor: AppColors.surface2));
                      return;
                    }
                    HapticFeedback.mediumImpact();
                    await EulaService.accept();
                    if (mounted) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                    }
                  },
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: checked ? AppColors.text : AppColors.surface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: checked ? AppColors.text : AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'СОГЛАСЕН И ОЗНАКОМИЛСЯ',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: checked ? AppColors.bg : AppColors.text3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
