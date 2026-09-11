import 'dart:math' as math;
import 'package:flutter/material.dart';

class LogoDraw extends StatefulWidget {
  const LogoDraw({
    super.key,
    required this.logo,
    this.size = 160,
    this.drawDuration = const Duration(milliseconds: 1200),
    this.fillStartPercent = 70,
    this.fillDuration = const Duration(milliseconds: 350),
    this.fillsLogo = true,
    this.strokeWidth = 1.5,
    this.outlineColor = Colors.black,
    this.fillColor = Colors.black,
    this.replayTrigger = 0,
    this.freezeAt,
    this.accessibilityLabel = 'Logo',
    this.onComplete,
  });

  final Path logo;
  final double size;
  final Duration drawDuration;
  final double fillStartPercent;
  final Duration fillDuration;
  final bool fillsLogo;
  final double strokeWidth;
  final Color outlineColor;
  final Color fillColor;
  final int replayTrigger;
  final double? freezeAt;
  final String accessibilityLabel;
  final VoidCallback? onComplete;

  @override
  State<LogoDraw> createState() => _LogoDrawState();
}

class _LogoDrawState extends State<LogoDraw> with TickerProviderStateMixin {
  late final AnimationController _draw;
  late final AnimationController _fill;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _draw = AnimationController(vsync: this, duration: widget.drawDuration);
    _fill = AnimationController(vsync: this, duration: widget.fillDuration);
    _fillAnimation = CurvedAnimation(parent: _fill, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  @override
  void didUpdateWidget(covariant LogoDraw oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.replayTrigger != widget.replayTrigger || oldWidget.logo != widget.logo) _play();
  }

  Future<void> _play() async {
    _draw.stop();
    _fill.stop();
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final fixed = widget.freezeAt?.clamp(0, 1).toDouble();
    if (fixed != null || reduced) {
      _draw.value = fixed ?? 1;
      _fill.value = fixed != null ? (fixed * 100 >= widget.fillStartPercent ? 1 : 0) : 1;
      if (mounted) widget.onComplete?.call();
      return;
    }
    _draw.value = 0;
    _fill.value = 0;
    final drawFuture = _draw.forward();
    final fillStart = Duration(milliseconds: (widget.drawDuration.inMilliseconds * widget.fillStartPercent / 100).round());
    final fillFuture = widget.fillsLogo
        ? Future<void>.delayed(fillStart, () => _fill.forward())
        : Future<void>.value();
    await Future.wait<void>([drawFuture, fillFuture]);
    if (!mounted) return;
    if (!widget.fillsLogo) { widget.onComplete?.call(); return; }
    if (mounted) widget.onComplete?.call();
  }

  @override
  void dispose() { _draw.dispose(); _fill.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Semantics(
    label: widget.accessibilityLabel,
    image: true,
    child: SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_draw, _fill]),
        builder: (_, __) => CustomPaint(
          painter: _LogoPainter(
            logo: widget.logo,
            progress: _draw.value,
            fillOpacity: widget.fillsLogo ? _fillAnimation.value : 0,
            strokeWidth: widget.strokeWidth,
            outlineColor: widget.outlineColor,
            fillColor: widget.fillColor,
          ),
        ),
      ),
    ),
  );
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter({required this.logo, required this.progress, required this.fillOpacity, required this.strokeWidth, required this.outlineColor, required this.fillColor});
  final Path logo;
  final double progress;
  final double fillOpacity;
  final double strokeWidth;
  final Color outlineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = logo.getBounds();
    final scale = math.min(size.width / bounds.width, size.height / bounds.height);
    final matrix = Matrix4.identity()..translate((size.width - bounds.width * scale) / 2 - bounds.left * scale, (size.height - bounds.height * scale) / 2 - bounds.top * scale)..scale(scale, scale);
    final transformed = logo.transform(matrix.storage);
    if (fillOpacity > 0) canvas.drawPath(transformed, Paint()..style = PaintingStyle.fill..color = fillColor.withOpacity(fillOpacity));
    final metrics = transformed.computeMetrics().toList();
    final total = metrics.fold<double>(0, (sum, m) => sum + m.length);
    var remaining = total * progress;
    final traced = Path();
    for (final metric in metrics) {
      if (remaining <= 0) break;
      final segment = metric.extractPath(0, math.min(remaining, metric.length));
      traced.addPath(segment, Offset.zero);
      remaining -= metric.length;
    }
    canvas.drawPath(traced, Paint()..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round..color = outlineColor);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) => old.progress != progress || old.fillOpacity != fillOpacity || old.logo != logo;
}
