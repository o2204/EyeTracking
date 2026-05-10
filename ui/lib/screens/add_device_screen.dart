import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/api_config.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedType = 'Light';
  String _selectedStatus = 'Connected';
  final List<String> _selectedFeatures = [];
  bool _isSaving = false;

  final List<String> _deviceTypes = [
    'Camera',
    'Sensor',
    'Smart Lock',
    'Light',
    'Speaker',
    'Wheelchair Sensor'
  ];

  final List<String> _statuses = ['Active', 'Inactive', 'Connected'];

  final List<Map<String, dynamic>> _accessibilityFeatures = [
    {'label': 'Voice Control', 'icon': Icons.mic_rounded},
    {'label': 'Sign Language Support', 'icon': Icons.front_hand_rounded},
    {'label': 'Motion Detection', 'icon': Icons.motion_photos_on_rounded},
  ];

  Future<void> _saveDevice() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a device name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/devices/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'name': name,
          'type': _selectedType,
          'status': _selectedStatus,
          'accessibility_features': _selectedFeatures,
        }),
      );

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Device $name added successfully!'),
              backgroundColor: AppColors.teal,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Failed to save device');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF080F1A),
                  Color(0xFF0A1628),
                  Color(0xFF060D18),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Device Name', 'Give your device a unique name'),
                        const SizedBox(height: 16),
                        _buildNameField(),
                        const SizedBox(height: 32),

                        _buildSectionTitle('Device Type', 'Recommended'),
                        const SizedBox(height: 16),
                        _buildTypeGrid(),
                        const SizedBox(height: 32),
                        
                        _buildSectionTitle('Device Status', 'Current State'),
                        const SizedBox(height: 16),
                        _buildStatusSelector(),
                        const SizedBox(height: 32),
                        
                        _buildSectionTitle('Accessibility Features', 'Optional'),
                        const SizedBox(height: 16),
                        _buildAccessibilityList(),
                        const SizedBox(height: 40),
                        
                        _buildSaveButton(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _glassBtn(Icons.arrow_back_ios_rounded, onTap: () => Navigator.pop(context)),
          const SizedBox(width: 20),
          const Text(
            'Add New Device',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassBtn(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgGlassBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _nameController,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'e.g. Living Room Camera',
          hintStyle: TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTypeGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _deviceTypes.map((type) {
        final isSelected = _selectedType == type;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.teal.withOpacity(0.1) : AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.teal : AppColors.bgGlassBorder,
                width: 1.5,
              ),
              boxShadow: isSelected ? [BoxShadow(color: AppColors.teal.withOpacity(0.15), blurRadius: 10)] : null,
            ),
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? AppColors.teal : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: _statuses.map((status) {
        final isSelected = _selectedStatus == status;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedStatus = status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: status != _statuses.last ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.blue.withOpacity(0.1) : AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.blue : AppColors.bgGlassBorder,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  status,
                  style: TextStyle(
                    color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAccessibilityList() {
    return Column(
      children: _accessibilityFeatures.map((feature) {
        final label = feature['label'] as String;
        final icon = feature['icon'] as IconData;
        final isSelected = _selectedFeatures.contains(label);
        
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedFeatures.remove(label);
              } else {
                _selectedFeatures.add(label);
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? AppColors.teal.withOpacity(0.4) : AppColors.bgGlassBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.teal.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: isSelected ? AppColors.teal : AppColors.textSecondary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (v) {
                    setState(() {
                      if (v!) {
                        _selectedFeatures.add(label);
                      } else {
                        _selectedFeatures.remove(label);
                      }
                    });
                  },
                  activeColor: AppColors.teal,
                  checkColor: AppColors.bgDeep,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  side: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: _isSaving ? null : _saveDevice,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.teal, Color(0xFF1CB5E0)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.teal.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: _isSaving 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.bgDeep, strokeWidth: 2))
            : const Text(
                'Save Device',
                style: TextStyle(
                  color: AppColors.bgDeep,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
        ),
      ),
    );
  }
}