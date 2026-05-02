import 'package:flutter/material.dart';

/// Plain text/password field used by sign-in & sign-up so both screens
/// share the same look and validation hooks.
///
/// When [obscureText] is true a visibility toggle is rendered as the
/// suffix icon, letting the user reveal what they typed.
class AuthFormField extends StatefulWidget {
  const AuthFormField({
    required this.label,
    required this.controller,
    super.key,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthFormField> createState() => _AuthFormFieldState();
}

class _AuthFormFieldState extends State<AuthFormField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final showToggle = widget.obscureText;
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      autofillHints: widget.autofillHints,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: showToggle
            ? IconButton(
                onPressed: () => setState(() => _obscured = !_obscured),
                icon: Icon(
                  _obscured ? Icons.visibility : Icons.visibility_off,
                ),
                tooltip: _obscured ? 'Show password' : 'Hide password',
              )
            : null,
      ),
    );
  }
}

/// Common validators shared between sign-in and sign-up.
abstract class AuthValidators {
  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'At least 6 characters';
    return null;
  }
}

/// A horizontal divider with centred "or" text. Used to separate the
/// password form from the OAuth buttons on the auth screens.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

/// Outlined "Continue with Google" button. The icon is a tiny inline
/// SVG-equivalent painted with a [CustomPaint], so we don't pull in an
/// asset / extra dependency just to render the brand mark.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    required this.onPressed,
    required this.isLoading,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const _GoogleGlyph(),
      label: const Text('Continue with Google'),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    // The official Google brand mark colours. Kept inline so we don't
    // ship a logo asset.
    return const SizedBox.square(
      dimension: 18,
      child: CustomPaint(painter: _GoogleGlyphPainter()),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  const _GoogleGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    const quadrants = <(double, double, Color)>[
      (-90, 90, Color(0xFF4285F4)), // right half — blue
      (90, 90, Color(0xFF34A853)), // bottom — green
      (180, 90, Color(0xFFFBBC05)), // left — yellow
      (270, 90, Color(0xFFEA4335)), // top — red
    ];

    for (final (start, sweep, color) in quadrants) {
      paint.color = color;
      final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
      canvas.drawArc(
        rect,
        start * 3.1415926535 / 180,
        sweep * 3.1415926535 / 180,
        true,
        paint,
      );
    }

    canvas
      // White inner circle so the colour wedges read as a "G"-style mark
      // without having to ship the actual logo.
      ..drawCircle(
        Offset(cx, cy),
        r * 0.55,
        Paint()..color = const Color(0xFFFFFFFF),
      )
      // Small blue notch on the right to suggest the gap in the "G".
      ..drawRect(
        Rect.fromLTWH(cx, cy - r * 0.08, r, r * 0.16),
        Paint()..color = const Color(0xFF4285F4),
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
