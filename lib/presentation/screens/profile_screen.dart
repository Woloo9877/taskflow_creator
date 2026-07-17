import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_info.dart';
import '../../core/utils/date_time_formatters.dart';
import '../../data/services/firebase_auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = FirebaseAuthService();
    final user = authService.currentUser;

    final creationTime = user?.metadata.creationTime;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.sunsetCopper,
              child: Text(
                (user?.email ?? '?').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.email ?? 'Unknown account',
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          if (creationTime != null) ...[
            const SizedBox(height: 4),
            Text(
              'Member since ${DateTimeFormatters.friendlyDate(creationTime)}',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 32),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.priorityCritical),
            title: const Text('Sign out'),
            onTap: () async {
              await authService.signOut();
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Text(AppInfo.appName, style: theme.textTheme.bodySmall),
                Text('Version ${AppInfo.version}', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}