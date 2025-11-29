import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';

class NotificationPermissionDialog extends ConsumerStatefulWidget {
  const NotificationPermissionDialog({super.key});

  @override
  ConsumerState<NotificationPermissionDialog> createState() => _NotificationPermissionDialogState();
}

class _NotificationPermissionDialogState extends ConsumerState<NotificationPermissionDialog> {
  static const MethodChannel _platform = MethodChannel('vpn_notification');
  bool _isLoading = false;
  bool _showSettingsOption = false;

  @override
  void initState() {
    super.initState();
    // Initially try to request permission in-app
    _tryRequestPermissionInApp();
  }

  Future<void> _tryRequestPermissionInApp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bool permissionGranted = await _platform.invokeMethod('requestNotificationPermissionInApp') as bool;
      
      if (permissionGranted) {
        // Permission already granted or successfully requested
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        // Need to show settings option
        if (mounted) {
          setState(() {
            _showSettingsOption = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Error occurred, show settings option
      if (mounted) {
        setState(() {
          _showSettingsOption = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openAppSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _platform.invokeMethod('openAppSettingsForNotifications');
    } catch (e) {
      // Handle error silently
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Close the dialog
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.notifications_active,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Notification Permission Required',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This app needs notification permission to show VPN connection status and control the VPN connection.',
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Notifications will only be used to show connection status and allow you to control your VPN connection from the notification panel.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      actions: [
        if (!_showSettingsOption)
          TextButton(
            onPressed: _isLoading ? null : () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
        if (_showSettingsOption) ...[
          TextButton(
            onPressed: _isLoading ? null : () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _openAppSettings,
            child: Text('Open Settings'),
          ),
        ] else if (!_isLoading) ...[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
        ]
      ],
    );
  }
}