import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../theme/app_theme.dart';
import '../models/dashboard_models.dart';

class LiveUsersTable extends StatefulWidget {
  final List<UserModel> users;
  final ThemeData theme;
  final bool isDark;
  final Function(UserModel) onRemove;

  const LiveUsersTable({
    super.key,
    required this.users,
    required this.theme,
    required this.isDark,
    required this.onRemove,
  });

  @override
  State<LiveUsersTable> createState() => _LiveUsersTableState();
}

class _LiveUsersTableState extends State<LiveUsersTable> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  late List<UserModel> _items;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _items = [];

    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _loading = false;
        _items = List.from(widget.users);
      });

      for (int i = 0; i < _items.length; i++) {
        _listKey.currentState?.insertItem(i);
      }
    });
  }

  @override
  void didUpdateWidget(covariant LiveUsersTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.users.length < _items.length) {
      _items = List.from(widget.users);
    }
  }

  void _removeItem(int index) {
    final removedUser = _items[index];

    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildItem(removedUser, animation, index),
      duration: const Duration(milliseconds: 300),
    );

    _items.removeAt(index);
    widget.onRemove(removedUser);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildShimmer();

    return AnimatedList(
      key: _listKey,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        return _buildItem(_items[index], animation, index);
      },
    );
  }

  Widget _buildItem(UserModel user, Animation<double> animation, int index) {
    final statusColor = user.status == 'active'
        ? Colors.green
        : user.status == 'idle'
            ? Colors.orange
            : Colors.grey;

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Dismissible(
          key: ValueKey(user.name + user.time),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _removeItem(index),

          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.red),
          ),

          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF111827) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      AppTheme.primary.withValues(alpha: 0.15),
                  child: Text(user.name[0]),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${user.room} • ${user.device}",
                          style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(user.status,
                      style: TextStyle(color: statusColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Column(
      children: List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}