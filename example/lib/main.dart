import 'package:flutter/material.dart';
import 'package:flutter_logo_draw/flutter_logo_draw.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatefulWidget { const DemoApp({super.key}); @override State<DemoApp> createState() => _DemoAppState(); }
class _DemoAppState extends State<DemoApp> {
  int replay = 0;
  final logo = Path()..moveTo(50, 8)..cubicTo(56, 28, 76, 26, 90, 50)..cubicTo(76, 74, 56, 72, 50, 92)..cubicTo(44, 72, 24, 74, 10, 50)..cubicTo(24, 26, 44, 28, 50, 8)..close();
  @override Widget build(BuildContext context) => MaterialApp(home: Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Logo Draw', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 28), LogoDraw(key: ValueKey(replay), logo: logo, size: 180), const SizedBox(height: 28), ElevatedButton(onPressed: () => setState(() => replay++), child: const Text('Replay'))]))));
}
