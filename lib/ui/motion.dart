import 'package:flutter/animation.dart';

// Shared motion for the two primary navigation controls (the book-mode
// switch and the bottom dock) so they feel like the same component family.
const Duration kSelectionAnimationDuration = Duration(milliseconds: 260);
const Curve kSelectionAnimationCurve = Curves.easeOutCubic;

const Duration kPageSwitchDuration = Duration(milliseconds: 240);
const Curve kPageSwitchCurve = Curves.easeOut;
