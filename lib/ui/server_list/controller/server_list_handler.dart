part of 'server_list_controller.dart';

mixin ServerListHandler {
  void getServerListUsecase(
    WidgetRef ref, {
    bool forceRefresh = false,
    bool getCache = false,
  }) {
    ref
        .read(serverListAsyncNotifier.notifier)
        .getServerList(forceRefresh: forceRefresh, getCache: getCache);
  }

  void selectServerUsecase(WidgetRef ref, {required ServerInfo server}) async {
    final context = ref.context;
    final VpnService vpnService = await ref.read(openvpnServiceProvider.future);

    if (vpnService.vpnstage == VpnStage.disconnected && context.mounted) {
      Navigator.pop(context, server);
      return;
    }

    if (!context.mounted) {
      return;
    }
    final bool disconnectApproved =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => DisconnectAlertDialog(),
        ) ??
        false;

    if (!context.mounted) {
      return;
    }
    if (disconnectApproved) {
      vpnService.disconnect();
      Navigator.pop(context, server);
    }
  }
}
