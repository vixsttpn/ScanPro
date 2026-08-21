
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/doc_processor.dart';
import '../../../core/theme/app_icons_svg.dart';

class FilterCarousel extends StatelessWidget {
  final DocFilter selected;
  final ValueChanged<DocFilter> onSelect;
  const FilterCarousel({super.key, required this.selected, required this.onSelect});
  @override Widget build(BuildContext context) {
    final filters = DocFilter.values;
    return SizedBox(height: 92, child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filters.length,
      itemBuilder: (_, i){
        final f = filters[i];
        final isSel = f==selected;
        return GestureDetector(
          onTap: ()=>onSelect(f),
          child: AnimatedContainer(
            duration: AppDurations.ui,
            curve: AppDurations.curve,
            margin: const EdgeInsets.only(right: 12),
            width: 72,
            decoration: BoxDecoration(
              color: isSel? AppColors.text : AppColors.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isSel? AppColors.text : AppColors.border),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              SvgPicture.asset(_iconFor(f), width: 20, height: 20, colorFilter: ColorFilter.mode(isSel? AppColors.bg : AppColors.text, BlendMode.srcIn)),
              const SizedBox(height: 8),
              Text(f.name.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: isSel? AppColors.bg: AppColors.text2)),
            ]),
          ),
        );
      },
    ));
  }
  String _iconFor(DocFilter f){
    switch(f){
      case DocFilter.original: return AppIconSvg.scan;
      case DocFilter.auto: return AppIconSvg.enhance;
      case DocFilter.gray: return AppIconSvg.filterMagic;
      case DocFilter.bw: return AppIconSvg.textOcr;
      case DocFilter.noShadow: return AppIconSvg.shadowOff;
      case DocFilter.lowLight: return AppIconSvg.flash;
    }
  }
}
