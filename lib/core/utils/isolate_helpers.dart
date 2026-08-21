
import 'package:flutter/foundation.dart';

class IsolateHelpers {
  static Future<T> run<T>(Future<T> Function() fn) async {
    return await Isolate.run(() async => await fn());
  }
  static Future<R> compute<R,P>(Future<R> Function(P) fn, P message) async {
    return await Isolate.run(() => fn(message));
  }
}
