import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../services/api_config.dart';

class ReceptionRoomScreen extends StatefulWidget {
  const ReceptionRoomScreen({super.key});
  @override
  State<ReceptionRoomScreen> createState() => _ReceptionRoomScreenState();
}

class _ReceptionRoomScreenState extends State<ReceptionRoomScreen>
    with TickerProviderStateMixin {
  // Lighting
  double _mainBrightness = 0.60;
  double _floorLampBrightness = 0.80;
  double _ledStripBrightness = 0.55;
  bool _mainOn = true;
  bool _floorLampOn = true;
  bool _ledStripOn = true;

  // Color temperature
  int _colorTempIdx = 1; // 0=Warm, 1=Neutral, 2=Cool
  final List<Map<String, dynamic>> _colorTemps = [
    {'label': 'Warm', 'color': const Color(0xFFF5A623), 'k': '2700K'},
    {'label': 'Neutral', 'color': AppColors.textPrimary, 'k': '4000K'},
    {'label': 'Cool', 'color': AppColors.blue, 'k': '6500K'},
  ];
  bool _isLoadingWeather = true;

  // Security
  // removed

  // Smart TV
  bool _tvOn = false;
  int _tvInputIdx = 0;
  final List<String> _tvInputs = ['HDMI 1', 'HDMI 2', 'Apple TV', 'Smart TV'];

  // Scene
  int _selectedScene = 0;
  final List<Map<String, dynamic>> _scenes = [
    {'label': 'Welcome', 'icon': Icons.waving_hand_rounded, 'color': AppColors.teal},
    {'label': 'Meeting', 'icon': Icons.people_rounded, 'color': AppColors.blue},
    {'label': 'Evening', 'icon': Icons.nights_stay_rounded, 'color': AppColors.amber},
    {'label': 'Away', 'icon': Icons.lock_rounded, 'color': AppColors.red},
  ];

  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    
    _fetchWeatherAndSetColorTemp();
  }

  Future<void> _fetchWeatherAndSetColorTemp() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/weather/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final colorTemp = data['color_temp'] as String;
        if (mounted) {
          setState(() {
            if (colorTemp == 'Warm') _colorTempIdx = 0;
            else if (colorTemp == 'Neutral') _colorTempIdx = 1;
            else if (colorTemp == 'Cool') _colorTempIdx = 2;
            _isLoadingWeather = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingWeather = false);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF07101C), Color(0xFF0B1828), Color(0xFF050E18)],
              ),
            ),
          ),
          // Teal glow top-left
          Positioned(
            top: -80, left: -80,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [AppColors.teal.withOpacity(0.05), Colors.transparent]),
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                _buildHero(context, mq),
                Expanded(child: _buildScrollBody()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────── HERO ────────────────────────────────────
  Widget _buildHero(BuildContext context, MediaQueryData mq) {
    return SizedBox(
      height: mq.size.height * 0.38,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/reception.png',
              fit: BoxFit.cover,
            ),
          ),
          // Brightness overlay
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: Colors.black.withOpacity((1.0 - (_mainOn ? _mainBrightness : 0.0)).clamp(0.0, 0.9)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.1), Colors.transparent, AppColors.bgDeep.withOpacity(0.5), AppColors.bgDeep],
                  stops: const [0.0, 0.2, 0.75, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _glassBtn(Icons.arrow_back_ios_rounded, onTap: () => Navigator.pop(context)),
                  _glassTitle('Reception'),
                  _glassBtn(Icons.more_vert_rounded, onTap: () {}),
                ],
              ),
            ),
          ),
          // Brightness pill right
          Positioned(right: 20, top: 72, bottom: 18, child: _buildBrightnessPill()),
        ],
      ),
    );
  }



  Widget _buildBrightnessPill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: 52,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.38),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.teal,
                  boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.5), blurRadius: 12)],
                ),
                child: const Icon(Icons.wb_sunny_rounded, color: AppColors.bgDeep, size: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 5,
                      activeTrackColor: AppColors.teal,
                      inactiveTrackColor: Colors.white.withOpacity(0.08),
                      thumbColor: Colors.transparent,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(value: _mainBrightness, onChanged: (v) => setState(() => _mainBrightness = v)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text('${(_mainBrightness * 100).round()}%',
                    style: const TextStyle(color: AppColors.teal, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────── SCROLL BODY ─────────────────────────────────
  Widget _buildScrollBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scene selector
          _buildSectionHeader('Scene', 'Active'),
          const SizedBox(height: 10),
          _buildSceneSelector(),
          const SizedBox(height: 20),

          // Lighting
          _buildSectionHeader('Lighting', '${[_mainOn, _floorLampOn, _ledStripOn].where((b) => b).length}/3 on'),
          const SizedBox(height: 10),
          _buildLightingRow(),
          const SizedBox(height: 12),

          // Color temperature
          _buildColorTempRow(),
          const SizedBox(height: 20),

          const SizedBox(height: 20),

          // Smart TV
          _buildSectionHeader('Smart TV', _tvOn ? 'On' : 'Standby'),
          const SizedBox(height: 10),
          _buildTVCard(),
          const SizedBox(height: 20),

          // Quick stats
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.08),
            border: Border.all(color: AppColors.teal.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(sub, style: const TextStyle(color: AppColors.teal, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildSceneSelector() {
    return Row(
      children: List.generate(_scenes.length, (i) {
        final s = _scenes[i];
        final active = _selectedScene == i;
        final Color col = s['color'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () { HapticFeedback.selectionClick(); setState(() => _selectedScene = i); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < _scenes.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: active ? col.withOpacity(0.10) : AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: active ? col.withOpacity(0.35) : AppColors.bgGlassBorder, width: active ? 1.5 : 1),
                boxShadow: active ? [BoxShadow(color: col.withOpacity(0.18), blurRadius: 12)] : null,
              ),
              child: Column(
                children: [
                  Icon(s['icon'] as IconData, color: active ? col : AppColors.textMuted, size: 20),
                  const SizedBox(height: 5),
                  Text(s['label'] as String,
                      style: TextStyle(color: active ? col : AppColors.textSecondary,
                          fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLightingRow() {
    return Row(
      children: [
        Expanded(child: _buildLightCard('Main Light', Icons.light_rounded, _mainBrightness, _mainOn, AppColors.teal,
            onToggle: (v) => setState(() {
              _mainOn = v;
              if (!v) _mainBrightness = 0.0;
              else if (_mainBrightness == 0.0) _mainBrightness = 0.5;
            }),
            onSlide: (v) => setState(() => _mainBrightness = v))),
        const SizedBox(width: 10),
        Expanded(child: _buildLightCard('Floor Lamp', Icons.light_mode_rounded, _floorLampBrightness, _floorLampOn, AppColors.amber,
            onToggle: (v) => setState(() {
              _floorLampOn = v;
              if (!v) _floorLampBrightness = 0.0;
              else if (_floorLampBrightness == 0.0) _floorLampBrightness = 0.5;
            }),
            onSlide: (v) => setState(() => _floorLampBrightness = v))),
        const SizedBox(width: 10),
        Expanded(child: _buildLightCard('LED Strip', Icons.auto_awesome_rounded, _ledStripBrightness, _ledStripOn, AppColors.blue,
            onToggle: (v) => setState(() {
              _ledStripOn = v;
              if (!v) _ledStripBrightness = 0.0;
              else if (_ledStripBrightness == 0.0) _ledStripBrightness = 0.5;
            }),
            onSlide: (v) => setState(() => _ledStripBrightness = v))),
      ],
    );
  }

  Widget _buildLightCard(String label, IconData icon, double brightness, bool on, Color accent,
      {required ValueChanged<bool> onToggle, required ValueChanged<double> onSlide}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: on ? accent.withOpacity(0.08) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: on ? accent.withOpacity(0.28) : AppColors.bgGlassBorder),
        boxShadow: on ? [BoxShadow(color: accent.withOpacity(0.12), blurRadius: 14)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: on ? accent : AppColors.textMuted, size: 16),
              GestureDetector(
                onTap: () => onToggle(!on),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30, height: 17,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: on ? accent : AppColors.bgGlassBorder,
                    boxShadow: on ? [BoxShadow(color: accent.withOpacity(0.4), blurRadius: 6)] : null,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(width: 13, height: 13, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${(brightness * 100).round()}%',
              style: TextStyle(color: on ? AppColors.textPrimary : AppColors.textMuted, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          _miniBar(on ? brightness : 0, accent),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _miniBar(double val, Color col) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        height: 3, color: AppColors.bgGlass,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: val.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [col.withOpacity(0.5), col]),
              boxShadow: [BoxShadow(color: col.withOpacity(0.5), blurRadius: 3)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorTempRow() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgGlassBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.thermostat_rounded, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 10),
          const Text('Color Temp', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          Row(
            children: List.generate(_colorTemps.length, (i) {
              final ct = _colorTemps[i];
              final active = _colorTempIdx == i;
              final Color col = ct['color'] as Color;
              return Opacity(
                opacity: _isLoadingWeather ? 0.5 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(left: i > 0 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? col.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: active ? col.withOpacity(0.4) : AppColors.bgGlassBorder),
                  ),
                  child: Text(ct['label'] as String,
                      style: TextStyle(color: active ? col : AppColors.textMuted,
                          fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }



  Widget _buildTVCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _tvOn ? AppColors.blue.withOpacity(0.25) : AppColors.bgGlassBorder),
        boxShadow: _tvOn ? [BoxShadow(color: AppColors.blue.withOpacity(0.1), blurRadius: 16)] : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // TV illustration
              Container(
                width: 64, height: 44,
                decoration: BoxDecoration(
                  color: _tvOn ? const Color(0xFF0A1828) : const Color(0xFF0A1420),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _tvOn ? AppColors.blue.withOpacity(0.3) : AppColors.bgGlassBorder),
                  boxShadow: _tvOn ? [BoxShadow(color: AppColors.blue.withOpacity(0.15), blurRadius: 10)] : null,
                ),
                child: _tvOn
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 36, height: 2, color: AppColors.blue.withOpacity(0.4)),
                            const SizedBox(height: 4),
                            Container(width: 28, height: 1.5, color: AppColors.blue.withOpacity(0.2)),
                            const SizedBox(height: 3),
                            Container(width: 32, height: 1.5, color: AppColors.blue.withOpacity(0.2)),
                          ],
                        ),
                      )
                    : Icon(Icons.tv_rounded, color: AppColors.textMuted.withOpacity(0.4), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Smart TV', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(_tvOn ? _tvInputs[_tvInputIdx] : 'Standby',
                        style: TextStyle(color: _tvOn ? AppColors.blue : AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () { HapticFeedback.lightImpact(); setState(() => _tvOn = !_tvOn); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _tvOn ? AppColors.blue : AppColors.bgGlass,
                    border: Border.all(color: _tvOn ? AppColors.blue : AppColors.bgGlassBorder),
                    boxShadow: _tvOn ? [BoxShadow(color: AppColors.blue.withOpacity(0.4), blurRadius: 12)] : null,
                  ),
                  child: Icon(Icons.power_settings_new_rounded,
                      color: _tvOn ? Colors.white : AppColors.textMuted, size: 20),
                ),
              ),
            ],
          ),
          if (_tvOn) ...[
            const SizedBox(height: 14),
            Divider(color: AppColors.bgGlassBorder, height: 1),
            const SizedBox(height: 12),
            // Input selector
            Row(
              children: List.generate(_tvInputs.length, (i) {
                final active = _tvInputIdx == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tvInputIdx = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(right: i < _tvInputs.length - 1 ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.blue.withOpacity(0.12) : AppColors.bgGlass,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: active ? AppColors.blue.withOpacity(0.3) : AppColors.bgGlassBorder),
                      ),
                      child: Text(_tvInputs[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: active ? AppColors.blue : AppColors.textMuted,
                            fontSize: 10, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                          )),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {'label': 'Temp', 'value': '23°C', 'icon': Icons.thermostat_rounded, 'color': AppColors.teal},
      {'label': 'Humidity', 'value': '52%', 'icon': Icons.water_drop_outlined, 'color': AppColors.blue},
      {'label': 'Power', 'value': '2.1 kW', 'icon': Icons.bolt_rounded, 'color': AppColors.amber},
      {'label': 'Noise', 'value': '38dB', 'icon': Icons.hearing_rounded, 'color': AppColors.red},
    ];
    return Row(
      children: stats.map((s) {
        final color = s['color'] as Color;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: stats.last == s ? 0 : 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.bgGlassBorder),
            ),
            child: Column(
              children: [
                Icon(s['icon'] as IconData, color: color, size: 15),
                const SizedBox(height: 6),
                Text(s['value'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                Text(s['label'] as String, style: const TextStyle(color: AppColors.textMuted, fontSize: 9)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Shared glass widgets ──
  Widget _glassBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _glassTitle(String title) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.28),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _ReceptionPainter extends CustomPainter {
  final double brightness;
  final bool ledOn;
  final bool lampOn;
  _ReceptionPainter(this.brightness, this.ledOn, this.lampOn);
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final floorPaint = Paint()..color = const Color(0xFF08121C);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.65, w, h * 0.35), floorPaint);
    final wallPaint = Paint()..color = const Color(0xFF0A1C2E);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.67), wallPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
