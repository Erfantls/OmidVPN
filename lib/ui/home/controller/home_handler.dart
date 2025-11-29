part of 'home_controller.dart';

mixin HomeHandler {
  void selectServerUsecase(WidgetRef ref) async {
    final ServerInfo? server = await Navigator.push(
      ref.context,
      MaterialPageRoute(builder: (context) => const ServerListScreen()),
    );
    if (server != null) {
      ref.read(_serverInfoNotifier.notifier).setServerInfo(server);
    }
  }

  void connectUsecase(WidgetRef ref, {required ServerInfo? server}) async {
    if (server == null) return;

    // Check and request notification permission on Android
    if (Platform.isAndroid) {
      final openvpnService = await ref.read(openvpnServiceProvider.future);

      // Check if notification permission is granted
      final MethodChannel platform = MethodChannel('vpn_notification');
      bool hasPermission = false;

      try {
        hasPermission =
            await platform.invokeMethod('checkNotificationPermission') as bool;
      } catch (e) {
        // If method is not implemented, assume permission is needed
        hasPermission = false;
      }

      // If no permission, request it
      if (!hasPermission) {
        // Show a dialog to inform the user
        if (ref.context.mounted) {
          final shouldRequest = await showDialog<bool>(
            context: ref.context,
            builder: (context) => AlertDialog(
              title: Text('Notification Permission Required'),
              content: Text(
                'This app needs notification permission to show VPN connection status.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Continue'),
                ),
              ],
            ),
          );

          if (shouldRequest != true) {
            return;
          }
        }

        // Request notification permission
        try {
          await platform.invokeMethod('requestNotificationPermission');
          // Wait a bit for user to grant permission
          await Future.delayed(Duration(seconds: 1));
        } catch (e) {
          // Handle error silently
        }
      }
    }

    // Connect to VPN
    (await ref.read(
      openvpnServiceProvider.future,
    )).connectWithServerInfo(serverInfo: server);
  }

  void disconnectUsecase(WidgetRef ref) async {
    (await ref.read(openvpnServiceProvider.future)).disconnect();
  }
}
