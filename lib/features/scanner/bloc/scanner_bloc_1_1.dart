
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

enum ScanMode { single, batch, idCard, book, passport }

abstract class ScannerEvent extends Equatable {
  @override List<Object?> get props => [];
}
class ScannerModeChanged extends ScannerEvent {
  final ScanMode mode;
  ScannerModeChanged(this.mode);
  @override List<Object?> get props => [mode];
}
class ScannerImageCaptured extends ScannerEvent {
  final String path;
  ScannerImageCaptured(this.path);
  @override List<Object?> get props => [path];
}
class ScannerImagesCleared extends ScannerEvent {}

class ScannerState extends Equatable {
  final ScanMode mode;
  final List<String> images;
  final bool autoMode;
  const ScannerState({this.mode=ScanMode.single, this.images=const [], this.autoMode=true});
  ScannerState copyWith({ScanMode? mode, List<String>? images, bool? autoMode}) =>
    ScannerState(mode: mode??this.mode, images: images??this.images, autoMode: autoMode??this.autoMode);
  @override List<Object?> get props => [mode, images, autoMode];
}

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  ScannerBloc(): super(const ScannerState()) {
    on<ScannerModeChanged>((e,s)=>emit(s.copyWith(mode:e.mode)));
    on<ScannerImageCaptured>((e,s){
      final list = List<String>.from(s.images)..add(e.path);
      emit(s.copyWith(images:list));
    });
    on<ScannerImagesCleared>((e,s)=>emit(s.copyWith(images:[])));
  }
}
