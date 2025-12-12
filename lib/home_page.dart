import 'dart:async';

import 'package:flutter/material.dart';
import 'esp_control_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  DateTime _time = DateTime.now();

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

  String _formatTime(DateTime date) {
    return TimeOfDay.fromDateTime(date).format(context);
  }

  String _formatDate(DateTime date) {
    return "${_weekday(date.weekday)}, ${_month(date.month)} ${date.day.toString().padLeft(2, '0')}";
  }

  String get _hourMinute24 {
    final h = _time.hour.toString().padLeft(2, '0');
    final m = _time.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  static String _weekday(int w) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(w - 1).clamp(0, 6)];
  }

  static String _month(int m) {
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
    return names[(m - 1).clamp(0, 11)];
  }

  void _onLoginTap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EspControlPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Center(
        child: Container(
          width: 360,
          height: 760,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(36),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF020817),
                Color(0xFF020617),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                Positioned(
                  top: -120,
                  right: -40,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x332563EB), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -120,
                  left: -40,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [Color(0x333B82F6), Colors.transparent],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                      const SizedBox(height: 80),
                      Column(
                        children: [
                          Text(
                            _hourMinute24,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
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
                              letterSpacing: 3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 56),
                      Column(
                        children: [
                          Container(
                            width: 140,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(14),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Image.asset(
                                'assets/images/robomanthan_new_logo_redesigned.png',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Robomanthan Pvt Ltd',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _onLoginTap,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 12,
                            shadowColor: const Color(0xFF1D4ED8).withOpacity(0.6),
                            backgroundColor: Colors.transparent,
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith((states) {
                              return null; // use Ink decoration below
                            }),
                          ),
                          child: Ink(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(14)),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'If life gives you lemons,',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'make it lemonade.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF60A5FA),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
