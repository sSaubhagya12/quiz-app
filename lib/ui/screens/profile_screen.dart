import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  final bool isEmbedded;
  const ProfileScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final student = authProvider.currentStudent;

    Widget body = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF1E3C72),
              child: Text(
                student?.name.isNotEmpty == true ? student!.name[0].toUpperCase() : 'S',
                style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              student?.name ?? 'Student',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
            ),
            Text(
              student?.email ?? '',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Stats
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    value: '${student?.xp ?? 0}',
                    label: 'XP Points',
                    icon: Icons.star_rounded,
                    color: const Color(0xFFF2994A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatBox(
                    value: '${(student?.avgScore ?? 0.0).toStringAsFixed(1)}%',
                    label: 'Avg Score',
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF27AE60),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Information',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E3C72)),
                  ),
                  const Divider(height: 20),
                  _InfoRow(icon: Icons.school_rounded, label: 'School', value: student?.school ?? '-'),
                  _InfoRow(icon: Icons.grade_rounded, label: 'Grade', value: student?.grade ?? '-'),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'O/L Year',
                    value: '${student?.oLevelYear ?? '-'}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  // Navigate to root and clear stack
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEB5757),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!isEmbedded) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F4FF),
        appBar: AppBar(
          title: const Text('My Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1E3C72),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: body,
      );
    }
    return body;
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatBox({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E3C72)),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
