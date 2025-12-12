import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EspControlPage extends StatefulWidget {
  const EspControlPage({super.key});

  @override
  State<EspControlPage> createState() => _EspControlPageState();
}

class _EspControlPageState extends State<EspControlPage> {
  late Timer _timer;
  DateTime _time = DateTime.now();

  bool _lightOn = false;
  String _connectionStatus = 'connected'; // 'connected' | 'connecting'

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _time = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _hourMinute24 {
    final h = _time.hour.toString().padLeft(2, '0');
    final m = _time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _formatDate(DateTime date) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = names[(date.month - 1).clamp(0, 11)];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[(date.weekday - 1).clamp(0, 6)];
    return '$weekday, $month ${date.day.toString().padLeft(2, '0')}';
  }
  Future<void> _toggleLight() async {
    if (_connectionStatus == 'connecting') return;
    setState(() {
      _connectionStatus = 'connecting';
    });

    try {
      final target = !_lightOn;
      final ip = '10.255.189.167'; // current ESP32 IP from Serial Monitor
      final path = target ? '/on' : '/off';
      final uri = Uri.parse('http://$ip$path');

      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) {
        throw Exception('ESP32 error: HTTP ${res.statusCode}');
      }
      setState(() {
        _lightOn = target;
        _connectionStatus = 'connected';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'connected';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('BLE error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Container(
                    width: 360,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Status bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _hourMinute24,
                              style: const TextStyle(
                                color: Color(0xFFCBD5F5),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: const [
                                Icon(Icons.signal_cellular_4_bar, size: 16, color: Color(0xFF94A3B8)),
                                SizedBox(width: 6),
                                Icon(Icons.wifi, size: 16, color: Color(0xFF94A3B8)),
                                SizedBox(width: 6),
                                Icon(Icons.battery_full, size: 16, color: Color(0xFF94A3B8)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // Header with back
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Color(0xFFE5E7EB), size: 22),
                            ),
                            const Text(
                              'Smart Control',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Time & date center
                        Column(
                          children: [
                            Text(
                              _hourMinute24,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(_time),
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // Glow circle with bulb
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 600),
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _lightOn
                                      ? const Color(0x33FACC15)
                                      : Colors.transparent,
                                  boxShadow: _lightOn
                                      ? const [
                                          BoxShadow(
                                            color: Color(0x33FACC15),
                                            blurRadius: 40,
                                            spreadRadius: 10,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: 170,
                                height: 170,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 4,
                                    color: _lightOn
                                        ? const Color(0xFFFACC15)
                                        : const Color(0xFF4B5563),
                                  ),
                                  color: _lightOn
                                      ? const Color(0x1AFACC15)
                                      : const Color(0xFF020617),
                                ),
                                child: Icon(
                                  Icons.lightbulb,
                                  size: 80,
                                  color: _lightOn
                                      ? const Color(0xFFFACC15)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Status text
                        Column(
                          children: [
                            Text(
                              _connectionStatus == 'connecting'
                                  ? 'Connecting...'
                                  : (_lightOn ? 'Light is ON' : 'Light is OFF'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _connectionStatus == 'connecting'
                                        ? const Color(0xFFF97316)
                                        : const Color(0xFF22C55E),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'ESP32 Device 01',
                                  style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Toggle button
                        Center(
                          child: SizedBox(
                            width: 96,
                            height: 96,
                            child: ElevatedButton(
                              onPressed:
                                  _connectionStatus == 'connecting' ? null : _toggleLight,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 12,
                                backgroundColor: Colors.transparent,
                                shadowColor: _lightOn
                                    ? const Color(0xFFF97316).withOpacity(0.5)
                                    : Colors.black.withOpacity(0.7),
                              ).copyWith(
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color?>((states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return const Color(0xFF4B5563);
                                  }
                                  return null;
                                }),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: _lightOn
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFFACC15),
                                            Color(0xFFF97316),
                                          ],
                                        )
                                      : const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF111827),
                                            Color(0xFF1F2937),
                                          ],
                                        ),
                                ),
                                child: Center(
                                  child: _connectionStatus == 'connecting'
                                      ? const SizedBox(
                                          width: 26,
                                          height: 26,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.6,
                                            valueColor: AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.power_settings_new,
                                          color: Colors.white,
                                          size: 34,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Tap to toggle power',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
