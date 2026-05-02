import 'package:flutter/material.dart';

/// Corner radius scale (ShadCN-inspired).
///
/// `lg` (8.0) is the default control radius — buttons, inputs, smaller chips.
/// `xl` (12.0) is for larger surfaces like cards, sheets, the floating nav.
/// `full` produces fully rounded ends (pills, avatars).
abstract final class AppRadii {
  static const double xs = 2;
  static const double sm = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double xxl = 16;
  static const double full = 9999;

  static const BorderRadius xsR = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smR = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdR = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgR = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlR = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlR = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius fullR = BorderRadius.all(Radius.circular(full));
}
