import 'package:flutter/material.dart';

class RepeatModeNotifer extends ValueNotifier<RepeatModeState> {
  RepeatModeNotifer() : super(_initialValue);
  static const _initialValue = RepeatModeState.none;
}

enum RepeatModeState { none, all, one }
