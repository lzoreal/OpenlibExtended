import 'package:flutter/animation.dart';

// Shared motion for the navigation controls (the bottom dock, the
// book-mode switch and the root tabs). These match the Material TabBar
// defaults so a dock tap and a settings-tab tap move at the same speed:
// kTabScrollDuration is 300ms with Curves.ease.
const Duration kSelectionAnimationDuration = Duration(milliseconds: 300);
const Curve kSelectionAnimationCurve = Curves.ease;

const Duration kPageSwitchDuration = Duration(milliseconds: 300);
const Curve kPageSwitchCurve = Curves.ease;
