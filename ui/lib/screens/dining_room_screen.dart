import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../theme/app_colors.dart';

class DiningRoomScreen extends StatefulWidget {
  const DiningRoomScreen({super.key});
  @override
  State<DiningRoomScreen> createState() => _DiningRoomScreenState();
}

class _DiningRoomScreenState extends State<DiningRoomScreen>
    with TickerProviderStateMixin {
  // Lights
  double _chandelierBrightness = 0.78;
  double _accentBrightness = 0.45;
  double _dimmerBrightness = 0.30;
  bool _chandelierOn = true;
  bool _accentOn = true;
  bool _dimmerOn = false;

  // Ambience
  double _temperatureTarget = 22.0;
  bool _acOn = true;
  int _selectedScene = 0;

  // Music
  bool _musicOn = true;
  double _volume = 0.6;
  int _selectedTrack = 1;

  // Curtains
  double _curtainOpen = 0.65;

  late AnimationController _fadeCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  final List<Map<String, dynamic>> _scenes = [
    {'label': 'Dinner', 'icon': Icons.restaurant_rounded, 'color': AppColors.amber},
    {'label': 'Party', 'icon': Icons.celebration_rounded, 'color': AppColors.red},
    {'label': 'Relax', 'icon': Icons.self_improvement_rounded, 'color': AppColors.teal},
    {'label': 'Focus', 'icon': Icons.wb_sunny_rounded, 'color': AppColors.blue},
  ];

  final List<Map<String, dynamic>> _tracks = [
    {'title': 'Ambient Jazz', 'artist': 'Smooth Lounge', 'duration': '3:42'},
    {'title': 'Dinner Classics', 'artist': 'Orchestra Set', 'duration': '4:15'},
    {'title': 'Lo-fi Chill', 'artist': 'Beats Studio', 'duration': '2:58'},
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _pulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
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
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF080F18), Color(0xFF0A1525), Color(0xFF060D18)],
              ),
            ),
          ),
          // Amber glow top-right
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 260, height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.amber.withOpacity(0.06), Colors.transparent,
                ]),
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

  // ─────────────────────────────────── HERO ─────────────────────────────────
  Widget _buildHero(BuildContext context, MediaQueryData mq) {
    return SizedBox(
      height: mq.size.height * 0.38,
      child: Stack(
        children: [
          // Background — decorative SVG-style dining illustration
          Positioned.fill(
            child: Image.asset(
              'assets/dining.png',
              fit: BoxFit.cover,
            ),
          ),
          // Brightness overlay
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              color: Colors.black.withOpacity((1.0 - (_chandelierOn ? _chandelierBrightness : 0.0)).clamp(0.0, 0.9)),
            ),
          ),
          // Dark gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.transparent,
                    AppColors.bgDeep.withOpacity(0.55),
                    AppColors.bgDeep,
                  ],
                  stops: const [0.0, 0.25, 0.75, 1.0],
                ),
              ),
            ),
          ),
          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _glassBtn(Icons.arrow_back_ios_rounded, onTap: () => Navigator.pop(context)),
                  _glassTitle('Dining Room'),
                  _glassBtn(Icons.more_vert_rounded, onTap: () {}),
                ],
              ),
            ),
          ),
          // Live status badge bottom-left
          Positioned(
            bottom: 20, left: 20,
            child: _buildLiveStatusBadge(),
          ),
          // Brightness vertical pill (right)
          Positioned(
            right: 20, top: 72, bottom: 20,
            child: _buildBrightnessPill(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiningIllustration() {
    return CustomPaint(painter: _DiningRoomPainter(), child: const SizedBox.expand());
  }

  Widget _buildLiveStatusBadge() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.teal.withOpacity(_pulseAnim.value),
                    boxShadow: [BoxShadow(color: AppColors.teal.withOpacity(0.6), blurRadius: 5)],
                  ),
                ),
                const SizedBox(width: 7),
                Text('3 devices active',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
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
                  shape: BoxShape.circle,
                  color: AppColors.amber,
                  boxShadow: [BoxShadow(color: AppColors.amber.withOpacity(0.5), blurRadius: 12)],
                ),
                child: const Icon(Icons.wb_incandescent_rounded, color: AppColors.bgDeep, size: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 5,
                      activeTrackColor: AppColors.amber,
                      inactiveTrackColor: Colors.white.withOpacity(0.08),
                      thumbColor: Colors.transparent,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                      overlayShape: SliderComponentShape.noOverlay,
                    ),
                    child: Slider(
                      value: _chandelierBrightness,
                      onChanged: (v) => setState(() => _chandelierBrightness = v),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  '${(_chandelierBrightness * 100).round()}%',
                  style: const TextStyle(color: AppColors.amber, fontSize: 10, fontWeight: FontWeight.w700),
                ),
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
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scene selector
          _buildSectionHeader('Scene', 'Active'),
          const SizedBox(height: 10),
          _buildSceneSelector(),
          const SizedBox(height: 20),

          // Lighting cards
          _buildSectionHeader('Lighting', '${[_chandelierOn, _accentOn, _dimmerOn].where((b) => b).length}/3 on'),
          const SizedBox(height: 10),
          _buildLightingRow(),
          const SizedBox(height: 20),

          // Climate + Curtains side-by-side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildClimateCard()),
              const SizedBox(width: 12),
              Expanded(child: _buildCurtainsCard()),
            ],
          ),
          const SizedBox(height: 20),

          // Music player
          _buildSectionHeader('Music', _musicOn ? 'Playing' : 'Paused'),
          const SizedBox(height: 10),
          _buildMusicCard(),
          const SizedBox(height: 20),

          // Quick stats row
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.amber.withOpacity(0.1),
            border: Border.all(color: AppColors.amber.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(sub,
              style: const TextStyle(color: AppColors.amber, fontSize: 10, fontWeight: FontWeight.w600)),
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
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.only(right: i < _scenes.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: active ? col.withOpacity(0.12) : AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: active ? col.withOpacity(0.4) : AppColors.bgGlassBorder,
                  width: active ? 1.5 : 1,
                ),
                boxShadow: active
                    ? [BoxShadow(color: col.withOpacity(0.2), blurRadius: 12)]
                    : null,
              ),
              child: Column(
                children: [
                  Icon(s['icon'] as IconData, color: active ? col : AppColors.textMuted, size: 20),
                  const SizedBox(height: 6),
                  Text(s['label'] as String,
                      style: TextStyle(
                        color: active ? col : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      )),
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
        Expanded(child: _buildLightCard('Chandelier', Icons.lightbulb_rounded, _chandelierBrightness, _chandelierOn, AppColors.amber,
            onToggle: (v) => setState(() {
              _chandelierOn = v;
              if (!v) _chandelierBrightness = 0.0;
              else if (_chandelierBrightness == 0.0) _chandelierBrightness = 0.5;
            }),
            onSlide: (v) => setState(() => _chandelierBrightness = v))),
        const SizedBox(width: 10),
        Expanded(child: _buildLightCard('Accent', Icons.highlight_rounded, _accentBrightness, _accentOn, AppColors.teal,
            onToggle: (v) => setState(() {
              _accentOn = v;
              if (!v) _accentBrightness = 0.0;
              else if (_accentBrightness == 0.0) _accentBrightness = 0.5;
            }),
            onSlide: (v) => setState(() => _accentBrightness = v))),
        const SizedBox(width: 10),
        Expanded(child: _buildLightCard('Dimmer', Icons.wb_twilight_rounded, _dimmerBrightness, _dimmerOn, AppColors.blue,
            onToggle: (v) => setState(() {
              _dimmerOn = v;
              if (!v) _dimmerBrightness = 0.0;
              else if (_dimmerBrightness == 0.0) _dimmerBrightness = 0.5;
            }),
            onSlide: (v) => setState(() => _dimmerBrightness = v))),
      ],
    );
  }

  Widget _buildLightCard(
    String label, IconData icon, double brightness, bool on, Color accent, {
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onSlide,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: on ? accent.withOpacity(0.08) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: on ? accent.withOpacity(0.3) : AppColors.bgGlassBorder,
        ),
        boxShadow: on ? [BoxShadow(color: accent.withOpacity(0.15), blurRadius: 14)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: on ? accent : AppColors.textMuted, size: 18),
              GestureDetector(
                onTap: () => onToggle(!on),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32, height: 18,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    color: on ? accent : AppColors.bgGlassBorder,
                    boxShadow: on ? [BoxShadow(color: accent.withOpacity(0.4), blurRadius: 6)] : null,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: on ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(width: 14, height: 14,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('${(brightness * 100).round()}%',
              style: TextStyle(color: on ? AppColors.textPrimary : AppColors.textMuted,
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          // Mini slider track
          _miniProgressBar(on ? brightness : 0, accent),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _miniProgressBar(double value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Container(
        height: 3,
        color: AppColors.bgGlass,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.5), color]),
              boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClimateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _acOn ? AppColors.teal.withOpacity(0.25) : AppColors.bgGlassBorder,
        ),
        boxShadow: _acOn ? [BoxShadow(color: AppColors.teal.withOpacity(0.1), blurRadius: 14)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Climate', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => setState(() => _acOn = !_acOn),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36, height: 20,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _acOn ? AppColors.teal : AppColors.bgGlassBorder,
                    boxShadow: _acOn ? [BoxShadow(color: AppColors.tealGlow, blurRadius: 8)] : null,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _acOn ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(width: 16, height: 16,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () { if (_acOn && _temperatureTarget > 16) setState(() => _temperatureTarget -= 0.5); },
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.bgGlass, border: Border.all(color: AppColors.bgGlassBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove_rounded, color: AppColors.textSecondary, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Text('${_temperatureTarget.toStringAsFixed(1)}°',
                      style: TextStyle(
                        color: _acOn ? AppColors.teal : AppColors.textMuted,
                        fontSize: 26, fontWeight: FontWeight.w800,
                      )),
                  const Text('Target', style: TextStyle(color: AppColors.textMuted, fontSize: 9)),
                ],
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () { if (_acOn && _temperatureTarget < 30) setState(() => _temperatureTarget += 0.5); },
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.bgGlass, border: Border.all(color: AppColors.bgGlassBorder),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              Text('24.0°C', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontFamily: 'monospace')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurtainsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bgGlassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Curtains', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          // Curtain visual
          Center(
            child: SizedBox(
              height: 64,
              child: CustomPaint(
                painter: _CurtainPainter(_curtainOpen),
                child: const SizedBox(width: 100, height: 64),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              activeTrackColor: AppColors.amber,
              inactiveTrackColor: AppColors.bgGlassBorder,
              thumbColor: AppColors.amber,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: _curtainOpen,
              onChanged: (v) => setState(() => _curtainOpen = v),
            ),
          ),
          Center(
            child: Text('${(_curtainOpen * 100).round()}% open',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _musicOn ? AppColors.teal.withOpacity(0.2) : AppColors.bgGlassBorder),
        boxShadow: _musicOn ? [BoxShadow(color: AppColors.teal.withOpacity(0.08), blurRadius: 16)] : null,
      ),
      child: Column(
        children: [
          // Track list
          ...List.generate(_tracks.length, (i) => _buildTrackRow(i)),
          const SizedBox(height: 12),
          // Volume row
          Row(
            children: [
              const Icon(Icons.volume_down_rounded, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3,
                    activeTrackColor: AppColors.teal,
                    inactiveTrackColor: AppColors.bgGlassBorder,
                    thumbColor: AppColors.teal,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(value: _volume, onChanged: (v) => setState(() => _volume = v)),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.volume_up_rounded, color: AppColors.textMuted, size: 16),
              const SizedBox(width: 12),
              // Play/Pause
              GestureDetector(
                onTap: () => setState(() => _musicOn = !_musicOn),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _musicOn ? AppColors.teal : AppColors.bgGlass,
                    border: Border.all(color: _musicOn ? AppColors.teal : AppColors.bgGlassBorder),
                    boxShadow: _musicOn ? [BoxShadow(color: AppColors.teal.withOpacity(0.4), blurRadius: 12)] : null,
                  ),
                  child: Icon(
                    _musicOn ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _musicOn ? AppColors.bgDeep : AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackRow(int i) {
    final t = _tracks[i];
    final active = _selectedTrack == i;
    return GestureDetector(
      onTap: () => setState(() => _selectedTrack = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.teal.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.teal.withOpacity(0.2) : Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: active ? AppColors.teal : AppColors.bgGlass,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: active ? AppColors.teal : AppColors.bgGlassBorder),
              ),
              child: Icon(active && _musicOn ? Icons.equalizer_rounded : Icons.music_note_rounded,
                  color: active ? AppColors.bgDeep : AppColors.textMuted, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['title']!, style: TextStyle(
                      color: active ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
                  Text(t['artist']!, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ),
            Text(t['duration']!, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {'label': 'Temp', 'value': '24°C', 'icon': Icons.thermostat_rounded, 'color': AppColors.teal},
      {'label': 'Humidity', 'value': '48%', 'icon': Icons.water_drop_outlined, 'color': AppColors.blue},
      {'label': 'Power', 'value': '1.8 kW', 'icon': Icons.bolt_rounded, 'color': AppColors.amber},
      {'label': 'AQI', 'value': 'Good', 'icon': Icons.air_rounded, 'color': AppColors.red},
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
                Icon(s['icon'] as IconData, color: color, size: 16),
                const SizedBox(height: 6),
                Text(s['value'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
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

class _DiningRoomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final floorPaint = Paint()..color = const Color(0xFF0A1520);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.6, w, h * 0.4), floorPaint);
    final wallPaint = Paint()..color = const Color(0xFF0D1C30);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h * 0.62), wallPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurtainPainter extends CustomPainter {
  final double open;
  _CurtainPainter(this.open);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.amber.withOpacity(0.4)..style = PaintingStyle.fill;
    final w = size.width; final h = size.height;
    canvas.drawRect(Rect.fromLTWH(0, 0, w * (1 - open) * 0.45, h), paint);
    canvas.drawRect(Rect.fromLTWH(w - (w * (1 - open) * 0.45), 0, w * (1 - open) * 0.45, h), paint);
  }
  @override
  bool shouldRepaint(covariant _CurtainPainter oldDelegate) => oldDelegate.open != open;
}
