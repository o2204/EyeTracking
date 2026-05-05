import 'package:flutter/material.dart';
import 'admin/models/dashboard_models.dart';
import 'admin/widgets/live_users_table.dart';
import 'admin/add_user_screen.dart';
import 'admin/send_notification_screen.dart';
import 'package:graduation_project/features/profile/screens/analytics_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late List<UserModel> _users;
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();

    _users = [
      const UserModel(name: 'Ahmed Hassan', room: 'Room A', status: 'active', device: 'Tracker 1', time: '10m'),
      const UserModel(name: 'Sara Mohamed', room: 'Room B', status: 'idle', device: 'Tracker 2', time: '5m'),
      const UserModel(name: 'Omar Khaled', room: 'Room C', status: 'offline', device: '-', time: '-'),
    ];
  }

  /// 🔥 Stats
  int get totalUsers => _users.length;

  int get activeUsers =>
      _users.where((u) => u.status == 'active').length;

  int get offlineUsers =>
      _users.where((u) => u.status == 'offline').length;

  void _removeUser(UserModel user) {
    setState(() => _users.remove(user));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${user.name} removed")),
    );
  }

  void _logout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        _buildDashboard(context),
        const AnalyticsScreen(),
      ],
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
  title: const Text("Admin Dashboard"),
  elevation: 0,
  backgroundColor: Colors.transparent, // مهم جدًا
  actions: [
    IconButton(
      onPressed: _logout,
      icon: const Icon(Icons.logout),
    )
  ],
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 82, 127, 163), // اللون الأول
          Color(0xFF1E3A5F), // اللون الثاني (أغمق)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    ),
  ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 🔥 STATS CARDS
          Row(
            children: [
              Expanded(child: _statCard("Users", totalUsers, Colors.blue)),
              const SizedBox(width: 10),
              Expanded(child: _statCard("Online", activeUsers, Colors.green)),
              const SizedBox(width: 10),
              Expanded(child: _statCard("Offline", offlineUsers, Colors.red)),
            ],
          ),

          const SizedBox(height: 20),

          /// 🔥 ACTION BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final newUser = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddUserScreen(),
                      ),
                    );

                    if (newUser != null) {
                      setState(() => _users.add(newUser));
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text("Add User"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const SendNotificationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.notifications),
                  label: const Text("Notify"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text("Live Users", style: theme.textTheme.titleLarge),

          const SizedBox(height: 16),

          LiveUsersTable(
            users: _users,
            theme: theme,
            isDark: isDark,
            onRemove: _removeUser,
          ),

          const SizedBox(height: 40),

          Center(
            child: Text(
              "👉 Swipe left to see Analytics",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 STAT CARD UI
  Widget _statCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "$count",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }
}